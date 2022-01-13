#!/bin/bash

REGION='us'

echo " "
echo " +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+"
echo " |B|i|g|Q|u|e|r|y| |E|x|p|o|r|t| |b|y| |M|o|b|i|l|i|z|e|.|N|e|t|"
echo " +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+"
echo " Version 1.0"
echo " +-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+"
echo " "


echo "Extracting DDLs from region $REGION"
echo "Creating Output Folder..."

mkdir -p Output
cd Output/
mkdir -p DDL
cd ..
echo "Extracting DDLs..."

# -----------------   EXTRACT SCHEMAS   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Schema.sql 2>&1

./google-cloud-sdk/bin/bq query --use_legacy_sql=false \
'
    SELECT
        '\''/* <sc-schema> '\''||catalog_name||'\''.'\''||schema_name||'\'' </sc-schema> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM 
        `region-'$REGION'`.INFORMATION_SCHEMA.SCHEMATA
'

# -----------------   EXTRACT TABLES   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Tables.sql 2>&1

./google-cloud-sdk/bin/bq query --use_legacy_sql=false \
'
    SELECT
        '\''/* <sc-'\''||lower(table_type)||'\''> '\''||table_catalog||'\''.'\''||table_schema||'\''.'\''||table_name||'\'' </sc-'\''||lower(table_type)||'\''> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM
        `region-'$REGION'`.INFORMATION_SCHEMA.TABLES
	WHERE
		table_type = '\''BASE TABLE'\''
'

# -----------------   EXTRACT EXTERNAL TABLES   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_External_Tables.sql 2>&1

./google-cloud-sdk/bin/bq query --use_legacy_sql=false \
'
    SELECT
        '\''/* <sc-'\''||lower(table_type)||'\''> '\''||table_catalog||'\''.'\''||table_schema||'\''.'\''||table_name||'\'' </sc-'\''||lower(table_type)||'\''> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM
        `region-'$REGION'`.INFORMATION_SCHEMA.TABLES
	WHERE
		table_type = '\''EXTERNAL TABLE'\''
'

# -----------------   EXTRACT VIEWS   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Views.sql 2>&1

./google-cloud-sdk/bin/bq query --use_legacy_sql=false \
'
    SELECT
        '\''/* <sc-'\''||lower(table_type)||'\''> '\''||table_catalog||'\''.'\''||table_schema||'\''.'\''||table_name||'\'' </sc-'\''||lower(table_type)||'\''> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM
        `region-'$REGION'`.INFORMATION_SCHEMA.TABLES
	WHERE
		table_type = '\''VIEW'\''
'

# -----------------   EXTRACT FUNCTIONS   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Functions.sql 2>&1

./google-cloud-sdk/bin/bq query --use_legacy_sql=false \
'
    SELECT
        '\''/* <sc-'\''||lower(routine_type)||'\''> '\''||specific_catalog||'\''.'\''||specific_schema||'\''.'\''||specific_name||'\'' </sc-'\''||lower(routine_type)||'\''> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM  
        `region-'$REGION'`.INFORMATION_SCHEMA.ROUTINES
	WHERE
		routine_type = '\''FUNCTION'\''
'

# -----------------   EXTRACT PROCEDURES   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Procedures.sql 2>&1

./google-cloud-sdk/bin/bq query --use_legacy_sql=false \
'
    SELECT
        '\''/* <sc-'\''||lower(routine_type)||'\''> '\''||specific_catalog||'\''.'\''||specific_schema||'\''.'\''||specific_name||'\'' </sc-'\''||lower(routine_type)||'\''> */'\''||'\''\n\n'\''||ddl||'\''\n\n'\'' DDLs
    FROM  
        `region-'$REGION'`.INFORMATION_SCHEMA.ROUTINES
	WHERE
		routine_type = '\''PROCEDURE'\''
'

# -----------------   EXTRACT RESERVATIONS   ---------------------------------------------------------------------------------------------------

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>Output/DDL/DDL_Reservations.sql 2>&1

./google-cloud-sdk/bin/bq query --use_legacy_sql=false \
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

./google-cloud-sdk/bin/bq query --use_legacy_sql=false \
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

./google-cloud-sdk/bin/bq query --use_legacy_sql=false \
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

