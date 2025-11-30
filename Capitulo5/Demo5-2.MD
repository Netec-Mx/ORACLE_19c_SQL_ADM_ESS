# DEMO 5.2 Comparando UNDO con tabla normal vs una tabla teporal


## Temas

#### 1. Parámetro `TEMP_UNDO_ENABLED` 

`TEMP_UNDO_ENABLED` es un parámetro introducido en Oracle 12c que controla **dónde se almacena el UNDO generado por operaciones sobre tablas temporales (GTTs)**.


* Las GTT **siempre** almacenan sus datos en TEMP, con o sin temporary undo.
* `TEMP_UNDO_ENABLED` **no afecta a tablas permanentes**.
* No elimina el UNDO por completo; elimina solo la necesidad de UNDO “normal”.
* Con `TEMP_UNDO_ENABLED = FALSE`: consumo de UNDO se ve en `V$TRANSACTION` y `V$UNDOSTAT`.
* Con `TEMP_UNDO_ENABLED = TRUE`: el consumo se mueve hacia `V$TEMPUNDOSTAT` y `V$SORT_USAGE`.

#### 2. Tablas Temporales Globales (GTT)

Las **GLOBAL TEMPORARY TABLES (GTT)** son tablas cuyo **esquema es permanente**, pero cuyos **datos son siempre temporales** y solo visibles para cada sesión.

* La **definición** de la tabla es permanente (existe en el diccionario).
* Los **datos** son temporales y **privados por sesión**.
* Los datos se almacenan en el **tablespace TEMP**, no en uno permanente.
* Se pueden definir dos modos:

  * `ON COMMIT DELETE ROWS` → los datos desaparecen al COMMIT.
  * `ON COMMIT PRESERVE ROWS` → los datos duran toda la sesión.

* Usan **undo mínimo**, porque no requieren mantener imágenes para consistencia entre sesiones.


Ver GTTs del usuario:

```sql
set linesize 200
col table_name format a30
SELECT table_name, temporary, duration FROM user_tables WHERE temporary = 'Y' order by 1;
```


<br/><br/>

### Tarea 1. Verificar que `TEMP_UNDO_ENABLED` está en FALSE

Conéctate como SYS:

```sql
CONN sys/Oracle1 AS SYSDBA;
```

Verifica el parámetro:

```sql
SHOW PARAMETER temp_undo_enabled;
```

> Si está en `TRUE`, cámbialo (para la demo) a TRUE:

```sql
ALTER SYSTEM SET temp_undo_enabled=TRUE SCOPE=BOTH;
```

Y reconéctate:

```sql
CONN sys/Oracle1 AS SYSDBA;
```

<br/><br/>

### Tarea 2. Labores de limpieza y creación de tablas

Vamos a crear dos tablas con la **misma estructura**:

* `T_NORMAL` → tabla permanente.
* `T_TEMP`   → tabla temporal global.

```sql
-- Limpieza previa
DROP TABLE t_normal PURGE;
DROP TABLE t_temp   PURGE;

-- Crear tabla normal
CREATE TABLE t_normal (
  id   NUMBER,
  dato VARCHAR2(50)
);

-- Crear tabla temporal global (por transacción)
CREATE GLOBAL TEMPORARY TABLE t_temp (
  id   NUMBER,
  dato VARCHAR2(50)
) ON COMMIT DELETE ROWS;
```

<br/><br/>

### Tarea 3. Medir UNDO con tabla normal

#### 1. Baseline de la transacción

Nos aseguramos de que no haya transacciones activas:

```sql
ROLLBACK;

SELECT used_ublk, used_urec FROM v$transaction;
```

> Salida esperada: `no rows selected`



#### 2. Insertar 50,000 filas en T_NORMAL

```sql
BEGIN
  FOR i IN 1..50000 LOOP
    INSERT INTO t_normal VALUES (i, 'NORMAL');
  END LOOP;
END;
/
```

#### Paso 3. Ver consumo de UNDO tras el INSERT masivo

Las columnas USED_UBLK y USED_UREC  la vista V$TRANSACTION proporcionan información sobre la cantidad de espacio de deshacer que consume una transacción activa. 

* USED_UBLK: Esta columna indica la cantidad de bloques de deshacer utilizados actualmente por la transacción.
* USED_UREC: Esta columna indica la cantidad de registros de deshacer utilizados actualmente por la transacción. 

```sql
SELECT used_ublk, used_urec FROM v$transaction;
```


> **Nota:** En una tabla normal, cada fila insertada genera UNDO para poder hacer rollback, lectura consistente, etc.



#### 4. Limpiar

```sql
ROLLBACK;

SELECT used_ublk, used_urec FROM v$transaction;
```

<br/><br/>

### Tarea 4. Medir UNDO con tabla temporal global (GTT)

#### 1. Confirmar baseline limpia

```sql
ROLLBACK;

SELECT used_ublk, used_urec FROM  v$transaction;
```

#### 2. Insertar 50,000 filas en T_TEMP (GTT)

```sql
BEGIN
  FOR i IN 1..50000 LOOP
    INSERT INTO t_temp VALUES (i, 'TEMP');
  END LOOP;
END;
/
```

#### 3. Ver consumo de UNDO tras el INSERT en la GTT

```sql
SELECT used_ublk, used_urec FROM v$transaction;
```

> **Nota:** Podríamos ver valor pero mínimos conparados con la tarea anterior.


Mientras tanto, confirmamos que las filas **sí existen**:

```sql
SELECT COUNT(*) FROM t_temp;
```

<br/><br/>

## Tarea 5. Comparación y conclusiones

Con los datos reales que obtuvimos la salida es muy similar a lo siguiente:

| Caso                                 | Filas insertadas | USED_UBLK | USED_UREC |
| ------------------------------------ | ---------------- | --------- | --------- |
| Tabla normal `T_NORMAL`              | 50,000           | 432       | 50,000    |
| GTT `T_TEMP` (ON COMMIT DELETE ROWS) | 50,000           | 1         | 1         |


> **Conclusiones:**
1. En ambos casos, **las filas sí existen** (comprobado con `COUNT(*)`).
2. La **tabla normal** genera **UNDO proporcional al número de filas**:
   * mucha más presión sobre el tablespace UNDO.
3. La **GTT** genera solo **UNDO mínimo**:
   * 1 bloque / 1 registro de UNDO para 50,000 filas,
   * porque los datos están en segmentos temporales (TEMP) y Oracle puede “descartarlos” sin necesidad de un before-image detallado.
4. Con `TEMP_UNDO_ENABLED = TRUE`:
   * el poco UNDO que se genera para la GTT sigue yendo al **UNDO tablespace**,
   * pero la cantidad es **mínima** comparada con una tabla normal.

<br/><br/>

## Tarea 6. Limpieza final

```sql
ROLLBACK;

DROP TABLE t_normal PURGE;
DROP TABLE t_temp   PURGE;
```

 
> **Observación:** Para mayor claridad, puedes repetir la demo pero con el valor de `TEMP_UNDO_ENABLED=FALSE`