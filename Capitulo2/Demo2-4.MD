# Efecto de `DISABLE ... CASCADE` sobre PK y FK

<br/><br/>

## Objetivo 

Mostrar en vivo que:

1. Al deshabilitar una **PK con `CASCADE`**, también se deshabilita la **FK** que la referencia.
2. Al volver a habilitar la **PK**, la **FK sigue deshabilitada**.
3. Todas las constraints (si no dices nada) son **NOT DEFERRABLE** y **IMMEDIATE**.


<br/><br/>

## Tabla de ayuda — Constraints Oracle (PK, FK, UK, CK, NN, Disable/Enable)

| **Concepto**                     | **Descripción**                                                                                  | **Ejemplo**                                                                                |
| -------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| **PRIMARY KEY (PK)**             | Garantiza unicidad y no permite NULL. Identifica de forma única cada fila y crea un índice implícito. | `emp_no NUMBER CONSTRAINT emp_pk PRIMARY KEY` → no se permiten duplicados ni valores NULL.        |
| **UNIQUE (UK)**                  | Evita valores duplicados, pero sí permite varios NULL. Garantiza unicidad lógica.                     | `email UNIQUE` → error si dos empleados tienen el mismo email; varios NULL son válidos.           |
| **FOREIGN KEY (FK)**             | Asegura integridad referencial: el valor debe existir en la tabla padre.                              | `dept_id REFERENCES departments(department_id)` → error si el depto no existe.                    |
| **CHECK (CK)**                   | Valida una expresión booleana al momento del DML. Controla rangos y reglas.                           | `CHECK (salary > 0)` → rechaza salarios ≤ 0 (pero NULL es permitido).                             |
| **NOT NULL (NN)**                | Obliga a que la columna tenga valor siempre (nunca NULL).                                             | `hire_date NOT NULL` → ORA-01400 si intentas insertar NULL.                                       |
| **DISABLE CONSTRAINT**           | Desactiva temporalmente la constraint. Permite insertar datos que normalmente violarían reglas.       | `ALTER TABLE emp DISABLE CONSTRAINT emp_pk` → se permiten duplicados mientras está deshabilitada. |
| **DISABLE … CASCADE**            | Al deshabilitar una PK, también deshabilita **todas sus FK dependientes**.                            | `DISABLE emp_pk CASCADE` → también deshabilita `emp_mgr_fk`.                                      |
| **ENABLE CONSTRAINT**            | Reactiva la constraint y valida los datos actuales. No re-activa FKs cascadas automáticamente.        | `ENABLE emp_pk` → PK queda activa e inmediata; la FK sigue deshabilitada.                         |
| **IMMEDIATE** (por defecto)      | La validación ocurre al final de **cada sentencia**. Si hay error, falla enseguida.                   | Violación en un INSERT → ORA-xxxxx sin permitir continuar.                                        |
| **NOT DEFERRABLE** (por defecto) | No se puede diferir la validación. Todas las constraints creadas sin especificar nada son inmediatas. | Todas las PK, FK, UK, CHECK, NN de estos ejemplos son **IMMEDIATE + NOT DEFERRABLE**.             |


<br/><br/>

## Instrucciones


```sql
-- Limpieza previa
DROP TABLE emp PURGE;

-- Crear tabla EMP con PRIMARY KEY
CREATE TABLE emp (
  emp_no   NUMBER(2) CONSTRAINT emp_emp_no_pk PRIMARY KEY,
  ename    VARCHAR2(15),
  salary   NUMBER(9,2),
  mgr_no   NUMBER(2)
);

-- Agregar FOREIGN KEY auto-referenciada
ALTER TABLE emp ADD CONSTRAINT emp_mgr_fk
  FOREIGN KEY (mgr_no)
  REFERENCES emp(emp_no)
  ON DELETE SET NULL;

-- Ver estado inicial de las constraints
SELECT constraint_name, constraint_type, status, deferrable, deferred
FROM user_constraints
WHERE table_name = 'EMP'
ORDER BY constraint_name;
```

> **Nota:**
Al revisar el resultado, observa que `EMP_EMP_NO_PK` aparece como tipo `P` (PRIMARY KEY) con estado `ENABLED`, y `EMP_MGR_FK` aparece como tipo `R` (FOREIGN KEY), también `ENABLED`. Además, ambas muestran `DEFERRABLE = NOT DEFERRABLE` y `DEFERRED = IMMEDIATE`, lo cual confirma que no especificamos ningún comportamiento especial: las constraints se crean así por defecto en Oracle.


```sql
-- Deshabilitar la PK con CASCADE
ALTER TABLE emp DISABLE CONSTRAINT emp_emp_no_pk CASCADE;

-- Consultar de nuevo
SELECT constraint_name, constraint_type, status, deferrable, deferred
FROM user_constraints
WHERE table_name = 'EMP'
ORDER BY constraint_name;
```
 

> **Nota:**
En este punto, tanto la **PK** como la **FK** aparecen con `STATUS = DISABLED`. Es importante recordar que **`CASCADE` implica que al deshabilitar la PK, Oracle también deshabilita automáticamente todas las FKs que dependen de ella**.

<br/><br/>

```sql
-- Volver a habilitar SOLO la PK
ALTER TABLE emp ENABLE CONSTRAINT emp_emp_no_pk;

-- Consultar una vez más
SELECT constraint_name, constraint_type, status, deferrable, deferred
FROM user_constraints
WHERE table_name = 'EMP'
ORDER BY constraint_name;
```

> **Nota:**
Tras reactivar solo la PK, esta aparece nuevamente como `ENABLED`, `NOT DEFERRABLE` e `IMMEDIATE`, mientras que la FK (`EMP_MGR_FK`) permanece `DISABLED`. En otras palabras: **la PK queda habilitada e inmediata y la FK continúa deshabilitada**.


