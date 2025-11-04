-- 
-- Oracle 19c SQL & ADM
-- Periodo de maximo ritmo de generación de undo
--
--
set heading off
set feedback off
alter session set NLS_DATE_FORMAT='DD/MM/YYYY HH24:MI:SS';

select 'Inicio periodo monitorizado ...: '|| min(begin_time) from dba_hist_undostat;

select 'Final periodo monitorizado ....: '|| max(end_time) from dba_hist_undostat;

set heading on

select begin_time "INICIO PERIODO", end_time "FIN PERIODO", ritmo "RITMO (Blk/s)"
from (
  select begin_time, end_time, undoblks/((end_time-begin_time)*(60*60*24)) ritmo 
  from dba_hist_undostat
)
where ritmo = (
  select max(undoblks/((end_time-begin_time)*(60*60*24))) 
  from dba_hist_undostat
);

quit