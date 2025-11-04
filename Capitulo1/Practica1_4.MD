# **Práctica 1.4 Agregación y Operadores de Conjuntos**

<br/><br/>

## **Objetivos**

* Usar funciones de grupo (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) para resumir datos.
* Aplicar `GROUP BY` y `HAVING` para generar y filtrar agrupaciones.
* Comprender el uso y las implicaciones de `DISTINCT` y `ALL` en funciones y consultas.
* Seleccionar correctamente entre los operadores de conjunto `UNION`, `UNION ALL`, `INTERSECT` y `MINUS`.
* Interpretar y prevenir el error `ORA-00979: not a GROUP BY expression`.

<br/><br/>

## **Duración estimada**

**70 minutos**

<br/><br/>

## **Tabla de Ayuda**

| Concepto / Función                              | Descripción breve                                         | Referencia oficial                                                                                  |
| ----------------------------------------------- | --------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `COUNT(*)`, `COUNT(col)`, `COUNT(DISTINCT col)` | Cuenta filas totales, valores no nulos o valores únicos.  | [COUNT Function](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/COUNT.html)    |
| `GROUP BY`                                      | Agrupa los resultados según una o más columnas.           | [GROUP BY Clause](https://docs.oracle.com/javadb/10.8.3.0/ref/rrefsqlj32654.html)  |
| `HAVING`                                        | Filtra grupos resultantes de una agregación.              | [HAVING Clause](https://docs.oracle.com/javadb/10.10.1.2/ref/rrefsqlj14854.html)    |
| `DISTINCT` / `ALL`                              | Controla duplicados en funciones o resultados combinados. | [DISTINCT Keyword](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/SELECT.html) |
| `UNION`, `UNION ALL`, `INTERSECT`, `MINUS`      | Combinan resultados de dos o más consultas.               | [Set Operators](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/The-UNION-ALL-INTERSECT-MINUS-Operators.html)   |
| `ORA-00979`                                     | Error al seleccionar columnas no agrupadas ni agregadas.  | [ORA-00979 Error](https://docs.oracle.com/en/error-help/db/ora-00979/?r=26ai)  |

<br/><br/>

## **Instrucciones**

<br/><br/>

### **Tarea 1. Funciones de grupo básicas**

1. Conéctate al esquema `HR`.
2. Ejecuta la siguiente consulta para agrupar por departamento:

   ```sql
   SELECT department_id, COUNT(*) AS empleados, AVG(salary) AS promedio_salario
   FROM employees
   GROUP BY department_id
   ORDER BY department_id;
   ```
3. Agrega una condición `HAVING AVG(salary) > 7000` y observa qué departamentos cumplen el criterio.

<br/><br/>

### **Tarea 2. Contando valores únicos y nulos**

1. Ejecuta las siguientes sentencias y analiza las diferencias:

   ```sql
   SELECT COUNT(*) AS total_empleados FROM employees;
   SELECT COUNT(commission_pct) AS con_comision FROM employees;
   SELECT COUNT(DISTINCT job_id) AS puestos_unicos FROM employees;
   ```
2. Reflexiona: ¿qué efecto tiene `DISTINCT` y cuándo puede cambiar el resultado?

<br/><br/>

### **Tarea 3. Corrigiendo ORA-00979**

1. Ejecuta:

   ```sql
   SELECT department_id, salary
   FROM employees
   GROUP BY department_id;
   ```
2. Anota el error que Oracle devuelve.
3. Corrige la consulta utilizando una función de grupo (`MIN`, `MAX`, `AVG`, etc.).

<br/><br/>

### **Tarea 4. DISTINCT y concatenaciones**

1. Ejecuta:

   ```sql
   SELECT COUNT(DISTINCT (first_name || ' ' || last_name)) AS nombres_unicos
   FROM employees;
   ```
2. Explica qué sucede si algunos empleados tienen el mismo nombre y apellido.
3. Verifica si la expresión puede devolver valores `NULL`.

<br/><br/>

### **Tarea 5. Operadores de conjunto: UNION vs UNION ALL**

1. Obtén todos los `job_id` del departamento 50 o del 80, sin duplicados:

   ```sql
   SELECT job_id FROM employees WHERE department_id = 50
   UNION
   SELECT job_id FROM employees WHERE department_id = 80;
   ```
2. Repite la consulta con `UNION ALL` y compara el número de filas.
3. Explica cuál operador elimina duplicados y cuál no.

<br/><br/>

### **Tarea 6. INTERSECT y MINUS**

1. Identifica los puestos (`job_id`) que existen en ambos departamentos 50 y 80:

   ```sql
   SELECT job_id FROM employees WHERE department_id = 50
   INTERSECT
   SELECT job_id FROM employees WHERE department_id = 80;
   ```
2. Identifica los puestos del 50 que **no** aparecen en el 80:

   ```sql
   SELECT job_id FROM employees WHERE department_id = 50
   MINUS
   SELECT job_id FROM employees WHERE department_id = 80;
   ```

<br/><br/>

### **Tarea 7. Precedencia de operadores**

1. Ejecuta y analiza:

   ```sql
   SELECT job_id FROM employees WHERE department_id = 50
   UNION
   SELECT job_id FROM employees WHERE department_id = 80
   INTERSECT
   SELECT job_id FROM employees WHERE department_id = 90;
   ```
2. Determina qué se ejecuta primero (`INTERSECT` tiene mayor precedencia).
3. Reescribe la consulta usando paréntesis para alterar el orden lógico.

<br/><br/>

### **Tarea 8. Desafíos**

Responde a los siguientes **10 enunciados** escribiendo la sentencia SQL correcta sobre el esquema **HR**.
Cada uno tiene una única respuesta que requiere aplicar correctamente **funciones de grupo**, **cláusulas de agregación** o **set operators**.

1. Muestra el salario promedio por departamento, excluyendo aquellos con menos de 5 empleados.
2. Calcula el número total de puestos distintos (`job_id`) existentes en la empresa.
3. Obtén los departamentos cuyo salario máximo sea mayor que 12000.
4. Muestra la cantidad de empleados por `job_id`, ordenando de mayor a menor.
5. Devuelve todos los `job_id` presentes en los departamentos 50 o 60 (sin duplicados).
6. Devuelve todos los `job_id` presentes en los departamentos 50 o 60, incluyendo duplicados.
7. Encuentra los `job_id` que existen en ambos departamentos 80 y 90.
8. Encuentra los `job_id` que existen en el 80 pero no en el 90.
9. Calcula cuántos empleados no tienen comisión (`commission_pct`) nula.
10. Muestra los departamentos cuyo salario promedio supere el salario promedio global.


<br/><br/>

## **Resultado Esperado**

El participante demuestra dominio en:

* Agrupación y filtrado con `GROUP BY` y `HAVING`.
* Uso adecuado de `DISTINCT` y `ALL` en agregaciones y operadores de conjunto.
* Comprensión de la precedencia entre operadores (`INTERSECT` > `UNION`/`MINUS`).
* Corrección de errores comunes como `ORA-00979`.
* Capacidad de aplicar estos conceptos en consultas de nivel de certificación Oracle SQL (1Z0-082).


La captura muestra correctamente el resultado esperado: una consulta con operadores de conjunto (INTERSECT) que devuelve un solo registro del departamento 80, con 34 empleados y un salario promedio de 8955.88235, evidenciando dominio de agrupaciones, HAVING, y precedencia entre operadores.


![Resultado Esperado](../images/p1-4.png)