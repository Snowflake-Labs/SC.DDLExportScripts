#!/bin/bash

#GENERAL INSTRUCTIONS: This script is used to extract object DDL from your Oracle Database.  Please adjust the variables below
#                      to match your environment. Once completed, your extracted DDL code will be stored in the object_extracts folder.

export ORACLE_SID=
export CONNECT_STRING=system/oracle
export SCRIPT_PATH=/home/oracle

#Path to where object extracts are written
mkdir $SCRIPT_PATH/object_extracts
mkdir $SCRIPT_PATH/object_extracts/DDL
mkdir $SCRIPT_PATH/object_extracts/STORAGE

# Modify the operator and condition for the Oracle schemas to explicity INCLUDE.  
# By default all schemas, other than system schemas, will be included. 
# Use uppercase names.  Do not remove the parentheses or double quotes.
export INCLUDE_OPERATOR=LIKE
export INCLUDE_CONDITION="('%')"

# Modify the operator and condition for the Oracle schemas to explicity EXCLUDE.  
# By default all schemas, other than system schemas, will be included. 
# Use uppercase names.  Do not remove the parentheses or double quotes.
export EXCLUDE_OPERATOR=IN
export EXCLUDE_CONDITION="('SYSMAN')"

sqlplus $CONNECT_STRING @$SCRIPT_PATH/create_ddls.sql $INCLUDE_OPERATOR $INCLUDE_CONDITION $EXCLUDE_OPERATOR $EXCLUDE_CONDITION
