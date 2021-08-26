param (
    [switch][Alias("h", "-help")]$HELP = $false,
    [Alias("HO", "-host")]$CONNECTION_HOST,
    [Alias("S", "-service")]$CONNECTION_SERVICE,
    [Alias("U", "-user")]$DB_USER,
    [Alias("P", "-password")] $DB_PASSWORD,
    [switch][Alias("-as-sysdba")]$SYSDBA = $false
)

function Set-Export-Script {
    Write-Host "Creating the scripts to export object DDLs"

    if (Test-Path ".\object_extracts") {
        Remove-Item -Recurse -Force object_extracts
    }    
    New-Item -ItemType Directory -Force -Path "./object_extracts/DDL"
    New-Item -ItemType Directory -Force -Path "./object_extracts/DDLExtra"

    if (Test-Path ".\scripts") {
        Remove-Item -Recurse -Force scripts
    }    
    New-Item -ItemType Directory -Force -Path "./scripts"

    $VERSION = '0.0.18'
    $OS_INFO = [Environment]::OSVersion.VersionString

    "SET SERVEROUT ON SIZE 1000000
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
spool object_extracts/DDL/extract_info.txt
select 'Mobilize.Net SnowConvert Oracle Extraction Scripts $VERSION.' || CHR(13) || CHR(10) || 'Date: ' || sysdate || CHR(13) || CHR(10) || 'OS information: ' || '$OS_INFO' from dual;
spool off
--

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
AND owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION 
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND (owner, object_name) not in (select owner, table_name from dba_nested_tables)
AND (owner, object_name) not in (select owner, table_name from dba_tables where iot_type = 'IOT_OVERFLOW');
spool off

--
spool object_extracts/DDL/DDL_Views.sql

SELECT '/* <sc-view> ' || owner || '.' || object_name || ' </sc-view> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) || ';'
FROM DBA_OBJECTS 
WHERE object_Type IN ('VIEW')
AND status = 'VALID' 
AND owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION
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
AND owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION
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
AND owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION
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
AND owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION
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
AND owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION
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

spool object_extracts/DDLExtra/DDL_Types.sql

SELECT '/* <sc-type> ' || owner || '.' || object_name || ' </sc-type> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) 
FROM DBA_OBJECTS 
WHERE object_Type IN ('TYPE') 
AND status = 'VALID'
AND owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','IX','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','PM','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'ORDS%'
AND owner NOT LIKE 'XFILES%'
AND owner NOT LIKE 'XDB%'
AND object_name not like 'SYS_%';

spool off

--

spool object_extracts/DDLExtra/DDL_Indexes.sql

SELECT '/* <sc-index> ' || owner || '.' || object_name || ' </sc-index> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) 
FROM DBA_OBJECTS 
WHERE object_Type IN ('INDEX')
AND status = 'VALID' 
AND owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DBJSON','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','IX','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','PM','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'FLOWS_FILES%'
AND owner NOT LIKE 'ORDS%'
AND owner NOT LIKE 'XDB%'
AND owner NOT LIKE 'XFILES%';

spool off

--

spool object_extracts/DDLExtra/DDL_Triggers.sql

SELECT '/* <sc-trigger> ' || owner || '.' || object_name || ' </sc-trigger> */', DBMS_METADATA.get_ddl(object_type, object_name, owner) 
FROM DBA_OBJECTS 
WHERE object_Type IN ('TRIGGER')
AND status = 'VALID' 
AND owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION
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
AND owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','IX','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'ORDS%'
AND owner NOT LIKE 'XDB%';

spool off

--

spool object_extracts/DDLExtra/DDL_DBlink.sql

SELECT 
'/* <sc-dblink> ' || owner || '.' || db_link || ' </sc-dblink> */', DBMS_METADATA.get_ddl('DB_LINK', db_link, owner) 
FROM dba_db_links 
WHERE 1=1 -- VALID = 'YES'
AND owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%';

spool off

--

spool object_extracts/DDLExtra/DDL_QUEUE_TABLES.sql

SELECT '/* <sc-queue_table> ' || owner || '.' || queue_table || ' </sc-queue_table> */', DBMS_METADATA.get_ddl('TABLE', queue_table, owner) 
FROM DBA_QUEUE_TABLES 
WHERE 
owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION 
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','IX','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'XDB%'
AND owner NOT LIKE 'XFILES%'
AND (owner, queue_table) not in (select owner, table_name from dba_nested_tables)
AND (owner, queue_table) not in (select owner, table_name from dba_tables where iot_type = 'IOT_OVERFLOW');

spool off

--

spool object_extracts/DDLExtra/DDL_OLAP_CUBES.sql

SELECT '/* <sc-olap_cube> ' || owner || '.' || cube_name || ' </sc-olap_cube> */', DBMS_METADATA.get_ddl('CUBE', cube_name, owner) 
FROM DBA_CUBES 
WHERE 
owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION 
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%';

spool off

--

spool object_extracts/DDLExtra/DDL_MATERIALIZED_VIEWS.sql

SELECT '/* <sc-materialized_view> ' || owner || '.' || mview_name || ' </sc-materialized_view> */', DBMS_METADATA.get_ddl('MATERIALIZED_VIEW', mview_name, owner) 
FROM DBA_MVIEWS 
WHERE 
owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION 
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%';

spool off

--

spool object_extracts/DDLExtra/DDL_QUEUES.sql

SELECT '/* <sc-queue> ' || owner || '.' || name || ' </sc-queue> */' 
FROM DBA_QUEUES 
WHERE 
owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION 
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','IX','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%'
AND owner NOT LIKE 'XDB%'
AND owner NOT LIKE 'XFILES%';

spool off

--

spool object_extracts/DDLExtra/DDL_ANALYTIC_VIEWS.sql

SELECT '/* <sc-analytic_view> ' || owner || '.' || analytic_view_name || ' </sc-analytic_view> */', DBMS_METADATA.get_ddl('ANALYTIC_VIEW', analytic_view_name, owner)
FROM DBA_ANALYTIC_VIEWS 
WHERE 
owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION 
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%';

spool off

--

spool object_extracts/DDLExtra/DDL_OPERATORS.sql

SELECT '/* <sc-operator> ' || owner || '.' || operator_name || ' </sc-analytic_view> */', DBMS_METADATA.get_ddl('OPERATOR', operator_name, owner)
FROM DBA_OPERATORS 
WHERE 
owner @@INCLUDE_OPERATOR @@INCLUDE_CONDITION
AND owner NOT @@EXCLUDE_OPERATOR @@EXCLUDE_CONDITION
AND owner NOT IN ('EXFSYS','SYSMAN','DMSYS','ANONYMOUS','APPQOSSYS','AUDSYS','CTXSYS','DBSFWUSER','DBSNMP','DVF','DVSYS','GGSYS','GSMADMIN_INTERNAL','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','OUTLN','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','REMOTE_SCHEDULER_AGENT','SYS','SYSTEM','WMSYS','XDB')
AND owner NOT LIKE 'DBA%'
AND owner NOT LIKE 'APEX%';

spool off

dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'DEFAULT');

quit" | Out-File -FilePath ".\scripts\create_ddls.sql"
}

Write-Host "sc-oracle-export"
Write-Host "This script will install the Oracle SQLcl tool and JDK to enable connection to your database"

function Install-Tools {
    if (Test-Path ".\tools") {
        Remove-Item -Recurse -Force tools
    }
    New-Item -ItemType Directory -Force -Path ".\tools"

    Write-Host "*** Installing Open JDK 11 ***"
    Push-Location .

    New-Item -ItemType Directory -Force -Path ".\tools\java"
    Set-Location -Path ".\tools\java"

    Write-Host "Downloading JDK zip file"
    if ([Environment]::Is64BitOperatingSystem -or ((Get-WmiObject Win32_OperatingSystem).OSArchitecture -eq "64-bit")) {
        $Url = "https://corretto.aws/downloads/latest/amazon-corretto-11-x64-windows-jdk.zip"
    } else {
        $Url = "https://corretto.aws/downloads/latest/amazon-corretto-11-x86-windows-jdk.zip"
    }

    $DownloadZipFile = $(Split-Path -Path $Url -Leaf)
    Invoke-WebRequest -Uri $Url -OutFile $DownloadZipFile

    Write-Host "Extracting JDK from zip file..."
    Expand-Archive ".\$DownloadZipFile" -DestinationPath "." -Force

    Get-ChildItem -Directory -Path . | Where-Object {$_.Name -like "jdk*"} | Rename-Item -NewName jdk11

    Remove-Item $DownloadZipFile
    Pop-Location

    $env:JAVA_HOME = Resolve-Path -Path ".\tools\java\jdk11"
    $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

    Write-Host "*** Installing Oracle SQLcl ***"
    Set-Location -Path ".\tools"
    
    Write-Host "Downloading SQLcl zip file"
    $Url = "https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip"
    $DownloadZipFile = $(Split-Path -Path $Url -Leaf)
    Invoke-WebRequest -Uri $Url -OutFile $DownloadZipFile

    Write-Host "Extracting SQLcl from zip file..."
    Expand-Archive ".\$DownloadZipFile" -DestinationPath "." -Force
    
    Remove-Item $DownloadZipFile
    
    Set-Location -Path ".."
    
    [Environment]::SetEnvironmentVariable("ORACLE_HOME", $null ,"User")
}

if ($HELP -eq $true) {
    Write-Host "    usage: sc-oracle-export [-h|-H]  [-U|--user USER] [-P|--password PASSWORD] [-HO|--host HOST] [-S|--service SERVICE] [--as-sysdba]"
    Write-Host ""
    Write-Host "    Mobilize.NET Oracle Code Export ToolsVersion X.X.X"
    Write-Host ""
    Write-Host "    optional arguments:"
    Write-Host "    -h  , --help       Show this help message and exit"
    Write-Host "    -S  , --service    Service name. For example ORCL"
    Write-Host "    -HO , --host       Host"
    Write-Host "    -U  , --user       Login ID for server"
    Write-Host "    -P  , --password   The password for the given user."
    Write-Host "    --as-sysdba        Connect as sysdba"
    Exit 1
}

$answer = Read-Host "Do you want to install tools to connect to Oracle (yes/no/cancel)?"

switch -Regex ($answer.ToUpper()) {
    'Y(ES)?' { 
        $answer = "Y";
        break
     }
    'NO?' {
        $answer = "N";
        break
    }
    Default {
        Write-Host "Execution has been cancelled";
        Exit 1
    }
}

if ($answer -eq "Y") {
    Install-Tools
}

Set-Export-Script

Write-Host "Updating DDL export scripts..."

$Include_Operator = Read-Host "1. Enter value for the 'INCLUDE_OPERATOR' (e.g. LIKE, IN, =, NOT IN, NOT LIKE)"
if ([string]::IsNullOrWhiteSpace($Include_Operator)) {
    $Include_Operator = "LIKE"
}

$Include_Condition = Read-Host "2. Enter value for the 'INCLUDE_CONDITION'"
if ([string]::IsNullOrWhiteSpace($Include_Condition)) {
    $Include_Condition = "'%%'"
}

$Exclude_Operator = Read-Host "3. Enter value for the 'EXCLUDE_OPERATOR' (e.g. LIKE, IN)"
if ([string]::IsNullOrWhiteSpace($Exclude_Operator)) {
    $Exclude_Operator = "IN"
}

$Exclude_Condition = Read-Host "4. Enter value for the 'EXCLUDE_CONDITION'"
if ([string]::IsNullOrWhiteSpace($Exclude_Condition)) {
    $Exclude_Condition = "('SYSMAN')"
}

Write-Host "If nothing was entered, we will be using these default values: 1=LIKE 2='%%' 3=IN 4=('SYSMAN')"

$Create_DDLs_File = ".\scripts\create_ddls.sql"

((Get-Content -path $Create_DDLs_File -Raw) -replace '@@INCLUDE_OPERATOR', $Include_Operator) | Set-Content -Path $Create_DDLs_File
((Get-Content -path $Create_DDLs_File -Raw) -replace '@@INCLUDE_CONDITION', $Include_Condition) | Set-Content -Path $Create_DDLs_File
((Get-Content -path $Create_DDLs_File -Raw) -replace '@@EXCLUDE_OPERATOR', $Exclude_Operator) | Set-Content -Path $Create_DDLs_File
((Get-Content -path $Create_DDLs_File -Raw) -replace '@@EXCLUDE_CONDITION', $Exclude_Condition) | Set-Content -Path $Create_DDLs_File

$SQLcl = ".\tools\sqlcl\bin\sql.exe"
if (Test-Path -Path $SQLcl -PathType Leaf) {
    Write-Host "Connecting to DB and executing the Oracle DDL Extraction"
    if ($SYSDBA -eq $false) {
        & $SQLcl $DB_USER/$DB_PASSWORD@$CONNECTION_HOST/$CONNECTION_SERVICE "@.\scripts\create_ddls.sql"
    } else {
        & $SQLcl $DB_USER/$DB_PASSWORD@$CONNECTION_HOST/$CONNECTION_SERVICE AS SYSDBA "@.\scripts\create_ddls.sql"
    }
} else {
    Write-Host "NOTE: **** Run this script with your oracle tools. For example sqlplus USER/PASSWORD@HOST/SERVICE @./scripts/create_ddls.sql"
}

Write-Host "Cleaning up empty output files"
Get-ChildItem -Recurse ".\object_extracts" | Where-Object {$_.length -eq 0} | Remove-Item

Write-Host "============================================================================================================================"
Write-Host "You can now run the script ./scripts/create_ddls.sql to export your Oracle DDLs"