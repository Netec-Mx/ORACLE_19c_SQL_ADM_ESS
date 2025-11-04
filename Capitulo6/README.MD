
# **Capítulo 6.** Conectividad

<br/><br/>

## [**Práctica 6.1 Creación de Network Service**](Practica6_1.MD)

En esta práctica crearás y probarás un **nuevo servicio de red (Network Service)** en Oracle Database utilizando la herramienta **Oracle Net Manager (netmgr)**. Aprenderás a configurar un *Service Naming* que permita establecer conexión a la base de datos local mediante el protocolo **TCP/IP**, validando la comunicación entre cliente y servidor mediante el usuario **HR**.

<br/><br/>

## [**Práctica 6.2 Creación de un nuevo LISTENER**](Practica6_2.MD)

En esta práctica aprenderás a **crear y configurar un nuevo listener en Oracle Database** utilizando la herramienta **Oracle Net Manager (netmgr)**. El listener es el proceso encargado de gestionar las solicitudes de conexión entre los clientes y la base de datos. Configurarás un listener alterno llamado `LISTENERPRA`, especificando protocolo, host y puerto, y validarás su funcionamiento desde la línea de comandos.

<br/><br/>

## [**Práctica 6.3 Uso del Nuevo Listener**](Practica6_3.MD)

En esta práctica aplicarás los conocimientos adquiridos sobre la configuración de listeners en Oracle Database. El objetivo es **asociar la instancia de la base de datos ORCL con el nuevo listener creado previamente (`LISTENERPRA`)**, modificando el parámetro `LOCAL_LISTENER` y verificando la conectividad. Además, dejarás configurado este listener como permanente y probarás su funcionamiento tras reiniciar la base de datos.
