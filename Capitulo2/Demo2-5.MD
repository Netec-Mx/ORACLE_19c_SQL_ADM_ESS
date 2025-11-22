# Demo tipos de constraints (PK, UK, FK, CHECK, NOT NULL)

<br/><br/>

## Objetivos

* Mostrar con ejemplos de INSERT/UPDATE qué garantiza cada constraint:

  * UNIQUE (correo sin duplicados)
  * FOREIGN KEY (dept_id debe existir en la tabla padre)
  * CHECK (salary > 0)
  * NOT NULL (hire_date obligatorio)
  * PK (id único y no nulo)


<br/><br/>

## Tabla de ayuda - Constraints

| **Constraint**         | **Descripción**                                     | **Comentario**                               |
| ----------------------------- | ------------------------------------------------------- | --------------------------------------------------------------- |
| **PRIMARY KEY (PK)**          | Valor único y no nulo. Identifica filas.                | employee_id no se puede repetir ni quedar NULL.               |
| **UNIQUE (UK)**               | No permite valores duplicados (sí permite varios NULL). | Dos emails iguales → error; NULL no cuenta como duplicado.    |
| **FOREIGN KEY (FK)**          | El valor debe existir en la tabla padre.                | Solo puedes asignar departamentos que existan en MY_DEPARTMENTS.   |
| **CHECK (salary > 0)**        | Valida una condición lógica.                            | Salarios ≤ 0 no pasan; NULL sí, porque no viola la condición. |
| **NOT NULL**                  | El valor es obligatorio.                                | hire_date no puede quedar vacío.                              |


<br/><br/>

## Instrucciones

### 1. Para no depender del esquema HR, crea una mini tabla `MY_DEPARTMENTS` local:

```sql
DROP TABLE my_employees PURGE;
DROP TABLE my_departments PURGE;

CREATE TABLE my_departments (
  department_id   NUMBER CONSTRAINT dept_pk PRIMARY KEY,
  department_name VARCHAR2(50)
);

INSERT INTO my_departments VALUES (10, 'HR');
INSERT INTO my_departments VALUES (20, 'IT');
COMMIT;
```

<br/><br/>

### 2. Ahora la tabla `my_employees` del enunciado:

```sql
CREATE TABLE my_employees (
  employee_id   NUMBER CONSTRAINT emp_pk       PRIMARY KEY,
  email         VARCHAR2(50) CONSTRAINT emp_email_unk UNIQUE,
  department_id NUMBER       CONSTRAINT emp_dept_fok REFERENCES my_departments(department_id),
  hire_date     DATE         CONSTRAINT emp_hire_nn NOT NULL,
  salary        NUMBER       CONSTRAINT emp_sal_ck CHECK (salary > 0)
);
```

<br/><br/>

### 3. Comprueba las constraints:

```sql
SELECT constraint_name, constraint_type, status
FROM user_constraints
WHERE table_name IN ('MY_EMPLOYEES','MY_DEPARTMENTS')
ORDER BY table_name, constraint_type;
```

<br/><br/>

### 4.  UNIQUE en `email` (EMP_EMAIL_UK)

```sql
-- Inserción válida
INSERT INTO my_employees (employee_id, email, department_id, hire_date, salary)
VALUES (1, 'greta@example.com', 10, DATE '2024-01-01', 1000);

-- Intento de duplicar email
INSERT INTO my_employees (employee_id, email, department_id, hire_date, salary)
VALUES (2, 'greta@example.com', 10, DATE '2024-02-01', 1200);
```

> **Nota:** Aquí debe aparecer un error tipo **ORA-00001: unique constraint (EMP_EMAIL_UK) violated**.
“The EMP_EMAIL_UK constraint ensures that no two my_employees can have the same email address.”  

<br/><br/>

### 5. Probar también que **UNIQUE permite varios NULL**:

```sql
INSERT INTO my_employees (employee_id, email, department_id, hire_date, salary)
VALUES (3, NULL, 10, DATE '2024-03-01', 1500);

INSERT INTO my_employees (employee_id, email, department_id, hire_date, salary)
VALUES (4, NULL, 20, DATE '2024-04-01', 1600);

SELECT * FROM my_employees;
```

<br/><br/>


### 6. FOREIGN KEY en `department_id` (EMP_DEPT_FK)

```sql
-- Inserción con depto válido
INSERT INTO my_employees (employee_id, email, department_id, hire_date, salary)
VALUES (5, 'carlos@example.com', 10, DATE '2024-05-01', 2000);

-- Inserción con depto inexistente
INSERT INTO my_employees (employee_id, email, department_id, hire_date, salary)
VALUES (6, 'laura@example.com', 99, DATE '2024-06-01', 2500);
```


> **Nota:** El segundo INSERT debe dar **ORA-02291: integrity constraint (EMP_DEPT_FK) violated - parent key not found**.
> La FK **no** asegura que el `department_id` exista en `MY_EMPLOYEES`. 
> La FK **sí** asegura que exista en la tabla padre `MY_DEPARTMENTS`.


<br/><br/>

### 7. CHECK en `salary` (EMP_SAL_CK)

```sql
-- Válido (salario > 0)
INSERT INTO my_employees (employee_id, email, department_id, hire_date, salary)
VALUES (7, 'maria@example.com', 20, DATE '2024-07-01', 1);

-- Inválido (salario <= 0)
INSERT INTO my_employees (employee_id, email, department_id, hire_date, salary)
VALUES (8, 'pepe@example.com', 20, DATE '2024-08-01', 0);
```


> El segundo INSERT debe dar error por la constraint `EMP_SAL_CK`.
> La restricción `CHECK` **no bloquea NULL**; `salary` podría ser NULL si no hay NOT NULL explícito.

<br/><br/>

### 8. NOT NULL en `hire_date` (EMP_HIRE_NN)

```sql
-- Inválido: hire_date NULL
INSERT INTO my_employees (employee_id, email, department_id, hire_date, salary)
VALUES (9, 'juan@example.com', 20, NULL, 3000);
```

> Esto debe dar **ORA-01400: cannot insert NULL into ("MY_EMPLOYEES"."HIRE_DATE")**.

<br/><br/>

### 9. PK en `employee_id` (EMP_PK)

```sql
-- PK ya usamos employee_id = 1 antes, volvemos a intentar 1
INSERT INTO my_employees (employee_id, email, department_id, hire_date, salary)
VALUES (1, 'otro@example.com', 10, DATE '2024-09-01', 4000);
```

> Debe dar **ORA-00001** por duplicar la PK.

<br/><br/>

## **Quiz — Constraints en Oracle**

### **1) ¿Qué ocurre si intentas insertar dos empleados con el mismo valor en la columna `email`, que tiene constraint UNIQUE?**

A. Ambos registros se insertan sin problema.
B. Solo se inserta el primero; el segundo genera error.
C. Ambos se insertan, pero Oracle muestra una advertencia.
D. Oracle convierte automáticamente el segundo email para que sea único.

<br/><br/>

### **2) ¿Qué garantiza la FOREIGN KEY `emp_dept_fk` sobre la columna `department_id`en la tabla MY_EMPLOYEES ?**

A. Que el valor exista en la tabla MY_EMPLOYEES.
B. Que el valor exista en la tabla MY_DEPARTMENTS.
C. Que el valor no pueda ser NULL.
D. Que todos los empleados pertenezcan al mismo departamento.

<br/><br/>

### **3) Con la constraint `CHECK (salary > 0)`, ¿cuál de las siguientes afirmaciones es verdadera?**

A. Permite salary = 0.
B. Permite salary < 0.
C. Permite salary NULL.
D. Solo permite salary mayores o iguales a 0.

<br/><br/>

### **4) ¿Qué sucede si intentas insertar un registro con `hire_date = NULL`, estando definida la constraint `NOT NULL`?**

A. Oracle inserta el registro y convierte NULL en SYSDATE.
B. Oracle rechaza el registro con ORA-01400.
C. Oracle inserta el registro porque `hire_date` no tiene default.
D. Oracle convierte NULL a un valor vacío pero válido.

<br/><br/>

### **5) La constraint PRIMARY KEY en `employee_id` garantiza que…**

A. Se permiten valores duplicados, pero no NULL.
B. Se permiten NULL, pero no duplicados.
C. No se permiten duplicados ni NULL.
D. Solo valida duplicados, no NULL.


<br/><br/>

## Respuestas

ᗺ ᗺ Ɔ ᗺ Ɔ
