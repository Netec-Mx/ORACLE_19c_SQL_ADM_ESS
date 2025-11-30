# Demo 5.1 Creación y validación de un tablespace de 32K

<br/><br/>

## Objetivo

* Crear un tablespace con tamaño de bloque **no estándar** (32K).
* Validar, mediante experimentos reales, qué requisitos son verdaderos y cuáles son falsos.
* Comprobar efectos en OS, SGA y filesystem.


<br/><br/>

### Tarea 1. Labores de limpieza inicial

Esta tarea garantiza que no haya objetos previos que interfieran.

#### 1. Borrar tablespace previo si existe

```sql
DROP TABLESPACE ns_tbs INCLUDING CONTENTS AND DATAFILES;
DROP TABLESPACE ns_tbs_test INCLUDING CONTENTS AND DATAFILES;
```

> **Nota:** Ignora si tienes el siguiente mensaje:
ORA-00959: tablespace does not exist


#### 2. Borrar directorios previos en OS (solo si deseas limpiar)

Ejecutar como usuario `oracle` o `root` según permisos.

```bash
rm -f /u02/Oracle/data/ns_tbs_f01.bdf
rm -f /u02/oradata/ns_tbs_test01.bdf
```

#### 3. Verificar espacio actual en /u02

```bash
df -h /u02
```

> **Nota:** Intentaremos crear un TB de 100G, o más grande del espacio que tengas libres deberás de ver un mensaje de error.


<br/><br/>

### Tarea 2. Verificar configuración inicial

#### 1. Ver tamaño de bloque estándar

```sql
conn / as sysdba

SHOW PARAMETER db_block_size;
```

Veras el valor:

```
db_block_size = 8192   -- 8K
```

#### 2. Ver caches no estándar

```sql
SELECT name, value FROM   v$parameter  WHERE  name LIKE 'db_%k_cache_size';
```

Veras que todos tienen el tamaño cero, andes de configurar 

```
db_32k_cache_size = 0  
```

<br/><br/>

### Tarea 3. Intentar crear el tablespace SIN db_32k_cache_size

#### 1. Intento fallido

```sql
CREATE TABLESPACE ns_tbs_test
  DATAFILE '/u02/oradata/ns_tbs_test01.bdf'
  SIZE 100G
  BLOCKSIZE 32K;
```

#### 2. Error esperado

```
ORA-29339: datafile block size 32768 does not match any cache
```

<br/><br/>

### Tarea 4. Configurar db_32k_cache_size

El valor de  `db_cache_size = 16M`, vamos a usar un valor pequeño, solo 4M, para demostrar que no necesita ser "mayor o menor".


#### 1. Configurar

```sql
ALTER SYSTEM SET db_32k_cache_size=4M SCOPE=SPFILE;
```

#### 2. Reiniciar instancia

```sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

#### 3. Verificar

```sql
SHOW PARAMETER db_cache_size;
SHOW PARAMETER db_32k_cache_size;
```

La salida deberá ser igual a lo siguiente:

```
db_cache_size     = 16M
db_32k_cache_size = 4M
```

<br/><br/>


### Tarea 5. Verificar block size del sistema operativo

#### 1. Obtener tamaño de bloque de /u02

```bash
stat -f /u02
```

> **Nota:** Busca el mensaje de "Bloque Fundamental"
Sistema operativo = **4K**, Oracle tablespace = **32K** → sin conflicto.

<br/><br/>

### Tarea 6. Crear ahora sí el tablespace con BLOCKSIZE 32K

Verifica el tamaño, si no puedes crear uno de 100G, puesde usar algo más pequeño, por ejemplo **10M** por seguridad  

```sql
CREATE TABLESPACE ns_tbs_test
  DATAFILE '/u02/oradata/ns_tbs_test01.bdf'
  SIZE 10M
  BLOCKSIZE 32K;
```

#### 1. Validación

```sql
SELECT tablespace_name, block_size FROM dba_tablespaces
WHERE  tablespace_name = 'NS_TBS_TEST';

SELECT file_name, bytes/1024/1024 AS mb FROM dba_data_files
WHERE  tablespace_name = 'NS_TBS_TEST';
```

> **Nota:** 
* `BLOCK_SIZE = 32768`
* Tamaño ≈ 10M




