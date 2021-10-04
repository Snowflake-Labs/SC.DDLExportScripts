/*  DDL Extract Version 0.0.18.01  */

SET SERVEROUT ON SIZE 1000000
SET LONG 2000000
SET LONGCHUNKSIZE 2000000
SET LINESIZE 32676
SET TERMOUT OFF
SET HEADING OFF
SET PAGESIZE 0
SET TRIMSPOOL ON
SET VERIFY OFF
SET FEEDBACK OFF
SET SHOWMODE OFF

--
spool object_extracts/extract_info.txt
select 'Snowflake/Mobilize.Net SnowConvert Oracle Extraction Scripts 0.0.18.01' || CHR(10) || 'Date: ' || sysdate || CHR(10) || 'Oracle Version: ' || BANNER from V$VERSION;
spool off
--

WHENEVER SQLERROR CONTINUE

execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE', false);
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',false);
execute DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'TABLESPACE', false);
execute dbms_metadata.set_transform_param (dbms_metadata.session_transform,'CONSTRAINTS_AS_ALTER', false);
execute dbms_metadata.set_transform_param (DBMS_METADATA.session_transform,'SQLTERMINATOR', true);
execute dbms_metadata.set_transform_param (DBMS_METADATA.session_transform,'PRETTY',true);

--

spool object_extracts/DDL/DDL_Tables.sql

SELECT '/* <sc-table> ' || owner || '.' || object_name || ' </sc-table> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) 
FROM DBA_OBJECTS 
WHERE object_Type IN ('TABLE')
AND status = 'VALID' 
AND owner &1 &2
AND owner NOT &3 &4 
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND (owner, object_name) not in (select owner, table_name from dba_nested_tables)
AND (owner, object_name) not in (select owner, table_name from dba_tables where iot_type = 'IOT_OVERFLOW');
spool off


--

spool object_extracts/DDL/DDL_Views.sql

SELECT '/* <sc-view> ' || owner || '.' || object_name || ' </sc-view> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) 
FROM DBA_OBJECTS 
WHERE object_Type IN ('VIEW')
AND status = 'VALID' 
AND owner &1 &2
AND owner NOT &3 &4
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','IX','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'ORDS%'
AND owner NOT LIKE 'XDB%'
AND owner NOT LIKE 'XFILES%';

spool off

--

spool object_extracts/DDL/DDL_Functions.sql

SELECT '/* <sc-function> ' || owner || '.' || object_name || ' </sc-function> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) 
FROM DBA_OBJECTS 
WHERE object_Type IN ('FUNCTION')
AND status = 'VALID' 
AND owner &1 &2
AND owner NOT &3 &4
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%';


spool off

--

spool object_extracts/DDL/DDL_Procedures.sql

SELECT '/* <sc-procedure> ' || owner || '.' || object_name || ' </sc-procedure> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) 
FROM DBA_OBJECTS 
WHERE object_Type IN ('PROCEDURE') 
AND status = 'VALID'
AND owner &1 &2
AND owner NOT &3 &4
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'ORDS%';


spool off

--

spool object_extracts/DDL/DDL_Packages.sql

SELECT '/* <sc-package> ' || owner || '.' || object_name || ' </sc-package> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) 
FROM DBA_OBJECTS 
WHERE object_Type IN ('PACKAGE') 
AND status = 'VALID'
AND owner &1 &2
AND owner NOT &3 &4
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'ORDS%'
AND owner NOT LIKE 'XDB%'
AND owner NOT LIKE 'XFILES%';

spool off

--

spool object_extracts/DDL/DDL_Synonyms.sql

SELECT '/* <sc-synonym> ' || owner || '.' || object_name || ' </sc-synonym> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) 
FROM DBA_OBJECTS 
WHERE object_Type IN ('SYNONYM')
AND status = 'VALID' 
AND owner &1 &2
AND owner NOT &3 &4
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'PUBLIC%'
AND owner NOT LIKE 'SI_INFORMTN_SCHEMA%'
AND owner NOT LIKE 'FLOWS_FILES%'
AND owner NOT LIKE 'ORDS%'
AND owner NOT LIKE 'XDB%'
AND owner NOT LIKE 'XFILES%'
;

spool off

--

spool object_extracts/DDL/DDL_Types.sql

SELECT '/* <sc-type> ' || owner || '.' || object_name || ' </sc-type> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) 
FROM DBA_OBJECTS 
WHERE object_Type IN ('TYPE') 
AND status = 'VALID'
AND owner &1 &2
AND owner NOT &3 &4
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','IX','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','PM','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'ORDS%'
AND owner NOT LIKE 'XFILES%'
AND owner NOT LIKE 'XDB%'
AND object_name not like 'SYS_%';

spool off

--

spool object_extracts/DDL/DDL_Indexes.sql

SELECT '/* <sc-index> ' || owner || '.' || object_name || ' </sc-index> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) 
FROM DBA_OBJECTS 
WHERE object_Type IN ('INDEX')
AND status = 'VALID' 
AND owner &1 &2
AND owner NOT &3 &4
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DBJSON','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','IX','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','PM','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'FLOWS_FILES%'
AND owner NOT LIKE 'ORDS%'
AND owner NOT LIKE 'XDB%'
AND owner NOT LIKE 'XFILES%';

spool off

--

spool object_extracts/DDL/DDL_Triggers.sql

SELECT '/* <sc-trigger> ' || owner || '.' || object_name || ' </sc-trigger> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) 
FROM DBA_OBJECTS 
WHERE object_Type IN ('TRIGGER')
AND status = 'VALID' 
AND owner &1 &2
AND owner NOT &3 &4
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'FLOWS_FILES%'
AND owner NOT LIKE 'ORDS%'
AND owner NOT LIKE 'XDB%'
AND owner NOT LIKE 'XFILES%';

spool off

--

spool object_extracts/DDL/DDL_Sequences.sql

SELECT '/* <sc-sequence> ' || owner || '.' || object_name || ' </sc-sequence> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) 
FROM DBA_OBJECTS 
WHERE object_Type IN ('SEQUENCE')
AND status = 'VALID' 
AND owner &1 &2
AND owner NOT &3 &4
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','IX','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'ORDS%'
AND owner NOT LIKE 'XDB%';

spool off

--

spool object_extracts/DDL/DDL_DBlink.sql

SELECT 
'/* <sc-dblink> ' || owner || '.' || db_link || ' </sc-dblink> */', DBMS_METADATA.get_ddl('DB_LINK', db_link, owner) 
FROM dba_db_links 
WHERE 1=1 -- VALID = 'YES'
AND owner &1 &2
AND owner NOT &3 &4
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%';

spool off

--

spool object_extracts/DDL/DDL_QUEUE_TABLES.sql

SELECT '/* <sc-queue_table> ' || owner || '.' || queue_table || ' </sc-queue_table> */', DBMS_METADATA.get_ddl('TABLE', queue_table, owner) 
FROM DBA_QUEUE_TABLES 
WHERE 
owner &1 &2
AND owner NOT &3 &4 
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','IX','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'XDB%'
AND owner NOT LIKE 'XFILES%'
AND (owner, queue_table) not in (select owner, table_name from dba_nested_tables)
AND (owner, queue_table) not in (select owner, table_name from dba_tables where iot_type = 'IOT_OVERFLOW');

spool off

--

spool object_extracts/DDL/DDL_OLAP_CUBES.sql

SELECT '/* <sc-olap_cube> ' || owner || '.' || cube_name || ' </sc-olap_cube> */', DBMS_METADATA.get_ddl('CUBE', cube_name, owner) 
FROM DBA_CUBES 
WHERE 
owner &1 &2
AND owner NOT &3 &4 
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%';

spool off

--

spool object_extracts/DDL/DDL_MATERIALIZED_VIEWS.sql

SELECT '/* <sc-materialized_view> ' || owner || '.' || mview_name || ' </sc-materialized_view> */', DBMS_METADATA.get_ddl('MATERIALIZED_VIEW', mview_name, owner) 
FROM DBA_MVIEWS 
WHERE 
owner &1 &2
AND owner NOT &3 &4 
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%';

spool off

--

spool object_extracts/DDL/DDL_QUEUES.sql

SELECT '/* <sc-queue> ' || owner || '.' || name || ' </sc-queue> */' 
FROM DBA_QUEUES 
WHERE 
owner &1 &2
AND owner NOT &3 &4 
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','IX','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'XDB%'
AND owner NOT LIKE 'XFILES%';

spool off

--

spool object_extracts/DDL/DDL_ANALYTIC_VIEWS.sql

SELECT '/* <sc-analytic_view> ' || owner || '.' || analytic_view_name || ' </sc-analytic_view> */', DBMS_METADATA.get_ddl('ANALYTIC_VIEW', analytic_view_name, owner)
FROM DBA_ANALYTIC_VIEWS 
WHERE 
owner &1 &2
AND owner NOT &3 &4 
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%';

spool off

--

spool object_extracts/DDL/DDL_OPERATORS.sql

SELECT '/* <sc-operator> ' || owner || '.' || operator_name || ' </sc-analytic_view> */', DBMS_METADATA.get_ddl('OPERATOR', operator_name, owner)
FROM DBA_OPERATORS 
WHERE 
owner &1 &2
AND owner NOT &3 &4
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%';

spool off


--
--STORAGE 
--
SET COLSEP ","
SET HEADING ON
spool object_extracts/STORAGE/STORAGE_Tables.csv

select TRIM(owner),TRIM(table_name), num_rows, NVL(round((avg_row_len*num_rows)/1024/1024,1),0) EST_MB_UNCOMPRESSED, compression from DBA_TABLES 
    WHERE owner &1 &2
    AND owner NOT &3 &4
    AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
    AND owner NOT LIKE 'DBA%'
    AND owner NOT LIKE 'APEX%';

spool off

execute dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'DEFAULT');

quit

