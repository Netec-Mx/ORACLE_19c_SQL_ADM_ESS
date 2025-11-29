
# Demo 4.4 Autenticación OS con `OS_AUTHENT_PREFIX` usando el usuario KING

<br/><br/>

## Descripción

Demostrar cómo Oracle autentica usuarios del sistema operativo según el valor del parámetro `OS_AUTHENT_PREFIX`, probando:

* `OS_AUTHENT_PREFIX = 'OPS$'`
* `OS_AUTHENT_PREFIX = ''` (vacío)

Usando el usuario del sistema operativo:

* king (password: king)

<br/><br/>

## TAREA 1. Labores de limpieza inicial (Oracle + SO)

### 1. Borrar usuarios Oracle previos

En Oracle como SYS:

```sql
DROP USER "OPS$KING" CASCADE;
DROP USER KING CASCADE;
```

Ignorar errores como:

```
ORA-01918: user does not exist
ORA-01917: user or role does not exist
```

<br/><br/>


## TAREA 2. Limpieza SO (si existe el usuario)

En Linux como root:

```bash
userdel -r king
```

<br/><br/>


## TAREA 3. Crear usuario del Sistema Operativo

```bash
useradd king
passwd king   # asignar contraseña: king
```

Verificar:

```bash
id king
```

<br/><br/>


## TAREA 4. Verificar valor actual del parámetro en Oracle

```sql
SHOW PARAMETER os_authent_prefix;
```

Ejemplo de salida inicial:

```
os_authent_prefix = OPS$
```

<br/><br/>


## TAREA 5. Prueba con `OS_AUTHENT_PREFIX = 'OPS$'`

### 1. Crear el usuario externo Oracle

El usuario SO `king` se convierte en Oracle como:

```
OPS$KING
```

Crear usuario externo:

```sql
CREATE USER "OPS$KING" IDENTIFIED EXTERNALLY;
GRANT CREATE SESSION TO "OPS$KING";
```

<br/>

### 2. Conexión desde SO como king

```bash
su - king
sqlplus /
```

Validación:

```sql
SHOW USER;
```

Salida esperada:

```
USER is "OPS$KING"
```

<br/>

### 3. Consultas útiles para el DBA

Ver detalles de autenticación:

```sql
SET LINESIZE 200
SET PAGESIZE 120
COL username FORMAT A15
COL osuser FORMAT A15
COL authentication_type FORMAT A20
COL program FORMAT A30

SELECT DISTINCT
       s.sid,
       s.serial#,
       s.username,
       s.osuser,
       sci.authentication_type,
       s.machine,
       s.program
FROM   v$session s
JOIN   v$session_connect_info sci
       ON s.sid = sci.sid
WHERE  s.username = 'OPS$KING';
```

Ver tipo de autenticación en `DBA_USERS`:

```sql
SELECT username, authentication_type
FROM dba_users
WHERE username = 'OPS$KING';
```

<br/><br/>


## TAREA 6. Cambiar `OS_AUTHENT_PREFIX` a vacío

### 1. Intentos directos (deben marcar error)

```sql
ALTER SYSTEM SET os_authent_prefix='' SCOPE=BOTH;   -- ERROR
ALTER SYSTEM SET os_authent_prefix='';              -- ERROR
```

### 2. Cambio correcto mediante SPFILE

```sql
ALTER SYSTEM SET os_authent_prefix='' SCOPE=SPFILE;
SHUTDOWN IMMEDIATE;
STARTUP;
```

### 3. Validar valor

```sql
SHOW PARAMETER os_authent_prefix;
```

<br/><br/>


## TAREA 7. Ingresar nuevamente como king con prefijo vacío

En SO:

```bash
su - king
sqlplus /
```

> Ahora Oracle buscará un usuario llamado exactamente:

```
KING
```

Si no existe, fallará la autenticación OS (comportamiento esperado).

<br/><br/>

## TAREA 8. Limpieza final (Opcional)

### 1. Borrar usuarios Oracle

```sql
DROP USER "OPS$KING" CASCADE;
DROP USER KING CASCADE;
```

### 2. Borrar usuario SO

```bash
userdel -r king
```

### 3. Verificar que no existan sesiones residuales

```sql
SELECT username
FROM v$session
WHERE username LIKE '%KING%';
```

<br/><br/>


## Resultado esperado

La demo permite observar:

* Autenticación OS funcionando con `OS_AUTHENT_PREFIX='OPS$'`
* Comportamiento cuando `OS_AUTHENT_PREFIX=''`
* Cómo Oracle mapea usuarios SO -> Oracle
* Qué vistas consulta un DBA para auditar sesiones externas (`V$SESSION`, `V$SESSION_CONNECT_INFO`, `DBA_USERS`)
* Validación de sesiones, tipos de autenticación y comportamiento según el parámetro



