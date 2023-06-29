@echo off
REM GENERAL INSTRUCTIONS: This script is used to extract object DDL from your Oracle Database.  Please adjust the variables below
REM                       to match your environment. Once completed, your extracted DDL code will be stored in the object_extracts folder.


SET ORACLE_SID=ORCL

SET CONNECT_STRING="system/System123"

SET SCRIPT_PATH="C:\oracle"

SET OUTPUT_PATH=%SCRIPT_PATH%


if not exist %SCRIPT_PATH% (
    echo "The script_path path does not exist."
    EXIT /b
)

REM Path to where object extracts are written

mkdir %OUTPUT_PATH%\object_extracts
mkdir %OUTPUT_PATH%\object_extracts\DDL
mkdir %OUTPUT_PATH%\object_extracts\STORAGE

if not exist %OUTPUT_PATH% (
    echo "The output path does not exist."
    EXIT /b
)

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
sqlplus %CONNECT_STRING% @%FULL_PATH% %INCLUDE_OPERATOR% %INCLUDE_CONDITION% %EXCLUDE_OPERATOR% %EXCLUDE_CONDITION% %OUTPUT_PATH%