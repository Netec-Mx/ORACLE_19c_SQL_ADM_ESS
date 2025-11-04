
-- 
-- Oracle 19c SQL & ADM
--

select f.tn TABLESPACE,
       round(usado/1048576,2) "USADO (Mb)",
       round(total/1048576,2) "TOTAL (Mb)",
       round(usado/total*100,2) "PCT (%)"
from (
    select tablespace_name tn, sum(nvl(bytes,0)) usado 
    from dba_segments 
    group by tablespace_name) s, (
    select tablespace_name tn, sum(nvl(bytes,0)) total 
    from dba_data_files where online_status='ONLINE' group by tablespace_name) f
    where s.tn=f.tn and f.tn=(select value from v$parameter where name = 'undo_tablespace');

quit