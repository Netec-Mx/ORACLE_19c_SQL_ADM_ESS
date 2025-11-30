

# DEMO 5.3  UNDO_RETENTION + GUARANTEED RETENTION + SNAPSHOT TOO OLD

<br/><br/>

## Códigos de error

### ORA-30036 — *unable to extend segment in undo tablespace*

No se pudo extender el segmento en el tablespace de undo

Es un error de espacio en el tablespace de UNDO. No es un problema de datos de usuario, sino de que Oracle ya no tiene dónde escribir más UNDO

Recordemos que cuando ejecutamos DML (INSERT, UPDATE, DELETE, MERGE):

1. Oracle escribe UNDO en el tablespcae de UNDO.
2. Ese UNDO vive en segmentos de undo (extents, block, etc.), este sigue siendo un tablespace.
3. Si el segmento necesita más espacio, Oracle intenta extenderlo (asignar nuevos extents) dentro del uno tablespace.

<br/><br/>

### ORA-01555 — *snapshot too old*

Oracle no puede reconstruir la imagen consistente (read-consistent) de un bloque que una consulta larga necesita, porque el UNDO que contenía la versión antigua ya fue sobrescrito.

Oracle garantiza que toda consulta ve datos consistentes al momento en que comenzó.
Esto se llama read consistency.

Ejemplo:

* A las 12:00 inicias un SELECT muy largo sobre una tabla grande.
* A las 12:01 alguien actualiza esas mismas filas.
* A las 12:03 tu SELECT “tarda”, sigue corriendo…
* Oracle debe mostrarte los datos tal como estaban a las 12:00, aunque ya cambiaron varias veces.

<br/>

¿De dónde obtiene la versión antigua? **Del UNDO.**

Es decir, Oracle necesita copias viejas de los bloques modificados, para reconstruir cómo eran en el “momento lógico” del inicio de tu SELECT.

<br/>

¿Cómo evitar ORA-01555 en producción?

Hay técnicas reales:

* Aumentar tamaño del UNDO TS. 
  Más espacio, más versiones antiguas disponibles.

* Aumentar UNDO_RETENTION
  Más tiempo mínimo de retención.

* Reducir DML concurrente
  Menos presión sobre el UNDO.

* Usar automatización (AUTOEXTEND)
  Permite crecer cuando se necesita.

* Evitar consultas largas sin necesidad
  A veces es tan simple como reescribir un query o poner índices.
  
* Para cargas masivas: COMMIT por lotes pequeños
  No mezclar SELECT largos con UPDATE masivos.

<br/><br/>


### Tarea 1. Labores de limpieza

```sql
ALTER SYSTEM SET undo_tablespace = UNDOTBS1;

DROP TABLESPACE undotbs_demo INCLUDING CONTENTS AND DATAFILES;
DROP TABLE t_demo PURGE;
```

Ignora errores si no existen.

<br/><br/>

### Tarea 2. Crear UNDO tablespace pequeño con GUARANTEE

```sql
CREATE UNDO TABLESPACE undotbs_demo
DATAFILE '/u01/app/oracle/oradata/UNDODEMO01.dbf'
SIZE 40M
RETENTION GUARANTEE;

ALTER SYSTEM SET undo_tablespace = undotbs_demo SCOPE=BOTH;

ALTER SYSTEM SET undo_retention = 300;  

-- 300 sefundos = 5 minutos
```

Crear tabla grande:

```sql
CREATE TABLE t_demo AS

SELECT rownum id,
       rpad('X',400,'X') txt
FROM   dual
CONNECT BY LEVEL <= 50000;

```

<br/><br/>

### Tarea 2. Provocar ORA-30036 (Retention Guarantee)

Esta versión está optimizada para generar UNDO pesado "rápido"

```sql
SET SERVEROUTPUT ON

DECLARE
  i PLS_INTEGER := 0;
BEGIN
  WHILE i < 400 LOOP
    UPDATE t_demo SET txt = rpad('Y',400,'Y');
    i := i + 1;

    IF MOD(i,40) = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Iteración: ' || i);
      COMMIT;
    END IF;
  END LOOP;
END;
/
```

> **Resultado esperado:**
**ORA-30036: unable to extend segment by … in undo tablespace 'UNDOTBS_DEMO'**

### Por qué pasa:

* Con **RETENTION GUARANTEE**, Oracle **NO** puede sobrescribir UNEXPIRED UNDO.
* El espacio del tablespace se llena entre ACTIVE + UNEXPIRED.
* Oracle prefiere lanzar ORA-30036 antes que perder UNDO protegido.

En otra sesión monitorea:

```sql
set linesize 200
SELECT status, COUNT(*) FROM   dba_undo_extents WHERE  tablespace_name = 'UNDOTBS_DEMO' GROUP  BY status;
```

Veremos que **UNEXPIRED sube sin parar**.

<br/><br/>

### Tarea 4. Cambiar a modo normal (NOGUARANTEE)

Para permitir snapshot too old:

```sql
ALTER TABLESPACE undotbs_demo RETENTION NOGUARANTEE;
ALTER SYSTEM SET undo_retention = 60;
```

<br/><br/>

### Tarea 5. Provocar ORA-01555 (Snapshot Too Old)

#### Sesión 1. Ejecuta una consulta larga:

```sql
SELECT /*+ FULL(t) FULL(t2) */
       t.id, t2.id, t.txt
FROM   t_demo t, t_demo t2
WHERE  t.id = t2.id
AND    t.id <= 30000;
```

Déjala corriendo.

<br/><br/>

#### Sesión 2. Genera mucho UNDO + commits:

```sql
DECLARE
  i PLS_INTEGER := 0;
BEGIN
  WHILE i < 500 LOOP
    UPDATE t_demo SET txt = rpad('Z',400,'Z');
    COMMIT;
    i := i + 1;
  END LOOP;
END;
/
```

<br/><br/>

## Resultado esperado en la sesión 1

**ORA-01555: snapshot too old**
*(rollback segment ... too small)*

<br/>

> **Nota:** Por qué pasa

* Sin GUARANTEE, Oracle **sí** puede reciclar UNEXPIRED UNDO.
* La consulta larga necesita imágenes viejas de los bloques.
* El UNDO necesario ya fue sobrescrito por las actualizaciones.
* Oracle no puede reconstruir la imagen consistente lanza un ORA-01555.


### Tarea 6. Limpieza

```sql

ALTER SYSTEM SET undo_tablespace = UNDOTBS1;

DROP TABLESPACE undotbs_demo INCLUDING CONTENTS AND DATAFILES;

DROP TABLE t_demo PURGE;
```


