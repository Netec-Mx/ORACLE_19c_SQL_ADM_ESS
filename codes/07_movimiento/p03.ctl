--
-- Curso Oracle 19c Administración
--

LOAD DATA
infile '/home/oracle/codes/13_movimientos/datos.dat'
into table userloader.cruce_ccm
append
fields terminated by ','
( id_cliente, id_contrato, monto )
