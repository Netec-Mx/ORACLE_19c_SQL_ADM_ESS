--
-- Curso Oracle 19c Administracion
--

drop table cruce_ccm;

create table userloader.cruce_ccm (
	id_cliente number primary key,
	id_contrato number,
	monto number
);

desc userloader.cruce_ccm

quit