
# Demo – Comportamiento de SEQUENCES en Oracle

<br/><br/>

## Objetivos

* Demostrar con POCs reales **qué garantizan y qué NO garantizan** las secuencias en Oracle:

  * Posibilidad de **gaps**
  * Uso de **CYCLE** y reutilización de valores
  * Pérdida de valores **CACHE** al reiniciar la instancia
  * Uso de una secuencia en **múltiples tablas**
  * Comportamiento **no transaccional** (`ROLLBACK` no revierte NEXTVAL)

<br/><br/>

## Tabla de ayuda – Sequences

| **Característica** | **Descripción**                             | **Comentario clave (Examen)**              |
| ------------------ | ------------------------------------------- | ------------------------------------------ |
| Gaps posibles      | Oracle no garantiza continuidad             | “can always have gaps” ≠ “always has gaps” |
| CYCLE              | Reutiliza valores al llegar a MAXVALUE      | Puede emitir duplicados históricos         |
| CACHE              | Valores se guardan en memoria               | Se pierden al apagar la instancia          |
| Uso compartido     | Una secuencia puede usarse en varias tablas | Muy común en la práctica                   |
| No transaccional   | NEXTVAL no participa en COMMIT/ROLLBACK     | Nunca se revierte                          |

> Nota: El tamaño del CACHE es mayor o igual que la cantidad de valores del ciclo de la secuencia. Si no usamos CACHE por defecto es 20
> En caso de no cumplir esta regla oracle despliega un ORA-04013

<br/><br/>

## Instrucciones

### 1. Limpieza inicial

```sql
DROP SEQUENCE seq_gap_demo;
DROP SEQUENCE seq_cycle_demo;
DROP SEQUENCE seq_cache_demo;
DROP SEQUENCE seq_shared_demo;
DROP SEQUENCE seq_tx_demo;
DROP SEQUENCE seq_demo

DROP TABLE t_seq_1 PURGE;
DROP TABLE t_seq_2 PURGE;
```

<br/><br/>

### 2. POC – Gaps por ROLLBACK

**(Pregunta A: Sequences can always have gaps)**

```sql
CREATE SEQUENCE seq_gap_demo START WITH 1;

SELECT seq_gap_demo.NEXTVAL FROM dual; -- 1

ROLLBACK;

SELECT seq_gap_demo.NEXTVAL FROM dual; -- 2
```

> **Observación:**
> El valor **1 nunca se recupera**.
> Aunque no se insertó ningún dato, el número se consumió.
> Demuestra que **los gaps siempre son posibles**.

<br/><br/>

### 3. POC – Valores duplicados con CYCLE

**(Pregunta B: A sequence can issue duplicate values)**

```sql
CREATE SEQUENCE seq_cycle_demo
START WITH 1
MAXVALUE 3
CYCLE
NOCACHE;

SELECT seq_cycle_demo.NEXTVAL FROM dual; -- 1
SELECT seq_cycle_demo.NEXTVAL FROM dual; -- 2
SELECT seq_cycle_demo.NEXTVAL FROM dual; -- 3
SELECT seq_cycle_demo.NEXTVAL FROM dual; -- 1
SELECT seq_cycle_demo.NEXTVAL FROM dual; -- 2
```

> **Observación:**
> El valor **1 se repite** después del ciclo.
> Oracle considera esto **duplicate values** (históricos).

<br/><br/>

### 4. POC – CACHE perdido al reiniciar la instancia

**(Pregunta C: Cached values are lost on shutdown)**

```sql
CREATE SEQUENCE seq_cache_demo
START WITH 1
CACHE 1000;

SELECT seq_cache_demo.NEXTVAL FROM dual; -- 1
SELECT seq_cache_demo.NEXTVAL FROM dual; -- 2
```

> Simula mentalmente en examen:

```sql
-- SHUTDOWN ABORT;
-- STARTUP;
```

```sql
SELECT seq_cache_demo.NEXTVAL FROM dual; -- 1002 (o mayor)
```

> **Observación:**
> Los valores **3–1000 se pierden**.
> Gap causado **sin ROLLBACK**.

<br/><br/>

### 5. POC – Misma secuencia en múltiples tablas

**(Pregunta D – FALSA)**

```sql
CREATE SEQUENCE seq_shared_demo;

CREATE TABLE t_seq_1 (
  id NUMBER
);

CREATE TABLE t_seq_2 (
  id NUMBER
);

INSERT INTO t_seq_1 VALUES (seq_shared_demo.NEXTVAL);
INSERT INTO t_seq_2 VALUES (seq_shared_demo.NEXTVAL);

SELECT * FROM t_seq_1;
SELECT * FROM t_seq_2;
```

> **Observación:**
> Una secuencia genera valores para **más de una tabla**.
> La afirmación D es falsa.

<br/><br/>

### 6. POC – NEXTVAL no es transaccional

**(Pregunta F – FALSA)**

```sql
CREATE SEQUENCE seq_tx_demo;

SELECT seq_tx_demo.NEXTVAL FROM dual; -- 1

ROLLBACK;

SELECT seq_tx_demo.NEXTVAL FROM dual; -- 2
```

> **Observación:**
> El valor **1 no vuelve**, aunque la transacción falle.
> Las secuencias **no participan en rollback**.

<br/><br/>

### 7. POC - Valor actual  CURRVAL


```sql
CREATE SEQUENCE seq_demo;

-- Falla
SELECT seq_demo.CURRVAL FROM dual;
-- ORA-08002

-- Inicializa
SELECT seq_demo.NEXTVAL FROM dual;  -- 1

-- Ya no incrementa
SELECT seq_demo.CURRVAL FROM dual;  -- 1
SELECT seq_demo.CURRVAL FROM dual;  -- 1

SELECT seq_demo.NEXTVAL FROM dual;  -- 2
SELECT seq_demo.CURRVAL FROM dual;  -- 2

COL sequence_name format a15
SELECT sequence_name, last_number, cache_size
FROM user_sequences
WHERE sequence_name like 'SEQ_%';

```

<br/><br/>

>Nota: ¿Qué es LAST_NUMBER?
* NO es el último valor emitido
* Es el próximo valor que Oracle tiene preparado, considerando CACHE

