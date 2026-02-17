@echo off
REM GENERAL INSTRUCTIONS: This script is used to extract object DDL from your Oracle Database.  Please adjust the variables below
REM                       to match your environment. Once completed, your extracted DDL code will be stored in the object_extracts folder.

SET VERSION=0.2.0

SET ORACLE_SID=ORCL

SET CONNECT_STRING="system/System123"

SET SCRIPT_PATH="\\Mac\Home\Documents\Workspace\SC.DDLExportScripts\Oracle"

SET OUTPUT_PATH=%SCRIPT_PATH%


if not exist %SCRIPT_PATH% (
    echo "The script_path path does not exist."
    EXIT /b
)

echo [%date% %time%] Info: Execute Oracle extraction scripts: Started
echo.
echo [%date% %time%] Info: Step 1/4 - Creating Directories: Started

REM Path to where object extracts are written

mkdir %OUTPUT_PATH%\object_extracts
mkdir %OUTPUT_PATH%\object_extracts\DDL
mkdir %OUTPUT_PATH%\object_extracts\STORAGE
cd . > %OUTPUT_PATH%\object_extracts\DDL\.sc_extracted

if not exist %OUTPUT_PATH% (
    echo "The output path does not exist."
    EXIT /b
)

echo [%date% %time%] Info: Step 1/4 - Creating Directories: Completed
echo.
echo [%date% %time%] Info: Step 2/4 - Extracting DDLs: Started

REM Modify the operator and condition for the Oracle schemas to explicity include.  
REM By default all schemas, other than system schemas, will be included. 
REM Use uppercase names.  Do not remove the parentheses or double quotes.
SET INCLUDE_OPERATOR="LIKE"
SET INCLUDE_CONDITION="('%%')"

REM Modify the operator and condition for the Oracle schemas to explicity exclude.  
REM Not necessary to modify this if you are using the above section to explicity include only certain schemas.
REM Use uppercase names.  Do not remove the parentheses or double quotes.
SET EXCLUDE_OPERATOR="IN"
SET EXCLUDE_CONDITION="('XXX')"

set FILE_NAME=create_ddls_plus.sql
set FULL_PATH=%SCRIPT_PATH%\%file_name%

@echo on
sqlplus %CONNECT_STRING% @%FULL_PATH% %INCLUDE_OPERATOR% %INCLUDE_CONDITION% %EXCLUDE_OPERATOR% %EXCLUDE_CONDITION% %OUTPUT_PATH% %VERSION%

@echo off
echo.
echo [%date% %time%] Info: Step 2/4 - Extracting DDLs: Completed
echo.
echo [%date% %time%] Info: Step 3/4 - Adding extraction headers: Started

REM Add extraction script header to each DDL file
SET DDL_FILES=DDL_Tables.sql DDL_Views.sql DDL_Functions.sql DDL_Procedures.sql DDL_Packages.sql DDL_Synonyms.sql DDL_Types.sql DDL_Indexes.sql DDL_Triggers.sql DDL_Sequences.sql DDL_DBlink.sql DDL_QUEUE_TABLES.sql DDL_OLAP_CUBES.sql DDL_MATERIALIZED_VIEWS.sql DDL_QUEUES.sql DDL_ANALYTIC_VIEWS.sql DDL_OPERATORS.sql

for %%f in (%DDL_FILES%) do (
    if exist "%OUTPUT_PATH%\object_extracts\DDL\%%f" (
        echo Processing %%f...
        REM Create temporary file with header
        echo -- ^<sc_extraction_script^> Oracle code extracted using script version %VERSION% on %date% ^<sc_extraction_script^> > "%OUTPUT_PATH%\object_extracts\DDL\%%f.tmp"
        type "%OUTPUT_PATH%\object_extracts\DDL\%%f" >> "%OUTPUT_PATH%\object_extracts\DDL\%%f.tmp"
        move "%OUTPUT_PATH%\object_extracts\DDL\%%f.tmp" "%OUTPUT_PATH%\object_extracts\DDL\%%f"
    )
)

echo [%date% %time%] Info: Step 3/4 - Adding extraction headers: Completed
echo.
echo [%date% %time%] Info: Step 4/4 - Oracle extraction scripts: Completed