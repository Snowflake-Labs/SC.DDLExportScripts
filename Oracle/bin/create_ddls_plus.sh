#!/bin/bash

#GENERAL INSTRUCTIONS: This script is used to extract object DDL from your Oracle Database.  Please adjust the variables below
#                      to match your environment. Once completed, your extracted DDL code will be stored in the object_extracts folder.

export ORACLE_SID=
export CONNECT_STRING=system/oracle
export SCRIPT_PATH=/home/oracle
# Default value is the #SCRIPT_PATH folder, You can change the output directory here!
export OUTPUT_PATH=$SCRIPT_PATH


if [ ! -e "$SCRIPT_PATH" ]; then
    echo "The script path does not exist."
    exit 1
fi

#Path to where object extracts are written
mkdir -p $OUTPUT_PATH/object_extracts
mkdir -p $OUTPUT_PATH/object_extracts/DDL
mkdir -p $OUTPUT_PATH/object_extracts/STORAGE

if [ ! -e "$OUTPUT_PATH" ]; then
    echo "The output path does not exist."
    exit 1
fi

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

# Modify this JAVA variable to asign less or more memory to the JVM
# export JAVA_TOOL_OPTIONS=-Xmx4G

sqlplus $CONNECT_STRING @$SCRIPT_PATH/create_ddls_plus.sql $INCLUDE_OPERATOR $INCLUDE_CONDITION $EXCLUDE_OPERATOR $EXCLUDE_CONDITION $OUTPUT_PATH