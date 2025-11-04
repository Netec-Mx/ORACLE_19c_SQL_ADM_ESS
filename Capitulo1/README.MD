# **Capítulo 1.** Fundamentos de SQL en Oracle Database

## **[Práctica 1.1 Acceso al Entorno de Curso](Practica1_1.MD)**

Comprobar el acceso y funcionamiento del entorno asignado para el curso, validando el inicio de sesión, la apertura de terminal, los permisos de usuario y las características básicas del sistema operativo Oracle Linux.

<br/><br/>

## **[Práctica 1.2 SQL Básicos](Practica1_2.MD)**

En esta práctica se ejecutarán consultas SQL básicas sobre el esquema HR. El participante aprenderá a aplicar filtros y operadores lógicos, utilizar variables de sustitución (`&` y `&&`) y manejar correctamente los valores `NULL` dentro de las consultas, comprendiendo su impacto en los resultados.

<br/><br/>

## **[Práctica 1.3 Funciones de una sola fila, Fechas y Conversión](Practica1_3.MD)**

Durante esta práctica se trabajará con funciones de una sola fila, incluyendo funciones de carácter, número y fecha. El participante aplicará funciones de conversión (`TO_CHAR`, `TO_DATE`, `TO_NUMBER`) con *format models*, utilizará funciones para el manejo de valores nulos (`NVL`, `NVL2`, `NULLIF`, `COALESCE`), y comprenderá cómo anidar funciones manteniendo el tipo de dato resultante. Además, realizará operaciones aritméticas con fechas y usará funciones de calendario (`ADD_MONTHS`, `NEXT_DAY`) considerando el parámetro regional (`NLS_TERRITORY`) y las diferencias entre los formatos `YY` y `RR`.

<br/><br/>

## **[Práctica 1.4 Agregación y Operadores de Conjuntos](Practica1_4.MD)**

En esta práctica se aplicarán funciones de grupo y operadores de conjunto utilizando el esquema HR. El participante ejecutará consultas que incluyan `GROUP BY` y `HAVING`, comparará los resultados entre `UNION`, `UNION ALL`, `INTERSECT` y `MINUS`, y aprenderá a evitar errores comunes de agrupamiento (`ORA-00979`) eligiendo el operador o función más adecuada según el caso.

<br/><br/>

## **[Práctica 1.5 Joins en Oracle SQL](Practica1_5.MD)**

Esta práctica se enfoca en el uso de diferentes tipos de `JOIN` para combinar datos de múltiples tablas dentro del esquema HR. El participante construirá consultas utilizando `NATURAL JOIN`, `USING`, `ON`, así como equijoins, outer joins (`LEFT`, `RIGHT`, `FULL`), el producto cartesiano y el **self join** con uso obligatorio de alias, comprendiendo cuándo y cómo aplicar cada uno según la relación entre las tablas.

<br/><br/>

## **[Práctica 1.6 Subqueries](Practica1_6.MD)**

A lo largo de esta práctica se desarrollarán consultas SQL que incorporen subconsultas básicas y correlacionadas. El participante aplicará los predicados `IN`, `EXISTS`, `ANY` y `ALL`, analizará el comportamiento de las subconsultas en distintos contextos y aprenderá a interpretar correctamente su semántica y cardinalidad para optimizar el resultado de las consultas.
 