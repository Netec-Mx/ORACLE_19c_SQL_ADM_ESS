# Uso de INTERVAL YEAR TO MONTH y INTERVAL DAY TO SECOND en Oracle

## Objetivos
Demostrar cómo crear una tabla en Oracle que use tipos de datos de intervalo, `INTERVAL YEAR TO MONTH` y `INTERVAL DAY TO SECOND`, insertar datos y consultarlos usando funciones de fecha e intervalos.


## Instrucciones

### 1. Creación de la tabla

```sql
CREATE TABLE demo_intervalos (
    id         NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre     VARCHAR2(50),
    antiguedad INTERVAL YEAR TO MONTH,  -- Años y meses
    duracion   INTERVAL DAY TO SECOND   -- Días, horas, minutos y segundos
);

desc demo_intervalos
```

<br/><br/>

### 2. Inserts de prueba

```sql
INSERT INTO demo_intervalos (nombre, antiguedad, duracion)
VALUES (
    'Proyecto Alpha',
    INTERVAL '3-4' YEAR TO MONTH,          -- 3 años, 4 meses
    INTERVAL '2 05:30:00' DAY TO SECOND    -- 2 días, 5h 30m
);

INSERT INTO demo_intervalos (nombre, antiguedad, duracion)
VALUES (
    'Servicio Beta',
    INTERVAL '0-10' YEAR TO MONTH,         -- 10 meses
    INTERVAL '0 12:15:45' DAY TO SECOND    -- 12h 15m 45s
);

INSERT INTO demo_intervalos (nombre, antiguedad, duracion)
VALUES (
    'Caso Gamma',
    INTERVAL '1' YEAR + INTERVAL '6' MONTH,
    INTERVAL '1' DAY + INTERVAL '03:20:00' HOUR TO SECOND
);
```



Verificación rápida:

```sql

set linesize 200
col nombre format a20
col antiguedad format a30
col duracion format a30

SELECT * FROM demo_intervalos;
SELECT count(*) "Total" FROM demo_intervalos;

```

<br/><br/>

## 3. Consulta de partes del INTERVAL

```sql
SELECT
    nombre,
    EXTRACT(YEAR  FROM antiguedad)  AS anios,
    EXTRACT(MONTH FROM antiguedad)  AS meses,
    EXTRACT(DAY   FROM duracion)    AS dias,
    EXTRACT(HOUR  FROM duracion)    AS horas,
    EXTRACT(MINUTE FROM duracion)   AS minutos
FROM demo_intervalos;
```

<br/><br/>

## 4. Uso en aritmética con fechas

```sql
col fecha_con_antiguedad format a30
col fecha_con_duracion format a30

SELECT 
    nombre,
    SYSDATE AS hoy,
    SYSDATE + antiguedad AS fecha_con_antiguedad,
    SYSDATE + duracion    AS fecha_con_duracion
FROM demo_intervalos;

SELECT 
    nombre,
    TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') AS hoy,
    TO_CHAR(SYSDATE + antiguedad, 'DD/MM/YYYY HH24:MI:SS') AS fecha_con_antiguedad,
    TO_CHAR(SYSDATE + duracion,  'DD/MM/YYYY HH24:MI:SS') AS fecha_con_duracion
FROM demo_intervalos;

```

<br/><br/>

## 5. UPDATE sobre columnas INTERVAL

### 1. Aumentar 1 año a todas las antigüedades

```sql

SELECT id, nombre, antiguedad
FROM demo_intervalos
ORDER BY id;

UPDATE demo_intervalos
SET antiguedad = antiguedad + INTERVAL '1' YEAR;

SELECT id, nombre, antiguedad
FROM demo_intervalos
ORDER BY id;

```

### 2. Ajustar la duración de un registro específico

Ejemplo: aumentar 30 minutos al registro “Servicio Beta”:

```sql
SELECT id, nombre, duracion
FROM demo_intervalos
ORDER BY id;

UPDATE demo_intervalos
SET duracion = duracion + INTERVAL '0 00:30:00' DAY TO SECOND
WHERE nombre = 'Servicio Beta';

SELECT id, nombre, duracion
FROM demo_intervalos
ORDER BY id;
```

<br/><br/>

## 6. DELETE usando una condición sobre INTERVAL

Ejemplo: borrar los registros cuya duración sea menor a 1 día:

```sql
DELETE FROM demo_intervalos
WHERE duracion < INTERVAL '1' DAY;
```

Verificar filas restantes:

```sql
SELECT * FROM demo_intervalos;
```

<br/><br/>

## 7. Limpieza final (DROP + RECYCLEBIN + PURGE)

### 1. Verificar que la tabla aún existe

```sql
SELECT table_name
FROM user_tables
WHERE table_name = 'DEMO_INTERVALOS';
```

### 2. Eliminar la tabla (se va al RECYCLEBIN)

```sql
DROP TABLE demo_intervalos;
```

### 3 Verificar en el RECYCLEBIN

```sql
SHOW RECYCLEBIN;
```

O vía vista de diccionario:

```sql
col ORIGINAL_NAME format a30
col OBJECT_NAME format a50

SELECT original_name, object_name, type, droptime
FROM user_recyclebin
WHERE original_name = 'DEMO_INTERVALOS';
```

### 4. PURGE de la tabla (limpieza definitiva)

Si quieres purgar **solo esa tabla**:

```sql
PURGE TABLE demo_intervalos;
```

> Nota: Se refiere al `original_name` en el recyclebin.

Si quieres purgar **todo el recyclebin del usuario** 

```sql
PURGE RECYCLEBIN;
```

<br/><br/>

## 8. Exploración de tipos de objetos en el diccionario de datos

Realiza una consulta sobre la vista USER_OBJECTS para identificar todos los tipos de objetos existentes en tu esquema. Obtén una lista única de los valores presentes en la columna TYPE. Ordena el resultado alfabéticamente.

```sql
SET PAGESIZE 100;

SELECT DISTINCT 
       object_name,
       object_type
FROM user_objects
ORDER BY object_type;

```
