
# Demo 5.4 Tablas Anidadas

<br/><br/>

### ¿Qué es una tabla anidada en Oracle?

Una **tabla anidada** (*nested table*) es **un tipo de colección** en Oracle que:

* Puede almacenarse en una **columna de una tabla**.
* Actúa como una **lista sin límite superior de elementos**.
* Puede **crecer dinámicamente**.
* Puede **almacenarse en la base de datos** de manera persistente.

Es conceptualmente, una **tabla dentro de una tabla**, pero Oracle la implementa como:

1. Una **columna** de tipo colección declarada como `NESTED TABLE`.
2. Una **tabla física de almacenamiento** donde realmente se guardan los elementos.


<br/><br/>

### Características clave de una tabla anidada

| Característica        | Descripción                                                         |
| --------------------- | ------------------------------------------------------------------- |
| Tamaño                | Ilimitado, puede crecer sin restricciones.                      |
| Tipo                  | Colección ordenable, pero sin índice numérico fijo como VARRAY. |
| Persistencia          | Se puede almacenar permanentemente en la BD.                        |
| Representación física | Oracle crea una tabla de almacenamiento secundario.             |
| Consultas             | Se consulta usando la función `TABLE()` en SQL.                     |



<br/><br/>

### Tarea 1. Labores de limpieza

Si no existen, saldrán errores ORA-00942 u ORA-04043.
No pasa nada, es normal.
Se agregan por si en la demo necesitamos hacer cambios o repetirla.

```sql
DROP TABLE clientes_nt_demo PURGE;
DROP TYPE phone_list_t;
```

<br/><br/>

### Tarea 2. Crear el tipo de colección (nested table type)

```sql
CREATE TYPE phone_list_t AS TABLE OF VARCHAR2(20);
/
```
<br/>

> La diagonal `/`, le dice al cliente (SQL*PLUS) que ejecute el bloque PL/SQL que acaba de leer en el buffer.
> Los bloques PL/SQL no se ejecutan automáticamente al terminar con `;`.
> La idea de `phone_list_t` es un tipo colección: una **lista de teléfonos** (`TABLE OF VARCHAR2(20)`).

Para verificar:

```sql
desc user_types

SELECT count(*) from user_types;

SELECT type_name, typecode FROM user_types WHERE  type_name = 'PHONE_LIST_T';

```

<br/><br/>

### Tarea 2. Crear la tabla con columna especial (anidada)

```sql
CREATE TABLE clientes_nt_demo (
  id_cliente NUMBER PRIMARY KEY,
  nombre VARCHAR2(50),
  telefonos phone_list_t  
)
NESTED TABLE telefonos
  STORE AS clientes_phones_nt;
```

<br/>

**Conceptos clave:**

* `CLIENTES_NT_DEMO` es una **tabla normal** con 3 columnas.
* `TELEFONOS` es una **columna** cuyo tipo es una **colección** (`phone_list_t`).
* `STORE AS CLIENTES_PHONES_NT` le dice a Oracle que los elementos de la colección se guarden físicamente en la tabla de almacenamiento `CLIENTES_PHONES_NT` (no se consulta directamente).

<br/>

Verifica:

```sql
SELECT table_name, nested FROM user_tables
WHERE table_name IN ('CLIENTES_NT_DEMO', 'CLIENTES_PHONES_NT');
```

<br/><br/>

### Tarea 3. Insertar datos 

```sql
INSERT INTO clientes_nt_demo (id_cliente, nombre, telefonos)
VALUES (1, 'HUGO', phone_list_t('555-1001', '555-1002'));

INSERT INTO clientes_nt_demo (id_cliente, nombre, telefonos)
VALUES (2, 'PACO', phone_list_t('555-2001'));

INSERT INTO clientes_nt_demo (id_cliente, nombre, telefonos)
VALUES (3, 'LUIS', phone_list_t('555-3001', '555-3002', '555-3003'));

COMMIT;
```

Aquí usamos el **constructor** `phone_list_t(...)` para crear la colección por fila.

<br/><br/>

### Tarea 4. Consultas básicas

#### 1. Ver la tabla "padre"

```sql
set linesize 200

col nombre format a15

SELECT id_cliente, nombre FROM clientes_nt_demo ORDER BY id_cliente;

```

#### 2. Ver el contenido de `TELEFONOS` 

```sql
desc clientes_nt_demo 
set linesize 200
col nombre format a15

SELECT id_cliente, nombre, telefonos FROM clientes_nt_demo;
```

Verás que `TELEFONOS` aparece como un tipo colección, no con los valores de la colección

<br/><br/>

### Tarea 5. Explorar la colección con `TABLE(...)`

Esta es la forma “práctica” de ver cada teléfono como fila, con un producto cartesiano.

```sql
set linesize 200
col nombre format a15

SELECT c.id_cliente, c.nombre, t.COLUMN_VALUE AS telefono
FROM clientes_nt_demo c, TABLE(c.telefonos) t
ORDER BY c.id_cliente, telefono;
```

* `TABLE(c.telefonos)` convierte la colección en un conjunto de filas.
* `COLUMN_VALUE` es el nombre por defecto de la columna que guarda cada teléfono.
* Internamente, Oracle usa `CLIENTES_PHONES_NT`, pero no se trabaja con ella directamente.

<br/><br/>

### Tarea 6. Ver la relación en el diccionario

#### 1. Relación entre "tabla padre" <-> "tabla de almacenamiento"

```sql
set linesize 200
col table_name format a15
col parent_table_name format a15
col parent_table_column format a15

SELECT table_name, parent_table_name, parent_table_column
FROM   user_nested_tables
WHERE  parent_table_name = 'CLIENTES_NT_DEMO';
```


> **Nota:** 

* `TABLE_NAME`         -> `CLIENTES_PHONES_NT`
* `PARENT_TABLE_NAME`  -> `CLIENTES_NT_DEMO`
* `PARENT_TABLE_COLUMN`-> `TELEFONOS`

<br/><br/>

#### 2. Columnas de la tabla de almacenamiento (`USER_NESTED_TABLE_COLS`)

```sql
set linesize 200
col table_name format a15
col column_name format a20
col data_type format a10


SELECT table_name, column_name, data_type, data_length, nullable, internal_column_id, qualified_col_name
FROM   user_nested_table_cols
WHERE  table_name = 'CLIENTES_PHONES_NT'
ORDER BY internal_column_id;

```

> Veremos algo como:

* `COLUMN_NAME = COLUMN_VALUE`
* `DATA_TYPE = VARCHAR2`
* `DATA_LENGTH = 20`

Es decir: cada elemento de la colección es un `VARCHAR2(20)` almacenado en `COLUMN_VALUE`.

<br/><br/>

### Tarea 7. Agregar un teléfono nuevo a Luis

Supón que quieres agregar a LUIS (`id_cliente = 3`) el teléfono `555-3004`.

```sql
UPDATE clientes_nt_demo c
SET    c.telefonos =
       c.telefonos MULTISET UNION phone_list_t('555-3004')
WHERE  c.id_cliente = 3;

COMMIT;
```

> **Nota:** `MULTISET UNION` combina la colección actual con otra colección (`phone_list_t('555-3004')`).

Verifica:

```sql
set linesize 200
col id_cliente format a15
col nombre format a15
col telefono a15

SELECT c.id_cliente, c.nombre, t.COLUMN_VALUE AS telefono
FROM   clientes_nt_demo c, TABLE(c.telefonos) t
ORDER BY c.id_cliente, telefono;
```

<br/><br/>

### Tarea 8. Eliminar teléfonos de la colección

Aquí vienen los dos escenarios importantes.

#### 1. Eliminar uno o varios teléfonos por **valor** (`MULTISET EXCEPT`)

Borrar el teléfono `555-3002` de LUIS.

```sql
UPDATE clientes_nt_demo c
SET    c.telefonos = c.telefonos MULTISET EXCEPT phone_list_t('555-3002')
WHERE  c.id_cliente = 3;

COMMIT;
```

> **Nota**: `MULTISET EXCEPT` hace: **colección_nueva = colección_actual – { '555-3002' }**

Revisar:

```sql
SELECT c.id_cliente, c.nombre, t.COLUMN_VALUE AS telefono
FROM clientes_nt_demo c, TABLE(c.telefonos) t
WHERE  c.id_cliente = 3
ORDER BY telefono;
```

<br/><br/>

### 2. Eliminar usando un **filtro complejo** (CAST + MULTISET + SELECT)

Borrar todos los teléfonos de LUIS que comiencen con `555-30`.

> Nota: este es el patrón importante a enseñar:
> **`CAST(MULTISET(SELECT …) AS tipo_colección)`**

```sql
UPDATE clientes_nt_demo c
SET    c.telefonos =
         CAST(
           MULTISET(
             SELECT COLUMN_VALUE
             FROM TABLE(c.telefonos)
             WHERE COLUMN_VALUE NOT LIKE '555-30%'
           ) AS phone_list_t
         )
WHERE  c.id_cliente = 3;

COMMIT;
```

> **Nota:**

1. `TABLE(c.telefonos)` explota la colección en filas.
2. `WHERE COLUMN_VALUE NOT LIKE '555-30%'` define qué teléfonos **se conservan**.
3. `MULTISET(SELECT ...)` empaqueta el resultado del `SELECT` como colección.
4. `CAST(... AS phone_list_t)` lo convierte exactamente al tipo de la columna.
5. El `UPDATE` asigna esta nueva colección (ya filtrada) a `c.telefonos`.

Verificar:

```sql
SELECT c.id_cliente, c.nombre, t.COLUMN_VALUE AS telefono
FROM clientes_nt_demo c, TABLE(c.telefonos) t
WHERE c.id_cliente = 3
ORDER BY telefono;
```

<br/><br/>

### Tarea 9. Limpieza final

Cuando termines la demo elimina las tablas que no necesitas más adelante, la máquina de curso tienen recursos limitados:

```sql
DROP TABLE clientes_nt_demo PURGE;
DROP TYPE phone_list_t;

SELECT original_name, object_name, type, droptime FROM recyclebin;
PURGE RECYCLEBIN;

-- De toda la base
-- PURGE DBA_RECYCLEBIN;

```

