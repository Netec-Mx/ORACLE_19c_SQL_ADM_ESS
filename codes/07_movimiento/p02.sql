--
-- Curso Oracle 19c SQL & ADM
--

drop user userloader cascade;

drop tablespace ts_loader including contents and datafiles;

create tablespace ts_loader datafile '/u02/oradata/orcl/df_loader' size 20m;

create user userloader identified by Oracle1 account unlock default tablespace ts_loader;

grant create session, create table, unlimited tablespace to userloader;

conn userloader/Oracle1

create table productos (
	sku number primary key,
	region char(3),
	descripcion varchar2(80),
	tipo varchar2(20)
);

desc userloader.productos

quit
