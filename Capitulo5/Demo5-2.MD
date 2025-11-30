# DEMO 5.2 Comparando UNDO con tabla normal vs una tabla teporal


## Temas

* Parámetro:  `TEMP_UNDO_ENABLED`
* Tablas Temporales


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