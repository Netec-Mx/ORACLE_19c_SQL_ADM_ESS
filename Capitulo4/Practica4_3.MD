# **Práctica 4.3 Gestión de usuarios, roles y cuotas (Oracle 19c)**

## **Objetivos**

* Crear usuarios con y sin especificar *default* y *temporary tablespace*.
* Consultar y entender `DBA_USERS`, `DBA_TS_QUOTAS`, `DBA_ROLE_PRIVS`, `ROLE_SYS_PRIVS`, `DBA_SYS_PRIVS`.
* Crear roles y otorgar privilegios de sistema mínimos necesarios.
* Asignar cuotas a tablespaces y validar su efecto en la creación de objetos.
* Diagnosticar y resolver errores de privilegios y cuotas frecuentemente encontrados por DBAs junior.

## **Duración estimada**

60 – 75 minutos

## **Tabla de ayuda**

| Concepto                | Vista/Comando                            | Ejemplo mínimo                                                                         | Nota clave                                          |
| ----------------------- | ---------------------------------------- | -------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Crear usuario           | `CREATE USER`                            | `CREATE USER usuario1 IDENTIFIED BY usuario1;`                                         | Si no se indica TS, hereda los *defaults* de la BD. |
| Alterar usuario         | `ALTER USER`                             | `ALTER USER usuario1 DEFAULT TABLESPACE tb_usuarios TEMPORARY TABLESPACE tb_temporal;` | No cambia cuotas.                                   |
| Cuotas                  | `ALTER USER ... QUOTA` / `DBA_TS_QUOTAS` | `ALTER USER usuario1 QUOTA UNLIMITED ON tb_usuarios;`                                  | Sin cuota → ORA-01950 al crear objetos.             |
| Conexión                | `CREATE SESSION`                         | `GRANT CREATE SESSION TO usuario1;`                                                    | Suele darse vía un rol.                             |
| Crear rol               | `CREATE ROLE` / `GRANT ... TO rol`       | `CREATE ROLE desarrollo; GRANT CREATE TABLE, CREATE VIEW TO desarrollo;`               | Asignar luego el rol al usuario.                    |
| Privilegios del rol     | `ROLE_SYS_PRIVS`                         | `SELECT * FROM ROLE_SYS_PRIVS WHERE ROLE='DESARROLLO';`                                | Verificar lo otorgado al rol.                       |
| Privilegios del usuario | `DBA_ROLE_PRIVS`, `DBA_SYS_PRIVS`        | `SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE='USUARIO1';`                               | Verificar lo efectivo.                              |
| Usuarios                | `DBA_USERS`                              | `SELECT USERNAME, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE FROM DBA_USERS;`            | Confirmar TS por defecto.                           |
| Errores                 | `oerr`                                   | `$ oerr ora 01950`                                                                     | Muestra causa y acción sugerida.                    |

<br/><br/>

## **Instrucciones**

### **Tarea 1. Acceso y preparación**

1. Conéctate como DBA:

   ```sql
   sqlplus / as sysdba
   ```
2. (Opcional) Ajusta formato:

   ```sql
   SET PAGES 200 LINES 200 TRIMSPOOL ON
   ```

<br/><br/>

### **Tarea 2. Crear USUARIO1 sin tablespaces explícitos y verificar**

1. Crea el usuario sin TS por defecto ni temporal (heredará los de la BD):

   ```sql
   CREATE USER usuario1 IDENTIFIED BY usuario1;
   ```
2. Consulta usuarios y cuotas:

   ```sql
   SELECT SUBSTR(username,1,15) usuario, default_tablespace, temporary_tablespace
   FROM dba_users
   WHERE username IN ('SYS','SYSTEM','GABRIEL','USUARIO1');

   SELECT SUBSTR(username,1,15) usuario, tablespace_name, bytes, max_bytes
   FROM dba_ts_quotas
   WHERE username IN ('SYS','SYSTEM','GABRIEL','USUARIO1');
   ```
3. **Pregunta de verificación:** ¿Qué ocurre con USUARIO1 respecto a creación de objetos? (Anticípate: carece de privilegios y de cuota).


<br/><br/>

### **Tarea 3. Crear USUARIO2 con TS explícitos**

1. Crea `USUARIO2` asignando *default* y *temp*:

   ```sql
   CREATE USER usuario2 IDENTIFIED BY usuario2
     DEFAULT TABLESPACE tb_usuarios
     TEMPORARY TABLESPACE tb_temporal;
   ```
2. Verifica en `DBA_USERS` y `DBA_TS_QUOTAS`.


<br/><br/>

### **Tarea 4. Ajustar TS de USUARIO1**

1. Cambia TS de `USUARIO1`:

   ```sql
   ALTER USER usuario1 DEFAULT TABLESPACE tb_usuarios;
   ALTER USER usuario1 TEMPORARY TABLESPACE tb_temporal;
   ```
2. Revisa nuevamente `DBA_USERS`.


<br/><br/>

### **Tarea 5. Rol de conexión y asignaciones**

1. Crea rol y otorga privilegio de conexión al rol:

   ```sql
   CREATE ROLE conexion;
   GRANT CREATE SESSION TO conexion;
   ```
2. Asigna el rol a ambos usuarios:

   ```sql
   GRANT conexion TO usuario1, usuario2;
   ```
3. Verifica roles:

   ```sql
   SELECT grantee, granted_role
   FROM dba_role_privs
   WHERE grantee IN ('USUARIO1','USUARIO2','GABRIEL');
   ```


<br/><br/>

### **Tarea 6. Intento de creación de tabla y diagnóstico (USUARIO2)**

1. Conéctate como `USUARIO2`:

   ```sql
   CONNECT usuario2/usuario2
   ```
2. Intenta crear la tabla:

   ```sql
   CREATE TABLE mensajes (codigo VARCHAR2(3), descripcion VARCHAR2(20))
   TABLESPACE tb_usuarios
   STORAGE (INITIAL 64K NEXT 64K MINEXTENTS 5 MAXEXTENTS 10);
   ```
3. **Registra el error esperado:** ORA-01031 (falta `CREATE TABLE`) o ORA-01950 (falta cuota), según tu entorno.


<br/><br/>

### **Tarea 7. Rol de desarrollo con privilegios de sistema**

1. Vuelve a SYS/SYSTEM y crea un rol con privilegios para desarrollo:

   ```sql
   CONNECT / AS SYSDBA
   CREATE ROLE desarrollo;
   GRANT CREATE SEQUENCE, CREATE SESSION, CREATE TABLE, CREATE VIEW TO desarrollo;
   GRANT desarrollo TO usuario1, usuario2;
   ```
2. Verifica privilegios del rol:

   ```sql
   SELECT role, privilege FROM role_sys_privs WHERE role='DESARROLLO';
   ```


<br/><br/>

### **Tarea 8. Reintento y resolución de cuotas**

1. Conéctate como `USUARIO1` e intenta nuevamente crear la tabla:

   ```sql
   CONNECT usuario1/usuario1
   CREATE TABLE mensajes (codigo VARCHAR2(3), descripcion VARCHAR2(20))
   TABLESPACE tb_usuarios
   STORAGE (INITIAL 64K NEXT 64K MINEXTENTS 5 MAXEXTENTS 10);
   ```
2. Si obtienes **ORA-01950**, vuelve a SYS/SYSTEM y asigna cuota:

   ```sql
   CONNECT / AS SYSDBA
   ALTER USER usuario1 QUOTA UNLIMITED ON tb_usuarios;
   -- (Opcional) cuota limitada para usuario2:
   -- ALTER USER usuario2 QUOTA 100M ON tb_usuarios;
   ```
3. Reintenta la creación como `USUARIO1` y confirma.


<br/><br/>

### **Tarea 9. Auditoría rápida de privilegios, roles y cuotas**

1. Ejecuta los reportes:

   ```sql
   SELECT grantee, granted_role FROM dba_role_privs
   WHERE grantee IN ('USUARIO1','USUARIO2','GABRIEL')
   ORDER BY grantee, granted_role;

   SELECT username, privilege FROM dba_sys_privs
   WHERE username IN ('USUARIO1','USUARIO2','GABRIEL')
   ORDER BY username, privilege;

   SELECT username, tablespace_name, bytes, max_bytes
   FROM dba_ts_quotas
   WHERE username IN ('USUARIO1','USUARIO2','GABRIEL')
   ORDER BY username, tablespace_name;
   ```


<br/><br/>

### **Tarea 10. Desafío**

**Diseña un esquema mínimo de permisos “solo lectura + vistas” sin dar privilegios amplios:**

1. Crea el rol `reportes` y asígnale **solo** `CREATE VIEW`.
2. Otorga a `reportes` privilegios de **objeto** (no de sistema) para consultar tablas del esquema `HR` necesarias para un reporte (por ejemplo, `HR.EMPLOYEES`, `HR.DEPARTMENTS`), usando `GRANT SELECT ON HR.<tabla> TO reportes;`.
3. Asigna `reportes` a `USUARIO2`.
4. Conéctate como `USUARIO2` y crea una vista `v_emps_dept` que muestre `employee_id`, `last_name`, `department_name`.
5. **Restricción:** No uses `SELECT ANY TABLE` ni otorgues privilegios al *PUBLIC*.
6. Muestra el *plan de verificación* (consultas a `USER_VIEWS`, `SESSION_ROLES`) y una *captura* de `SELECT * FROM v_emps_dept FETCH FIRST 5 ROWS ONLY;`.


<br/><br/>

## **Resultado Esperado**

* `USUARIO1` y `USUARIO2` pueden conectarse (poseen `CONEXION` → `CREATE SESSION`).
* `USUARIO1` crea correctamente `MENSAJES` en `TB_USUARIOS` tras asignarle **cuota** (se resolvió ORA-01950).
* Se evidencian y explican errores típicos:

  * **ORA-01031: insufficient privileges** → faltaba `CREATE TABLE` (resuelto vía rol `desarrollo`).
  * **ORA-01950: no privileges on tablespace** → faltaba cuota en `TB_USUARIOS`.
* Consultas a `DBA_USERS`, `DBA_TS_QUOTAS`, `DBA_ROLE_PRIVS`, `DBA_SYS_PRIVS` y `ROLE_SYS_PRIVS` muestran el estado final coherente.
* En el **Desafío**, `USUARIO2` crea una vista basada en HR usando solo privilegios de **objeto** otorgados al rol `reportes` (sin privilegios globales), y demuestra acceso correcto a través de `SESSION_ROLES` y `USER_VIEWS`.


<br/><br/>

**Notas rápidas para copiar/pegar (resumen de comandos clave):**

```sql
-- Crear usuarios
CREATE USER usuario1 IDENTIFIED BY usuario1;
CREATE USER usuario2 IDENTIFIED BY usuario2 DEFAULT TABLESPACE tb_usuarios TEMPORARY TABLESPACE tb_temporal;

-- Ajustes de usuario
ALTER USER usuario1 DEFAULT TABLESPACE tb_usuarios;
ALTER USER usuario1 TEMPORARY TABLESPACE tb_temporal;

-- Roles y privilegios
CREATE ROLE conexion;
GRANT CREATE SESSION TO conexion;
GRANT conexion TO usuario1, usuario2;

CREATE ROLE desarrollo;
GRANT CREATE SEQUENCE, CREATE SESSION, CREATE TABLE, CREATE VIEW TO desarrollo;
GRANT desarrollo TO usuario1, usuario2;

-- Cuotas
ALTER USER usuario1 QUOTA UNLIMITED ON tb_usuarios;

-- Prueba de creación
CONNECT usuario1/usuario1
CREATE TABLE mensajes (codigo VARCHAR2(3), descripcion VARCHAR2(20))
TABLESPACE tb_usuarios STORAGE (INITIAL 64K NEXT 64K MINEXTENTS 5 MAXEXTENTS 10);

-- Reportes/Desafío
CREATE ROLE reportes;
GRANT CREATE VIEW TO reportes;
GRANT SELECT ON hr.employees TO reportes;
GRANT SELECT ON hr.departments TO reportes;
GRANT reportes TO usuario2;

CONNECT usuario2/usuario2
CREATE OR REPLACE VIEW v_emps_dept AS
SELECT e.employee_id, e.last_name, d.department_name
FROM hr.employees e JOIN hr.departments d ON d.department_id = e.department_id;
```
