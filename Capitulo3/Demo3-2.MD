
# Demo 3.2 - DML y DDL, transacciones implicitamente comitadas

## Objetivo de la demo

Demostrar que **una DDL fallida (CTAS)** **sí provoca el commit** de una transacción previa **debido al COMMIT implícito ANTES** de ejecutar la DDL.

Esto valida la opción:

> **When a CREATE TABLE AS SELECT statement is executed unsuccessfully in the same session.**

<br/><br/>

### Paso 1. Preparación (tabla de prueba)

```sql
DROP TABLE demo_commit PURGE;

CREATE TABLE demo_commit (
    id NUMBER
);

INSERT INTO demo_commit VALUES (1);
COMMIT;
```

Estado inicial confirmado.

<br/><br/>

### Paso 2. Iniciar transacción NO confirmada

```sql
UPDATE demo_commit
SET id = id + 100;
```

>Nota: **NO hacer COMMIT**

En esta sesión:

```sql
SELECT * FROM demo_commit;
```

Resultado:

```
ID
<br/><br/>-
101
```

<br/><br/>

### Paso 3. Ejecutar una DDL FALLIDA (CTAS)

```sql
CREATE TABLE demo_ctas_fail
AS
SELECT * FROM tabla_que_no_existe;
```

Resultado esperado:

```
ORA-00942: table or view does not exist
```

>Nota: El CTAS **falla**.

<br/><br/>

### Paso 4. Verificar si hubo COMMIT

#### En la MISMA sesión:

```sql
SELECT * FROM demo_commit;
```

Resultado:

```
ID
<br/><br/>-
101
```

<br/><br/>

#### En OTRA sesión (nueva conexión):

```sql
SELECT * FROM demo_commit;
```

Resultado:

```
ID
<br/><br/>-
101
```

>Nota:
* **El cambio es visible**
* **La transacción fue confirmada**
* **NO hubo COMMIT explícito del usuario**

<br/><br/>

## Conclusión didáctica para alumnos

> Aunque la sentencia **CREATE TABLE AS SELECT falla**,
> Oracle ejecuta un **COMMIT implícito ANTES de intentar la DDL**,
> por lo tanto **la transacción previa queda confirmada**.

<br/><br/>

### Frase clave para el examen

> **DDL ALWAYS commits BEFORE execution**
> *(even if it fails)*

