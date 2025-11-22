  

# DEMO/POC – Uso de Sinónimos en Oracle (solo HR)

<br/><br/>

## Objetivos

Demostrar el uso de sinónimos

<br/><br/>


## Puntos clave para los sinónimos públicos

1. Se necesitan privilegios: CREATE PUBLIC SYNONYM
2. Se crean con: CREATE PUBLIC SYNONYM nombre FOR esquema.objeto
3. No dan permisos; solo simplifican nombres
4. Son visibles para todos
5. Solo DBA o creador los puede borrar
6. Pueden causar conflicto si un usuario tiene un objeto con el mismo nombre


<br/><br/>

## Puntos clave para los paquetes en Oracle

1. **Un paquete se compone de dos partes:**

   * *Especificación (PACKAGE)*
   * *Cuerpo (PACKAGE BODY)*

2. **La especificación declara la interfaz pública:**

   * Procedimientos
   * Funciones
   * Variables públicas
   * Constantes
   * Tipos

3. **El cuerpo implementa la lógica del código:**

   * Implementa cada procedimiento y función declarados en la especificación
   * Puede contener subprogramas privados no visibles fuera del paquete

4. **La especificación puede existir sin cuerpo**,
   pero **el cuerpo no puede existir sin la especificación**.

5. **Cambios en la especificación invalidan objetos dependientes.**
   Cambios en el cuerpo normalmente no.

6. **Los paquetes permiten encapsular y agrupar lógica relacionada**,
   mejorando organización, mantenimiento y reusabilidad.

7. Se crean usando:

   * `CREATE OR REPLACE PACKAGE ...`
   * `CREATE OR REPLACE PACKAGE BODY ...`



<br/><br/>

## Instrucciones

## 1. Preparación en HR


> Nota: Esta demo se ejecuta **completamente dentro del esquema HR**.

Entrar al esquema HR:

```sql
CONNECT hr/Oracle1
```

Crear una secuencia y un paquete sencillos:

```sql
CREATE SEQUENCE seq_demo_syn START WITH 1;

CREATE OR REPLACE PACKAGE pkg_demo AS
  PROCEDURE saluda;
END pkg_demo;
/

CREATE OR REPLACE PACKAGE BODY pkg_demo AS
  PROCEDURE saluda IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Hola desde pkg_demo.saluda');
  END;
END pkg_demo;
/
```

<br/><br/>

## **2. Crear sinónimos privados en el mismo esquema**

Aunque estemos en HR, los sinónimos funcionan igual.

```sql
CREATE SYNONYM emp_local FOR employees;
CREATE SYNONYM seq_local FOR seq_demo_syn;
CREATE SYNONYM pkg_local FOR pkg_demo;
```

<br/><br/>

## **3. Probar sinónimos privados**

### Tabla:

```sql
SELECT employee_id, last_name
FROM emp_local
FETCH FIRST 3 ROWS ONLY;
```

### Secuencia:

```sql
SELECT seq_local.NEXTVAL FROM dual;
```

### Paquete:

```sql
SET SERVEROUTPUT ON;
BEGIN
  pkg_local.saluda;
END;
/
```

<br/><br/>

## **4. Ver sinónimos creados en el diccionario**

```sql

col object_name forma a20
set linesize 120

SELECT object_name, object_type, object_id
FROM user_objects
WHERE object_type = 'SYNONYM';
```

<br/><br/>

## **5. Sinónimo que apunta a otro sinónimo**

Crear un sinónimo adicional dentro de HR:

```sql
CREATE SYNONYM emp_local_2 FOR emp_local;
```

Probarlo:

```sql
SELECT employee_id, last_name
FROM emp_local_2
FETCH FIRST 3 ROWS ONLY;
```

<br/><br/>

## **6. Sinónimo público (opcional, si el usuario HR tiene privilegios)**

Este paso solo se ejecuta si HR tiene privilegios (`CREATE PUBLIC SYNONYM`).
Si **no tiene**, simplemente se omite en el laboratorio.

```sql
CREATE PUBLIC SYNONYM pub_emp FOR hr.employees;
```

Prueba:

```sql
SELECT employee_id, last_name
FROM pub_emp
FETCH FIRST 3 ROWS ONLY;
```

Intentar eliminarlo (si no se tiene privilegio, fallará):

```sql
DROP PUBLIC SYNONYM pub_emp;
```

<br/><br/>

## **7. Simplificar acceso usando sinónimo local**

Aunque estamos en el mismo esquema, se puede demostrar la simplificación del nombre:

```sql
CREATE SYNONYM emp_simple FOR employees;
```

Probar:

```sql
SELECT COUNT(*)
FROM emp_simple;
```




