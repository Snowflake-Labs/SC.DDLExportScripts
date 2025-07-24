#!/bin/bash
VERSION="0.0.96"

# This script extracts DDLs from BigQuery using the Google Cloud SDK.
# It connects to a BigQuery instance and retrieves the DDL statements for schemas, tables, views, functions, procedures,
# external tables, reservations, capacity commitments, and assignments. 

# Define the extraction script message as a variable
EXTRACTION_MESSAGE="-- <sc_extraction_script> BigQuery code extracted using script version $VERSION on $(date +%m/%d/%Y) <sc_extraction_script>"

export inputParam=$1
if [ "$inputParam" = "--version" ]; then
    echo "You are using the $VERSION of the extraction scripts"
    exit 1
fi

if [ "$inputParam" = "--help" ]; then
    echo "  --help                              Display this help screen."
    echo "  --version                           Display version information."
    echo "  -s                                  Optional parameter to limit to an in-list of schemas"
    echo "                                      using the following structure "schema1 [, ...]"\""
    exit 1
fi


while getopts s: flag
do
    case "${flag}" in
        s) SCHEMA=${OPTARG};;
    esac
done

REGION='us'

echo " "
echo " +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+"
echo " |B|i|g|Q|u|e|r|y| |E|x|p|o|r|t| |b|y| |S|n|o|w|f|l|a|k|e|"
echo " +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+"
echo " Version $VERSION" 
echo " +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+"
echo " "
echo " Before execute this tool, please read the following link "
echo " https://github.com/Snowflake-Labs/SC.DDLExportScripts/blob/main/BigQuery/README.md"
echo " This tool is exclusively to execute using Google Cloud Console"
echo " "

echo "Extracting DDLs from region $REGION"
if [ "$SCHEMA" != "" ]; then
    echo "Schemas to filter: $SCHEMA"
fi

echo "Creating Output Folder..."

mkdir -p Output
cd Output/ || exit
mkdir -p DDL
cd ..
echo "Extracting DDLs..."

# -----------------   EXTRACT SCHEMAS   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Schema.sql 2>&1

echo "$EXTRACTION_MESSAGE"
echo ""

if [ "$SCHEMA" != "" ]; then
    SCHEMA_CLAUSE=' INNER JOIN UNNEST(SPLIT('\'$SCHEMA\'', '\',\'')) AS SCHEMAS
        ON TRIM(SCHEMAS)=schema_name'
else 
    SCHEMA_CLAUSE=""
fi

./google-cloud-sdk/bin/bq query --use_legacy_sql=false --max_rows=50000 \
'
    SELECT
        '\''/* <sc-schema> '\''||catalog_name||'\''.'\''||schema_name||'\'' </sc-schema> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM 
        `region-'$REGION'`.INFORMATION_SCHEMA.SCHEMATA '$SCHEMA_CLAUSE'
'

# -----------------   EXTRACT TABLES   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Tables.sql 2>&1

echo "$EXTRACTION_MESSAGE"
echo ""

if [ "$SCHEMA" != "" ]; then
    SCHEMA_CLAUSE=' INNER JOIN UNNEST(SPLIT('\'$SCHEMA\'', '\',\'')) AS SCHEMAS
        ON TRIM(SCHEMAS)=table_schema'
else 
    SCHEMA_CLAUSE=""
fi

./google-cloud-sdk/bin/bq query --use_legacy_sql=false --max_rows=50000 \
'
    SELECT
        '\''/* <sc-'\''||lower(table_type)||'\''> '\''||table_catalog||'\''.'\''||table_schema||'\''.'\''||table_name||'\'' </sc-'\''||lower(table_type)||'\''> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM
        `region-'$REGION'`.INFORMATION_SCHEMA.TABLES '$SCHEMA_CLAUSE'
	WHERE
		table_type = '\''BASE TABLE'\''
'
# -----------------   EXTRACT EXTERNAL TABLES   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_External_Tables.sql 2>&1

echo "$EXTRACTION_MESSAGE"
echo ""

./google-cloud-sdk/bin/bq query --use_legacy_sql=false --max_rows=50000 \
'
    SELECT
        '\''/* <sc-'\''||lower(table_type)||'\''> '\''||table_catalog||'\''.'\''||table_schema||'\''.'\''||table_name||'\'' </sc-'\''||lower(table_type)||'\''> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM
        `region-'$REGION'`.INFORMATION_SCHEMA.TABLES '$SCHEMA_CLAUSE'
	WHERE
		table_type = '\''EXTERNAL TABLE'\''
'

# -----------------   EXTRACT VIEWS   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Views.sql 2>&1

echo "$EXTRACTION_MESSAGE"
echo ""

./google-cloud-sdk/bin/bq query --use_legacy_sql=false --max_rows=50000 \
'
    SELECT
        '\''/* <sc-'\''||lower(table_type)||'\''> '\''||table_catalog||'\''.'\''||table_schema||'\''.'\''||table_name||'\'' </sc-'\''||lower(table_type)||'\''> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM
        `region-'$REGION'`.INFORMATION_SCHEMA.TABLES '$SCHEMA_CLAUSE'
	WHERE
		table_type = '\''VIEW'\''
'

# -----------------   EXTRACT FUNCTIONS   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Functions.sql 2>&1

echo "$EXTRACTION_MESSAGE"
echo ""

if [ "$SCHEMA" != "" ]; then
    SCHEMA_CLAUSE=' INNER JOIN UNNEST(SPLIT('\'$SCHEMA\'', '\',\'')) AS SCHEMAS
        ON TRIM(SCHEMAS)=specific_schema'
else 
    SCHEMA_CLAUSE=""
fi

./google-cloud-sdk/bin/bq query --use_legacy_sql=false --max_rows=50000 \
'
    SELECT
        '\''/* <sc-'\''||lower(routine_type)||'\''> '\''||specific_catalog||'\''.'\''||specific_schema||'\''.'\''||specific_name||'\'' </sc-'\''||lower(routine_type)||'\''> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM  
        `region-'$REGION'`.INFORMATION_SCHEMA.ROUTINES '$SCHEMA_CLAUSE'
	WHERE
		routine_type = '\''FUNCTION'\''
'

# -----------------   EXTRACT PROCEDURES   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Procedures.sql 2>&1

echo "$EXTRACTION_MESSAGE"
echo ""

./google-cloud-sdk/bin/bq query --use_legacy_sql=false --max_rows=50000 \
'
    SELECT
        '\''/* <sc-'\''||lower(routine_type)||'\''> '\''||specific_catalog||'\''.'\''||specific_schema||'\''.'\''||specific_name||'\'' </sc-'\''||lower(routine_type)||'\''> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM  
        `region-'$REGION'`.INFORMATION_SCHEMA.ROUTINES '$SCHEMA_CLAUSE'
	WHERE
		routine_type = '\''PROCEDURE'\''
'

# -----------------   EXTRACT RESERVATIONS   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Reservations.sql 2>&1

echo "$EXTRACTION_MESSAGE"
echo ""

./google-cloud-sdk/bin/bq query --use_legacy_sql=false --max_rows=50000 \
'
    SELECT 
        '\''/* <sc-reservation> '\''||project_id||'\''.'\''||reservation_name||'\'' </sc-reservation> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM 
        `region-'$REGION'`.INFORMATION_SCHEMA.RESERVATIONS_BY_PROJECT
'

# -----------------   EXTRACT CAPACITY COMMITMENTS   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Capacity_commitments.sql 2>&1

echo "$EXTRACTION_MESSAGE"
echo ""

./google-cloud-sdk/bin/bq query --use_legacy_sql=false --max_rows=50000 \
'
    SELECT 
        '\''/* <sc-capacity_commitments> '\''||project_id||'\''.'\''||capacity_commitment_id||'\'' </sc-capacity_commitments> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM 
        `region-'$REGION'`.INFORMATION_SCHEMA.CAPACITY_COMMITMENTS_BY_PROJECT
'

# -----------------   EXTRACT ASSIGNMENTS   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Assignments.sql 2>&1

echo "$EXTRACTION_MESSAGE"
echo ""

./google-cloud-sdk/bin/bq query --use_legacy_sql=false --max_rows=50000 \
'
    SELECT 
        '\''/* <sc-assigments> '\''||project_id||'\''.'\''||reservation_name||'\'' </sc-assigments> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM 
        `region-'$REGION'`.INFORMATION_SCHEMA.ASSIGNMENTS_BY_PROJECT
'

cd Output/
cd DDL/


sed -i ':a;N;$!ba;s/\n+/\n--+/g' *.sql
sed -i ':a;N;$!ba;s/+\n|/+\n--|/g' *.sql
sed -i ':a;N;$!ba;s/|\n|/\n/g' *.sql
sed -i ':a;N;$!ba;s/|\n/\n/g' *.sql
sed -i ':a;N;$!ba;s/Waiting/--Waiting/g' *.sql