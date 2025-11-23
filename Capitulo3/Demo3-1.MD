
# Demo 3.1

<br/><br/>
## ¿Cómo ver en vivo los mensajes en el alert log cuando se hace ALTER DATABASE MOUNT?

<br/><br/>

### **1. Identifica la ruta del alert log**

En Oracle 12c en adelante (incluye 19c), el alert log está en ADWR:

```sql
SHOW PARAMETER diagnostic_dest;
```

Con eso vas a:

```
$DIAG/diag/rdbms/<DB_NAME>/<ORACLE_SID>/trace/alert_<ORACLE_SID>.log
```

Ejemplo típico en Linux:

```
/u01/app/oracle/diag/rdbms/orcl/orcl/trace/alert_orcl.log
```

<br/><br/>

### **2. Visualiza el alert log mientras ejecutas las órdenes**

En Linux:

```bash
tail -f alert_orcl.log
```

Esto permite **ver la llegada de mensajes en tiempo real**, justo cuando ejecutas:

```sql
STARTUP NOMOUNT;
ALTER DATABASE MOUNT;
ALTER DATABASE OPEN;
```

<br/><br/>

### **3. ¿Qué verán exactamente al hacer ALTER DATABASE MOUNT?**

Cuando ejecutas:

```sql
ALTER DATABASE MOUNT;
SELECT status FROM v$instance;
SELECT open_mode FROM v$database;
```

<br/>

Verán líneas como:

```
ALTER DATABASE MOUNT
Successful mount of redo thread 1
Database mounted in Exclusive Mode
Control file sequential read
Opening controlfile...
Completed: ALTER DATABASE MOUNT
```

<br/>

¿Qué demostramos con esto?

* Oracle **leyó los archivos de control**.
* Oracle verificó **la estructura física de la BD** (datafiles, redo logs).
* **Aún NO abrió datafiles** ni redo logs (eso ocurre en OPEN).
* Todo quedó **registrado** en alert log.

<br/><br/>

### **4. También podemos leer desde SQL**

Oracle tiene la vista:

```sql
SELECT message_text, ORIGINATING_TIMESTAMP
FROM v$diag_alert_ext
WHERE component_id = 'rdbms'
ORDER BY originating_timestamp DESC;
```

O ver solo las últimas 20 líneas:

```sql
SELECT *
FROM v$diag_alert_ext
WHERE originating_timestamp > SYSDATE - (1/24/60*5); -- últimos 5 minutos
```

Ventaja:
✔ No necesitan entrar al SO
✔ Funciona igual en Windows y Linux

<br/><br/>

### **5. ¿Qué verán exactamente al hacer ALTER DATABASE OPEN?**

```sql
ALTER DATABASE OPEN;
SELECT status FROM v$instance;
SELECT open_mode FROM v$database;
```
<br/><br/>

Cómo identificar NOMOUNT, MOUNT y OPEN

#### **NOMOUNT**

* `V$INSTANCE.STATUS = 'STARTED'`
* `V$DATABASE` dará error (porque no leyó control files aún)

#### **MOUNT**

* `V$INSTANCE.STATUS = 'MOUNTED'`
* `V$DATABASE.OPEN_MODE = 'MOUNTED'`

#### **OPEN**

* `V$INSTANCE.STATUS = 'OPEN'`
* `V$DATABASE.OPEN_MODE = 'READ WRITE'` (o `READ ONLY`)

<br/><br/>


##  Resumen 
Para saber exactamente qué está haciendo Oracle cuando pasas de NOMOUNT a MOUNT, lo más confiable es revisar el alert log. 
Aquí es donde Oracle registra cada cambio de estado de la instancia y cada lectura de control files, datafiles y redo logs.
