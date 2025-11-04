# **Práctica 5.4 Eliminación de Tablespaces**

## **Objetivos**

1. Identificar los efectos de eliminar un tablespace y su contenido.
2. Ejecutar correctamente la instrucción `DROP TABLESPACE` con las opciones adecuadas.
3. Verificar la eliminación de los datafiles físicos asociados al tablespace.
4. Comprobar el impacto de la eliminación en las vistas del diccionario de datos (`DBA_TABLESPACES`, `DBA_DATA_FILES`).
5. Aplicar buenas prácticas antes de eliminar objetos de almacenamiento en Oracle.

<br/><br/>

## **Duración estimada**

25 minutos

<br/><br/>

## **Tabla de ayuda**

| Comando / Vista      | Descripción                                              | Ejemplo                                                      |
| -------------------- | -------------------------------------------------------- | ------------------------------------------------------------ |
| `DROP TABLESPACE`    | Elimina un tablespace del diccionario de datos.          | `DROP TABLESPACE users INCLUDING CONTENTS;`                  |
| `INCLUDING CONTENTS` | Elimina todos los objetos dentro del tablespace.         | —                                                            |
| `AND DATAFILES`      | Elimina físicamente los datafiles del sistema operativo. | `DROP TABLESPACE ts_sales INCLUDING CONTENTS AND DATAFILES;` |
| `DBA_TABLESPACES`    | Muestra todos los tablespaces existentes.                | `SELECT tablespace_name FROM dba_tablespaces;`               |
| `DBA_DATA_FILES`     | Lista los datafiles asociados a cada tablespace.         | `SELECT file_name FROM dba_data_files;`                      |
| `V$TABLESPACE`       | Muestra tablespaces activos en la instancia.             | `SELECT * FROM v$tablespace;`                                |

 



<br/><br/>

## **Instrucciones**

### **Tarea 1. Conexión al entorno**

1. Inicia sesión en Oracle como usuario con privilegios de administrador:

   ```bash
   sqlplus / as sysdba
   ```
2. Verifica el usuario actual:

   ```sql
   SHOW USER;
   ```

<br/><br/>

### **Tarea 2. Identificar tablespaces previos**

1. Lista todos los tablespaces creados en prácticas anteriores:

   ```sql
   SELECT tablespace_name FROM dba_tablespaces;
   ```
2. Localiza los datafiles asociados:

   ```sql
   SELECT file_name, tablespace_name FROM dba_data_files;
   ```

<br/><br/>

### **Tarea 3. Eliminar tablespaces con objetos**

1. Ejecuta el comando de eliminación para cada tablespace personalizado (por ejemplo, `TS_CLIENTES`, `TS_VENTAS`):

   ```sql
   DROP TABLESPACE ts_clientes INCLUDING CONTENTS;
   ```
2. Si deseas eliminar también los archivos físicos:

   ```sql
   DROP TABLESPACE ts_clientes INCLUDING CONTENTS AND DATAFILES;
   ```

<br/><br/>

### **Tarea 4. Verificar la eliminación**

1. Revisa nuevamente las vistas:

   ```sql
   SELECT tablespace_name FROM dba_tablespaces;
   ```
2. Confirma que los datafiles correspondientes fueron eliminados del sistema operativo (ruta dentro de `ORACLE_BASE/oradata/`).

<br/><br/>

### **Tarea 5. Limpieza y validación final**

1. Comprueba que ningún usuario o segmento esté apuntando al tablespace eliminado:

   ```sql
   SELECT username, default_tablespace FROM dba_users;
   ```
2. Ajusta los usuarios que quedaron con un tablespace eliminado, asignándoles otro válido si es necesario:

   ```sql
   ALTER USER hr DEFAULT TABLESPACE users;
   ```

<br/><br/>

### **Tarea 6. Desafío**

Diseña un script SQL que elimine **todos los tablespaces de prácticas anteriores**, incluyendo sus contenidos y datafiles, pero **preservando los tablespaces del sistema** (`SYSTEM`, `SYSAUX`, `UNDOTBS1`, `TEMP`, `USERS`).
Tu script debe:

* Identificar automáticamente los tablespaces no esenciales.
* Eliminar cada uno con `INCLUDING CONTENTS AND DATAFILES`.
* Verificar el resultado mostrando los tablespaces restantes.

<br/><br/>

## **Resultado Esperado**

El participante habrá eliminado correctamente los tablespaces de prácticas previas y validado su ausencia tanto en las vistas del diccionario de datos como en el sistema operativo.
La ejecución del comando `SELECT tablespace_name FROM dba_tablespaces;` solo deberá mostrar los tablespaces base del sistema:

```
SYSTEM
SYSAUX
UNDOTBS1
TEMP
USERS
```

Además, los archivos físicos asociados a los tablespaces eliminados ya no estarán presentes en la carpeta `oradata/`.
