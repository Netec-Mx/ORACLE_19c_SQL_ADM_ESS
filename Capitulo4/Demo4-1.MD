 

# Demo 4.1 Grant/Revoke 

<br/><br/>

### 1. Limpieza previa (como SYS)

Conéctate como SYS u otro usuario con permisos de administración:

```sql
CONNECT sys/Oracle1 AS SYSDBA;
```

Primero eliminamos, si existen, los usuarios de pruebas (ignorar el error si no existen):

```sql
DROP USER grt CASCADE;
DROP USER u1  CASCADE;
```

Si te sale algo como `ORA-01918: user 'GRT' does not exist`, simplemente lo ignoras.

<br/><br/>

### 2. Preparación del escenario (como SYS)

Creamos de nuevo los usuarios desde cero:

```sql
-- Crear usuario GRT
CREATE USER grt IDENTIFIED BY grt
  DEFAULT TABLESPACE users
  TEMPORARY TABLESPACE temp
  QUOTA 10M ON users;

-- Darle CREATE SESSION con ADMIN OPTION a GRT (solo a GRT)
GRANT CREATE SESSION TO grt WITH ADMIN OPTION;

-- Crear otro usuario  U1 (para probar GRANT/REVOKE desde GRT)
CREATE USER u1 IDENTIFIED BY u1
  DEFAULT TABLESPACE users
  TEMPORARY TABLESPACE temp
  QUOTA 10M ON users;
```


Verificar el privilegio de `grt`, como DBA:

```sql
conn sys/Oracle1 as sysdba

set linesize 200
col grantee format a20

SELECT grantee, privilege, admin_option
FROM   dba_sys_privs
WHERE  grantee in ('GRT', 'U1', 'HR');
```

Deberías ver: `CREATE SESSION` con `ADMIN_OPTION = YES`, para el usuario 'GRT'

<br/><br/>

### 3. GRT puede iniciar sesión (CREATE SESSION)

Como `grt`:

```sql
CONNECT grt/grt;

SELECT user FROM dual;
```

<br/><br/>

### 4. GRT puede otorgar CREATE SESSION con ADMIN OPTION

Sigue conectado como `grt`:

```sql

conn u1/u1

conn grt/grt

GRANT CREATE SESSION TO u1 WITH ADMIN OPTION;

conn u1/u1

```

Verifícalo como SYS:

```sql
CONNECT sys/Oracle1 AS SYSDBA;

set linesize 200
col grantee format a20

SELECT grantee, privilege, admin_option
FROM   dba_sys_privs
WHERE  grantee in ('GRT', 'U1', 'HR');
```


<br/><br/>

### 5. GRT puede revocar CREATE SESSION de otros usuarios

Como `grt`:

```sql
CONNECT grt/grt;

REVOKE CREATE SESSION FROM u1;
```

Verifica de nuevo como SYS:

```sql
CONNECT sys/Oracle1 AS SYSDBA;

set linesize 200
col grantee format a20

SELECT grantee, privilege, admin_option
FROM   dba_sys_privs
WHERE  grantee in ('GRT', 'U1', 'HR');
```

<br/><br/>


### 6. Intento de que GRT se revoque CREATE SESSION a sí mismo

Vuelve a conectarte como `grt`:

```sql
CONNECT grt/grt;

REVOKE CREATE SESSION FROM grt;

CONNECT sys/Oracle1 AS SYSDBA;

set linesize 200
col grantee format a20

SELECT grantee, privilege, admin_option
FROM   dba_sys_privs
WHERE  grantee in ('GRT', 'U1', 'HR');

```

<br/><br/>

### 7. ¿GRT puede ejecutar DDL en su esquema?

GRT solo tiene `CREATE SESSION` (no se le ha otorgado `CREATE TABLE`). Probamos:

```sql
CONNECT grt/grt;

CREATE TABLE prueba_grt (
  id NUMBER
);
```

> **Nota:** ORA-01031: insufficient privileges



<br/><br/>


### 8. GRT puede ejecutar DML en su propio esquema

Primero, como SYS, creamos una tabla propiedad de `grt` (sin darle `CREATE TABLE` a `grt`):

```sql
CONNECT sys/Oracle1 AS SYSDBA;

CREATE TABLE grt.demo_tab (
  id          NUMBER,
  descripcion VARCHAR2(100)
);
```

Ahora prueba DML como `grt`:

```sql
CONNECT grt/grt;

-- INSERT
INSERT INTO demo_tab (id, descripcion)
VALUES (1, 'Primer registro de GRT');

COMMIT;

-- SELECT
SELECT * FROM demo_tab;

-- UPDATE
UPDATE demo_tab
SET descripcion = 'Actualizado por GRT'
WHERE id = 1;

COMMIT;

-- DELETE
DELETE FROM demo_tab
WHERE id = 1;

COMMIT;
```

> **Nota:** Todo esto debe funcionar, sin ningún `GRANT SELECT/INSERT/UPDATE/DELETE` explícito, porque `GRT` es el **owner** de la tabla.

