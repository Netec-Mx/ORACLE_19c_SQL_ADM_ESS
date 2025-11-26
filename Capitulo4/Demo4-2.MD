
# Demo 4.2 Análisis de Privilegios con DBMS_PRIVILEGE_CAPTURE

<br/><br/>

## Objetivo

Identificar privilegios USADOS y NO USADOS de un rol fuerte para aplicar el principio de Least Privilege.


<br/><br/>

### Tarea 1. Crear el rol y el usuario de prueba

```sql
conn / as sysdba

-- 1. Crear rol con privilegios “excesivos”

CREATE ROLE rl_app_full;

GRANT SELECT ANY TABLE TO rl_app_full;
GRANT UPDATE ANY TABLE TO rl_app_full;
GRANT CREATE VIEW     TO rl_app_full;

-- 2. Crear usuario de pruebas GRT

CREATE USER grt IDENTIFIED BY grt
  DEFAULT TABLESPACE users
  TEMPORARY TABLESPACE temp
  QUOTA 10M ON users;

GRANT CREATE SESSION TO grt;
GRANT rl_app_full     TO grt;

-- 3. Verificación 

SET LINESIZE 200
COLUMN username FORMAT A15
COLUMN account_status FORMAT A20

SELECT username, account_status
FROM   dba_users
WHERE  username = 'GRT';

COLUMN role FORMAT A20

SELECT role
FROM   dba_roles
WHERE  role = 'RL_APP_FULL';

```

<br/><br/>


### Tarea 2. Crear la política de Privilege Analysis por rol

```sql

-- 1. Crear la política CAP_APP_ROLE (tipo G_ROLE sobre RL_APP_FULL)

BEGIN
  DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE(
    name        => 'CAP_APP_ROLE',
    description => 'Captura de privilegios usados por rol de prueba',
    type        => DBMS_PRIVILEGE_CAPTURE.G_ROLE,
    roles       => ROLE_NAME_LIST('RL_APP_FULL')
  );
END;
/

-- 2. Verificar la política en DBA_PRIV_CAPTURES

COLUMN name FORMAT A15
COLUMN type FORMAT A16
COLUMN enabled FORMAT A1
COLUMN description FORMAT A40

SELECT name, type, enabled, description
FROM   dba_priv_captures
WHERE  name = 'CAP_APP_ROLE';  -- Nombre usado en CREATE_CAPTURE
```

<br/><br/>


### Tarea 3. Habilitar la captura

```sql

BEGIN
  DBMS_PRIVILEGE_CAPTURE.ENABLE_CAPTURE('CAP_APP_ROLE');
END;
/


SELECT name, enabled
FROM   dba_priv_captures
WHERE  name = 'CAP_APP_ROLE';

-- Esperamos: ENABLED = 'Y'
```

<br/><br/>


### Tarea 4. Ejecutar acciones como el usuario GRT


```sql

  conn grt/grt
--
-- Usar SELECT ANY TABLE (ajusta esquema/tabla si no tienes HR)
--     Ejemplo con HR.EMPLOYEES:

SELECT COUNT(*) FROM hr.employees;

--
-- Usar UPDATE ANY TABLE (con ROLLBACK para no afectar datos)

UPDATE hr.employees
         SET salary = salary
         WHERE employee_id = 100;

ROLLBACK;

```

<br/><br/>

### Tarea 5. Detener la captura y generar resultados

```sql
-- Regresa a la sesión como SYS

conn / as sysdba

-- 1. Deshabilitar la captura

BEGIN
  DBMS_PRIVILEGE_CAPTURE.DISABLE_CAPTURE('CAP_APP_ROLE');
END;
/

SELECT name, enabled
FROM   dba_priv_captures
WHERE  name = 'CAP_APP_ROLE';

-- Esperado: ENABLED = 'N'

-- 2 Generar los resultados de la captura

BEGIN
  DBMS_PRIVILEGE_CAPTURE.GENERATE_RESULT('CAP_APP_ROLE');
END;
/

```

<br/><br/>


### Tarea 6. Consultar los privilegios USADOS (DBA_USED_PRIVS)


```sql
SET LINESIZE 200
COLUMN username  FORMAT A15
COLUMN privilege FORMAT A30
COLUMN used_role FORMAT A20
COLUMN path FORMAT A60

SELECT username,
       COALESCE(sys_priv, obj_priv, user_priv) AS privilege,
       used_role,
       path
FROM   dba_used_privs
WHERE  capture = 'CAP_APP_ROLE'
ORDER BY username, privilege;
```

> **Nota:**
   - USERNAME  : quién usó el privilegio (GRT).
   - PRIVILEGE : qué privilegio se usó (SELECT ANY TABLE, UPDATE ANY TABLE, etc.).
   - USED_ROLE : desde qué rol vino el privilegio (RL_APP_FULL).
   - PATH      : ruta de grant (GRANT_PATH('GRT','RL_APP_FULL'), etc.).  

<br/><br/>


### Tarea 8. Consultar los privilegios NO USADOS (DBA_UNUSED_PRIVS)

```sql

COLUMN privilege FORMAT A30

SELECT username,
       COALESCE(sys_priv, obj_priv, user_priv) AS privilege,
       object_owner,
       object_name,
       path
FROM   dba_unused_privs
WHERE  capture = 'CAP_APP_ROLE'
ORDER BY username, privilege;
```

> **Nota:** Los privilegios que nunca se usan son candidatos a ser revocados para acercarnos al principio de #Least Privilege".



<br/><br/>


### Tarea 8. Limpieza de la práctica (dejar el entorno como estaba)

```sql

-- 1. Eliminar la política de captura
BEGIN
  DBMS_PRIVILEGE_CAPTURE.DROP_CAPTURE('CAP_APP_ROLE');
END;
/

-- 2. Eliminar el usuario de pruebas
DROP USER grt CASCADE;

-- 3. Eliminar el rol de pruebas
DROP ROLE rl_app_full;

-- 4. Verificación de limpieza

SELECT username FROM dba_users WHERE username = 'GRT';

SELECT role FROM dba_roles WHERE role = 'RL_APP_FULL';

SELECT name FROM dba_priv_captures WHERE name = 'CAP_APP_ROLE';

```

