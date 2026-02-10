# Demo: Oracle Transaction Control and Constraint Validation 


## DEMO 1 — WITH CHECK OPTION

Objetivo 
* Ver que NO afecta SELECT, solo INSERT / UPDATE

<br/><br/>

### Preparación

```sql

DROP TABLE emp PURGE;

CREATE TABLE emp (
  empno   NUMBER PRIMARY KEY,
  ename   VARCHAR2(20),
  deptno  NUMBER
);

INSERT INTO emp VALUES (1, 'GRETA', 10);
INSERT INTO emp VALUES (2, 'FRANCISCO', 20);
COMMIT;
```

<br/><br/>

### Vista SIN CHECK OPTION

```sql
CREATE OR REPLACE VIEW v_emp_10 AS
SELECT * FROM emp
WHERE deptno = 10;
```

### SELECT

```sql
SELECT * FROM v_emp_10;
```

>Nota: Devuelve solo GRETA

### INSERT (ojo)

```sql
INSERT INTO v_emp_10 VALUES (3, 'CARLA', 20);
COMMIT;
```

>Nota: **INSERT PERMITIDO**, aunque **NO cumple** el WHERE de la vista

<br/><br/>

### Vista CON CHECK OPTION

```sql
CREATE OR REPLACE VIEW v_emp_10 AS
SELECT * FROM emp
WHERE deptno = 10
WITH CHECK OPTION;
```

### INSERT inválido

```sql
INSERT INTO v_emp_10 VALUES (4, 'PEDRO', 20);
```

>Nota: **ERROR ORA-01402**

<br/><br/>

### Conclusión demo 1

> WITH CHECK OPTION **NO cambia SELECT**, **SOLO controla INSERT y UPDATE**

<br/><br/>

## DEMO 2 — DEFERRABLE vs IMMEDIATE

Objetivo
* Ver cuándo Oracle valida constraints

<br/><br/>

### Preparación

```sql
DROP TABLE emp PURGE;
DROP TABLE dept PURGE;

CREATE TABLE dept (
  deptno NUMBER PRIMARY KEY
);

CREATE TABLE emp (
  empno   NUMBER PRIMARY KEY,
  deptno  NUMBER,
  CONSTRAINT emp_fk
    FOREIGN KEY (deptno)
    REFERENCES dept(deptno)
    DEFERRABLE INITIALLY DEFERRED
);
```

<br/><br/>

### Insertar en “orden incorrecto”

```sql
INSERT INTO emp VALUES (1, 50);
INSERT INTO dept VALUES (50);
COMMIT;
```

>Nota: **FUNCIONA**, porque la FK es **DEFERRABLE**.

<br/><br/>

### Ahora IMMEDIATE (default)

```sql
ALTER TABLE emp DROP CONSTRAINT emp_fk;

ALTER TABLE emp ADD CONSTRAINT emp_fk
FOREIGN KEY (deptno)
REFERENCES dept(deptno)
DEFERRABLE INITIALLY IMMEDIATE;
```

```sql
INSERT INTO emp VALUES (2, 60);
```

>Nota: **ERROR inmediato** ORA-02291: integrity constraint violated

<br/><br/>

### Conclusión demo 2

* IMMEDIATE valida **en el statement**
* DEFERRABLE puede validar **al COMMIT**
* NOT NULL **NO puede ser DEFERRABLE**

<br/><br/>

## DEMO 3 — Recuento exacto + Transacciones

Objetivo
* Ver cuándo Oracle crea o NO una transacción

<br/><br/>

### Preparación

```sql
CREATE TABLE t (
  id NUMBER
);
```

<br/><br/>

### SELECT NO inicia transacción

```sql
SELECT * FROM t;

SELECT xid, status FROM v$transaction;
```

> **Sin filas**

<br/><br/>

### DML sí inicia

```sql
INSERT INTO t VALUES (1);

SELECT xid, status FROM v$transaction;
```

>Nota: Aparece un XID

<br/><br/>

### DDL hace COMMIT implícito

```sql
CREATE TABLE t2 AS SELECT * FROM t;
```

```sql
SELECT xid, status FROM v$transaction;
```

>Nota: **Sin filas** (la transacción murió)

<br/><br/>

### Nuevo DML = nuevo XID

```sql
INSERT INTO t VALUES (2);

SELECT xid, status FROM v$transaction;
```

>Nota: **Nuevo XID distinto**

<br/><br/>

### Conclusión demo 3

* SELECT no inicia transacción
* DDL mata la transacción
* El siguiente DML crea un XID nuevo

<br/><br/>



