--
-- Oracle 19c SQL & Admin
-- p02_espacio.sql
-- Espacio usado por los tablespaces
--
col "Tablespace" for a22
col "Used MB" for 99,999,999
col "Free MB" for 99,999,999
col "Total MB" for 99,999,999

select df.tablespace_name "Tablespace", totalusedspace "Used MB", (df.totalspace - tu.totalusedspace) "Free MB",
   df.totalspace "Total MB", round(100 * ( (df.totalspace - tu.totalusedspace)/ df.totalspace)) "Pct. Free" from
   (select tablespace_name, round(sum(bytes) / 1048576) TotalSpace from dba_data_files group by tablespace_name) df, (select round(sum(bytes)/(1024*1024)) totalusedspace, tablespace_name from dba_segments group by tablespace_name) tu where df.tablespace_name = tu.tablespace_name ;

quit