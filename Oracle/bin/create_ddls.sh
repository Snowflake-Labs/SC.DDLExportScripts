#!/bin/bash
VERSION="0.0.96"

# This script extracts DDLs from Oracle databases using SQL*Plus.
# It connects to an Oracle instance and retrieves the DDL statements for schemas, tables, views, procedures,
# functions, packages, and other database objects.  
export versionParam=$1

if [ "$versionParam" = "--version" ]; then
    echo "You are using the version $VERSION of the extraction scripts"
    exit 1
fi

echo "[$(date '+%Y/%m/%d %l:%M:%S%p')] Info: Execute Oracle extraction scripts: Started"

export ORACLE_SID=
export CONNECT_STRING=system/oracle
export SCRIPT_PATH=
export SQLCL_PATH=
# Default value is the #SCRIPT_PATH folder, You can change the output directory here!
export OUTPUT_PATH=$SCRIPT_PATH


if [ ! -e "$SCRIPT_PATH" ]; then
    echo "The script path does not exist."
    exit 1
fi

if [ ! -e "$SQLCL_PATH" ]; then
    echo "The sqlcl path does not exist."
    exit 1
fi

echo "[$(date '+%Y/%m/%d %l:%M:%S%p')] Info: Step 1/4 - Creating Directories: Started"

#Path to where object extracts are written
mkdir -p $OUTPUT_PATH/object_extracts
mkdir -p $OUTPUT_PATH/object_extracts/DDL
mkdir -p $OUTPUT_PATH/object_extracts/STORAGE
touch -- "${OUTPUT_PATH}/object_extracts/DDL/.sc_extracted"

echo "[$(date '+%Y/%m/%d %l:%M:%S%p')] Info: Step 1/4 - Creating Directories: Completed"


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

echo "[$(date '+%Y/%m/%d %l:%M:%S%p')] Info: Step 2/4 - Extracting DDLs: Started"

"$SQLCL_PATH"/sql $CONNECT_STRING @"$SCRIPT_PATH"/create_ddls.sql $INCLUDE_OPERATOR $INCLUDE_CONDITION $EXCLUDE_OPERATOR $EXCLUDE_CONDITION "$OUTPUT_PATH" $VERSION

echo "[$(date '+%Y/%m/%d %l:%M:%S%p')] Info: Step 2/4 - Extracting DDLs: Completed"

echo "[$(date '+%Y/%m/%d %l:%M:%S%p')] Info: Step 3/4 - Adding extraction headers: Started"

# Add extraction script header to each DDL file
DDL_FILES=("DDL_Tables.sql" "DDL_Views.sql" "DDL_Functions.sql" "DDL_Procedures.sql" "DDL_Packages.sql" "DDL_Synonyms.sql" "DDL_Types.sql" "DDL_Indexes.sql" "DDL_Triggers.sql" "DDL_Sequences.sql" "DDL_DBlink.sql" "DDL_QUEUE_TABLES.sql" "DDL_OLAP_CUBES.sql" "DDL_MATERIALIZED_VIEWS.sql" "DDL_QUEUES.sql" "DDL_ANALYTIC_VIEWS.sql" "DDL_OPERATORS.sql")

for file in "${DDL_FILES[@]}"; do
    if [ -f "$OUTPUT_PATH/object_extracts/DDL/$file" ]; then
        # Create temporary file with header
        temp_file=$(mktemp)
        echo "-- <sc_extraction_script> Oracle code extracted using script version $VERSION on $(date +%m/%d/%Y) <sc_extraction_script>" > "$temp_file"
        cat "$OUTPUT_PATH/object_extracts/DDL/$file" >> "$temp_file"
        mv "$temp_file" "$OUTPUT_PATH/object_extracts/DDL/$file"
    fi
done

echo "[$(date '+%Y/%m/%d %l:%M:%S%p')] Info: Step 3/4 - Adding extraction headers: Completed"

echo "[$(date '+%Y/%m/%d %l:%M:%S%p')] Info: Step 4/4 - Oracle extraction scripts: Completed"
