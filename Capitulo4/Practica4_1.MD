
# **Práctica 4.1 Creación de Usuarios**

<br/><br/>

## **Objetivos**

* Crear un nuevo usuario utilizando SQL*Plus.
* Consultar las vistas del diccionario relacionadas con usuarios, roles y privilegios.
* Otorgar privilegios de sistema necesarios para permitir el acceso del usuario.
* Verificar la asignación de privilegios y cuotas en el sistema.
* Comprobar la autenticación y conexión del usuario recién creado.

<br/><br/>

## **Duración estimada**

30 minutos

<br/><br/>

## **Tabla de ayuda**

| Concepto / Vista | Descripción breve                                    | Comando / Consulta útil                                 |
| ---------------- | ---------------------------------------------------- | ------------------------------------------------------- |
| `DBA_USERS`      | Lista todos los usuarios de la base de datos.        | `SELECT username, account_status FROM dba_users;`       |
| `DBA_PROFILES`   | Muestra los perfiles y límites de recursos.          | `DESC dba_profiles;`                                    |
| `DBA_ROLES`      | Contiene los roles existentes en la base.            | `SELECT role FROM dba_roles;`                           |
| `DBA_ROLE_PRIVS` | Muestra los roles asignados a cada usuario.          | `SELECT * FROM dba_role_privs WHERE grantee='USUARIO';` |
| `DBA_SYS_PRIVS`  | Privilegios de sistema otorgados a usuarios o roles. | `SELECT * FROM dba_sys_privs WHERE grantee='USUARIO';`  |
| `DBA_TAB_PRIVS`  | Privilegios sobre objetos.                           | `SELECT * FROM dba_tab_privs WHERE grantee='USUARIO';`  |
| `CREATE USER`    | Crea un nuevo usuario en Oracle.                     | `CREATE USER nombre IDENTIFIED BY contraseña ...;`      |
| `GRANT`          | Otorga privilegios o roles.                          | `GRANT create session TO usuario;`                      |

<br/><br/>

## **Objetivo visual**

El siguiente diagrama representa la relación entre **usuarios**, **roles**, **privilegios** y **objetos** dentro del esquema de seguridad de Oracle Database:

<br/><br/>

![diagrama1](../images/p4-2.png)

<br/><br/>

## **Instrucciones**

### **Tarea 1. Ingreso al entorno administrativo**

1. Abre una terminal y accede como administrador de base de datos:

   ```bash
   sqlplus / as sysdba
   ```
2. Verifica la conexión:

   ```sql
   SHOW USER;
   ```

<br/><br/>

### **Tarea 2. Exploración de vistas del diccionario**

1. Muestra la estructura de las vistas principales de administración de usuarios:

   ```sql
   DESC dba_profiles;
   DESC dba_roles;
   DESC dba_users;
   DESC dba_role_privs;
   DESC dba_tab_privs;
   DESC dba_sys_privs;
   ```
2. Identifica qué información proporciona cada vista y su utilidad en la administración de seguridad.

<br/><br/>

### **Tarea 3. Creación del usuario**

1. Crea un usuario llamado **GABRIEL** con contraseña **azul1234**, usando el tablespace por defecto y temporal **TEMP**, asignando una cuota de **100K** en el tablespace **USUARIOS**:

   ```sql
   CREATE USER gabriel IDENTIFIED BY azul1234
   DEFAULT TABLESPACE usuarios
   TEMPORARY TABLESPACE temp
   QUOTA 100K ON usuarios;
   ```
2. Verifica su creación:

   ```sql
   SELECT username FROM dba_users WHERE username = 'GABRIEL';
   ```

<br/><br/>

### **Tarea 4. Intento de conexión y diagnóstico**

1. Intenta conectarte con el nuevo usuario:

   ```sql
   CONNECT gabriel/azul1234
   ```
2. Observa el resultado.

   * ¿Pudo conectarse?
   * Si no, ¿qué error se muestra?

<br/><br/>

### **Tarea 5. Asignación de privilegios básicos**

1. Regresa a la sesión de administrador y otorga el privilegio para permitir conexión:

   ```sql
   GRANT CREATE SESSION TO gabriel;
   ```
2. Conéctate nuevamente:

   ```sql
   CONNECT gabriel/azul1234
   SHOW USER;
   ```
3. Confirma que la conexión sea exitosa.

<br/><br/>

### **Tarea 6. Verificación de privilegios asignados**

1. Desde la sesión de administrador, ejecuta las siguientes consultas para comprobar privilegios directos:

   ```sql
   SELECT * FROM dba_sys_privs WHERE grantee = 'GABRIEL';
   SELECT * FROM dba_role_privs WHERE grantee = 'GABRIEL';
   SELECT * FROM dba_tab_privs WHERE grantee = 'GABRIEL';
   ```

<br/><br/>

### **Tarea 7. Exploración de privilegios globales**

Investiga qué usuarios poseen los siguientes privilegios directos:

1. `CREATE USER`

   ```sql
   SELECT grantee FROM dba_sys_privs WHERE privilege = 'CREATE USER';
   ```

2. `CREATE SESSION`

   ```sql
   SELECT grantee FROM dba_sys_privs WHERE privilege = 'CREATE SESSION';
   ```

3. `CREATE ROLE`

   ```sql
   SELECT grantee FROM dba_sys_privs WHERE privilege = 'CREATE ROLE';
   ```

<br/><br/>

### **Tarea 8. Desafío**

Crea un usuario llamado **AUDITOR** con contraseña **audit2024**, asigna una **cuota ilimitada** en el tablespace **USUARIOS**, y otórgale los privilegios necesarios para crear tablas y conectarse al sistema.
Valida la correcta creación, conexión y verificación de privilegios mediante consultas a las vistas `DBA_USERS` y `DBA_SYS_PRIVS`.

<br/><br/>

## **Resultado Esperado**

* Usuario **GABRIEL** creado exitosamente y conectado tras asignar el privilegio `CREATE SESSION`.
* Salida esperada al ejecutar `SHOW USER`:

  ```
  USER is "GABRIEL"
  ```
* Consultas de privilegios retornan registros indicando permisos asignados.
* Usuario **AUDITOR** creado y verificado con privilegios adecuados en el desafío final.

 
