
# POC: Inicio y fin de una transacción con DML + DDL en Oracle

<br/><br/>

## Objetivo

Demostrar que **el DDL fuerza commits automáticos**, y por lo tanto rompe el control manual de transacciones.

<br/><br/>

## Descripción

Usaremos dos acciones:

1. **Hacer un DML sin commit**
2. **Ejecutar un DDL**
3. Verificar que el DML **quedó confirmado automáticamente**, aunque nunca se hizo `COMMIT` explicito.


## Instrucciones

### Preparación

#### 1. Limpiar si ya existe

```sql
DROP TABLE demo_tx PURGE;
```

#### 2. Crear tabla para el ejemplo:

```sql
CREATE TABLE demo_tx (
    id NUMBER,
    nombre VARCHAR2(50)
);
```

### Inicia la transacción (DML sin commit)

```sql
INSERT INTO demo_tx VALUES (1, 'Primero');
INSERT INTO demo_tx VALUES (2, 'Segundo');
```

> **Nota Importante:**
No hagas `COMMIT` ni `ROLLBACK`.


<br/><br/>

### Verifica que están en buffer (sí se ven en tu sesión, incluso abre otra sesión y verifica que no puedes ver la tabla)

```sql
SELECT * FROM demo_tx;
```

<br/><br/>

### Ejecuta un DDL (este tipo de instrucción provoca commit implícito)

```sql
CREATE TABLE otra_tabla (x NUMBER);
```

> Aquí Oracle ejecuta:

* **Commit antes del DDL**
* **Commit después del DDL**

<br/><br/>

### Verifica que los datos fueron confirmados(comitados)

Abre **otra sesión** o conecta como otro usuario:

```sql
SELECT * FROM demo_tx;
```

> Verás los registros aunque **nunca ejecutaste COMMIT**.

<br/><br/>

### Demuestra que ya no puedes hacer rollback

En la sesión original:

```sql
ROLLBACK;
```

Ahora:

```sql
SELECT * FROM demo_tx;
```

> Los registros siguen ahí ya **no** se pueden revertir.

<br/><br/>

## Resultado Semántico
 

| Operación      | Commit implícito | Explicación                          |
| -------------- | ---------------- | ------------------------------------ |
| CREATE TABLE   | Sí               | El DDL genera commit antes y después |
| ALTER TABLE    | Sí               | También genera commit implícito      |
| DROP TABLE     | Sí               | Igual: DDL → commit automático       |
| TRUNCATE TABLE | Sí               | DDL, auto-commit                     |
| GRANT/REVOKE   | Sí               | Considerados DDL → commit            |

<br/><br/>
 

## Qué demuestra este Demo o POC

1. Un DDL **cierra cualquier transacción pendiente** → `COMMIT BEFORE`.
2. Luego ejecuta el DDL.
3. Después realiza un **COMMIT AFTER**.
4. El usuario **no puede hacer rollback** a ningún cambio previo.


