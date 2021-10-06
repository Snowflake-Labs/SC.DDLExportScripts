@echo off
REM GENERAL INSTRUCTIONS: This script is used to extract object DDL from your Oracle Database.  Please adjust the variables below
REM                       to match your environment. Once completed, your extracted DDL code will be stored in the object_extracts folder.


SET ORACLE_SID=ORCL

SET CONNECT_STRING="system/System123"

SET SCRIPT_PATH="C:\oracle"

REM Path to where object extracts are written

mkdir %SCRIPT_PATH%\object_extracts
mkdir %SCRIPT_PATH%\object_extracts\DDL
mkdir %SCRIPT_PATH%\object_extracts\STORAGE

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

@echo on
sqlplus %CONNECT_STRING% @C:\Oracle\create_ddls.sql %INCLUDE_OPERATOR% %INCLUDE_CONDITION% %EXCLUDE_OPERATOR% %EXCLUDE_CONDITION%