# **Práctica 6.2 Creación de un nuevo LISTENER**

## **Objetivos**

* Comprender el rol y funcionamiento del **listener** dentro de la arquitectura de red de Oracle.
* Crear un nuevo listener mediante la herramienta **netmgr**.
* Configurar los parámetros de conexión básicos (protocolo, host y puerto).
* Guardar y verificar los cambios en los archivos **listener.ora** y **tnsnames.ora**.
* Iniciar y validar el estado del listener recién creado.

<br/><br/>

## **Duración estimada**

25 minutos

<br/><br/>

## **Tabla de ayuda**

| Elemento / Comando                  | Descripción breve                                 | Ubicación o uso                       |
| ----------------------------------- | ------------------------------------------------- | ------------------------------------- |
| `listener.ora`                      | Archivo de configuración del listener             | `$ORACLE_HOME/network/admin/`         |
| `tnsnames.ora`                      | Archivo con alias de conexión                     | `$ORACLE_HOME/network/admin/`         |
| `$ netmgr`                          | Abre Oracle Net Manager para configuración de red | Desde terminal                        |
| `$ lsnrctl start <nombre>`          | Inicia un listener específico                     | Ejemplo: `lsnrctl start LISTENERPRA`  |
| `$ lsnrctl status <nombre>`         | Muestra el estado de un listener                  | Ejemplo: `lsnrctl status LISTENERPRA` |
| `$ . oraenv`                        | Define las variables de entorno de Oracle         | `ORACLE_SID=orcl`                     |
| `File → Save Network Configuration` | Guarda los cambios en netmgr                      | En la interfaz gráfica                |

<br/><br/>

## **Objetivo visual**

El siguiente diagrama muestra la relación entre el cliente Oracle y el nuevo listener configurado:

![LISTENERPRA](../images/p6-2.png)

<br/><br/>

## **Instrucciones**

### **Tarea 1: Configurar entorno**

1. Define las variables de entorno de Oracle:

   ```bash
   $ . oraenv
   orcl
   ```
2. Verifica que tu entorno apunta correctamente a la base de datos `orcl`.

<br/><br/>

### **Tarea 2: Crear el nuevo listener**

1. Ejecuta la herramienta **Oracle Net Manager**:

   ```bash
   $ netmgr
   ```
2. En el árbol de navegación, selecciona **Listeners**.
3. Haz clic en el símbolo **+ (verde)** para agregar un nuevo listener.
4. Asigna el nombre **LISTENERPRA**.
5. En la sección **Protocol Addresses**, selecciona **TCP/IP**.
6. Especifica los siguientes valores:

   * **Host:** `localhost`
   * **Port:** `1551`
7. Guarda los cambios desde el menú **File → Save Network Configuration**.

<br/><br/>

### **Tarea 3: Validar la configuración**

1. Desde la terminal, revisa el contenido de los archivos actualizados:

   ```bash
   $ more $ORACLE_HOME/network/admin/listener.ora
   $ more $ORACLE_HOME/network/admin/tnsnames.ora
   ```
2. Inicia el nuevo listener:

   ```bash
   $ lsnrctl start LISTENERPRA
   ```
3. Verifica su estado:

   ```bash
   $ lsnrctl status LISTENERPRA
   ```
4. Comprueba que esté escuchando en el puerto **1551** y asociado a la base de datos **orcl**.

<br/><br/>

### **Tarea 4. Desafío**

Crea un **segundo listener** llamado `LISTENERLAB` que escuche en el puerto **1560**.
Inícialo y comprueba su estado.
Luego, identifica y explica las diferencias entre `LISTENERPRA` y `LISTENERLAB` observando el contenido de sus archivos de configuración.

<br/><br/>

## **Resultado Esperado**

* Listener `LISTENERPRA` creado correctamente con protocolo **TCP/IP**, host `localhost` y puerto `1551`.
* Archivos `listener.ora` y `tnsnames.ora` actualizados y guardados sin errores.
* El comando `lsnrctl status LISTENERPRA` muestra el listener en estado **READY** y asociado al servicio **orcl**.



```
LSNRCTL for Linux: Version 19.0.0.0.0
Status of the listener:
------------------------
Alias                     LISTENERPRA
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=localhost)(PORT=1551)))
Services Summary...
  Service "orcl" has 1 instance(s).
  Instance "orcl", status READY, has 1 handler(s) for this service...
The command completed successfully
```
