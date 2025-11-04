--
-- Curso Oracle 19c SQL & ADM
--

drop user userdp cascade;

drop tablespace ts_userdp including contents and datafiles;

create tablespace ts_userdp datafile '/u02/oradata/orcl/df_userdp' size 250m;

create user userdp identified by Oracle1 account unlock default tablespace ts_userdp;

grant create session, create table, unlimited tablespace to userdp;
grant exp_full_database to userdp;

quit