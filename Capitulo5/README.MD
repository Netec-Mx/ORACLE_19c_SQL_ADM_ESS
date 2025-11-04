
# **Capítulo 5.** Gestión de Almacenamiento

Este capítulo profundiza en la administración física del espacio en Oracle Database 19c. A través de las siguientes prácticas, el participante aprenderá a visualizar, crear, extender y eliminar estructuras de almacenamiento, comprendiendo cómo se gestionan los tablespaces, datafiles y bloques de datos dentro del motor de base de datos.

<br/><br/>

## [**Práctica 5.1 Visualización del Espacio de Almacenamiento**](Practica5_1.MD)

En esta práctica identificarás las **estructuras físicas y lógicas del almacenamiento** en Oracle Database, como tablespaces, datafiles y bloques de datos. Utilizarás vistas del diccionario de datos (`DBA_TABLESPACES`, `DBA_DATA_FILES`, `DBA_SEGMENTS`, entre otras) para **analizar la distribución del espacio**, verificar la **ubicación física de los archivos** y comprender cómo Oracle asigna el almacenamiento a los objetos de usuario.

<br/><br/>

## [**Práctica 5.2 Creación y Gestión de Tablespaces en Oracle 19c**](Practica5_2.MD)

Esta práctica te guiará en la **creación, configuración y administración de tablespaces** en Oracle Database 19c. Configurarás los directorios físicos para los datafiles, crearás tablespaces de distintos tipos (localmente gestionados, temporales y undo), y probarás la **ampliación de espacio** mediante la adición de archivos y la modificación de parámetros de crecimiento automático. También experimentarás con **errores típicos de almacenamiento** (como `ORA-01653`) y sus soluciones.

<br/><br/>

## [**Práctica 5.3 Extensión del Espacio de la Base de Datos**](Practica5_3.MD)

Durante esta práctica aplicarás técnicas para **incrementar la capacidad de almacenamiento** de la base de datos. Aprenderás a **redimensionar datafiles** mediante `ALTER DATABASE DATAFILE RESIZE` y a **agregar nuevos archivos** a un tablespace existente. Se explorarán también los parámetros de **autoextensión (AUTOEXTEND)** y cómo supervisar el crecimiento del espacio utilizado, asegurando un manejo eficiente del almacenamiento físico y lógico.

<br/><br/>

## [**Práctica 5.4 Eliminación de Tablespaces**](Practica5_4.MD)

En esta práctica realizarás la **eliminación controlada de tablespaces** y sus datafiles asociados, garantizando la **liberación segura del espacio en disco**. Analizarás las diferencias entre eliminar un tablespace con o sin sus contenidos (`INCLUDING CONTENTS AND DATAFILES`), y las implicaciones de esta acción sobre el **diccionario de datos**. Finalmente, verificarás la limpieza del entorno y la correcta actualización de las vistas del sistema tras la eliminación.

<br/><br/>

## [**Práctica 5.5 Gestión del Undo Tablespace**](Practica5_5.MD)

En esta práctica aprenderás a **gestionar el espacio de UNDO en Oracle Database**, identificando los parámetros configurados, el tamaño actual del tablespace UNDO y los periodos de mayor actividad. Además, realizarás la **configuración de la retención de UNDO** para permitir operaciones de *Flashback* durante 24 horas.


<br/><br/>

## [**Práctica 5.6 Archivos de Control en Oracle Database**](Practica5_6.MD)

En esta práctica aprenderás a **identificar la función y el contenido del archivo de control (Control File)** en Oracle Database, analizar sus componentes mediante vistas dinámicas, y generar respaldos tanto en formato binario como en texto para fines administrativos y de recuperación del sistema.


<br/><br/>

## [**Práctica 5.7 Redo Logs (Grupos y Miembros)**](Practica5_7.MD)

Identificar, verificar y administrar los **grupos y miembros del Redo Log online** en Oracle 19c, agregando nuevos grupos/miem