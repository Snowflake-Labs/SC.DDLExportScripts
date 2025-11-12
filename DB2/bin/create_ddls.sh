#!/bin/bash
VERSION="0.1.1"

# This script extracts DDLs from DB2 databases using the db2look utility.
# It generates DDL scripts for all databases listed in the DB2 directory,
# excluding those specified in the DATABASES_TO_EXCLUDE variable.
export versionParam=$1

if [ "$versionParam" = "--version" ]; then
    echo "You are using the $VERSION of the extraction scripts"
    exit 1
fi

echo "DB2 DDL Export script"
echo "Getting list of databases"
OUTPUTDIR="../object_extracts"
### Get List of Database

## You can modify this variable to exclude some databases:
## For example if you want to exclude database TESTDB just set:
## DATABASES_TO_EXCLUDE="TESTDB"
## If you want to exclude database TESTDB and database SAMPLE just set:
## DATABASES_TO_EXCLUDE="TESTDB|SAMPLE"
## You can use regular any valid regular expression as a pattern to exclude the databases to exclude
DATABASES_TO_EXCLUDE="XXXXXXX"

## DB Reports
SCHEMA_FILTER="%"

DDLS="$OUTPUTDIR/DDL"
REPORTS="$OUTPUTDIR/Reports"
mkdir -p $DDLS
mkdir -p $REPORTS
DBS=$( db2 list db directory | grep Indirect -B 5 |grep "Database alias" |awk {'print $4'} |sort -u | uniq 2>/dev/null | grep -v -E $DATABASES_TO_EXCLUDE)
for db in $DBS
do
    mkdir -p "$DDLS/$db"
    mkdir -p "$REPORTS/$db"
    echo "Processing Database $db"
    db2look -d $db -e -l > "$DDLS/$db/DDL_All.sql"

    ## Get REPORTS
    ## Get table volumetrics
    db2 "connect to $db"

    db2 "SELECT SUBSTR(TABSCHEMA,1,10) AS SCHEMA,  SUBSTR(TABNAME,1,15) AS TABNAME,
    INT(DATA_OBJECT_P_SIZE) AS OBJ_SZ_KB,
    INT(INDEX_OBJECT_P_SIZE) AS INX_SZ_KB,
    INT(XML_OBJECT_P_SIZE) AS XML_SZ_KB
    FROM  SYSIBMADM.ADMINTABINFO
    WHERE TABSCHEMA LIKE '%'
    ORDER BY 3 DESC;" > "$REPORTS/$db/volumetrics_per_object.txt"

    db2 "SELECT SUBSTR(TABSCHEMA,1,10) AS SCHEMA,  
    SUM(DATA_OBJECT_P_SIZE) AS OBJ_SZ_KB,
    SUM(INDEX_OBJECT_P_SIZE) AS INX_SZ_KB,
    SUM(XML_OBJECT_P_SIZE) AS XML_SZ_KB
    FROM    SYSIBMADM.ADMINTABINFO
    GROUP BY TABSCHEMA
    ORDER BY 2 DESC;"  > "$REPORTS/$db/volumetrics_per_database.txt"

### DATABASE SIZE

    db2 "CALL GET_DBSIZE_INFO(?,?,?,-1)" > "$REPORTS/$db/db_size.txt"

done




