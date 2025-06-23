Write-Output "DB2 DDL Export script"
Write-Output "Getting list of databases"
$OUTPUTDIR = "../object_extracts"
### Get List of Database

## You can modify this variable to exclude some databases:
## For example if you want to exclude database TESTDB just set:
## DATABASES_TO_EXCLUDE=@("TESTDB")
## If you want to exclude database TESTDB and database SAMPLE just set:
## DATABASES_TO_EXCLUDE=@("TESTDB","SAMPLE")
## You can use regular any valid regular expression as a pattern to exclude the databases to exclude
$DATABASES_TO_EXCLUDE = @()
## DB Reports
$SCHEMA_FILTER = "%"

$DDLS = "$OUTPUTDIR/DDL"
$REPORTS = "$OUTPUTDIR/Reports"

IF (-Not (Test-Path "$DDLS")) { mkdir -p "$DDLS" }
IF (-Not (Test-Path "$REPORTS")) { mkdir -p $REPORTS }
## Get list of databases 
$lines = (db2 list db directory) | ForEach-Object { "$_" }
$DBS = $lines | Where-Object { $_ -match "Database alias" } | ForEach-Object { $_.Split("=")[1].Trim() } |  Where-Object { $_ -notin $DATABASES_TO_EXCLUDE }
Write-Output "Output Directory: $OUTPUTDIR"
Foreach ($db in $DBS) {
    IF (-Not (Test-Path "$DDLS/$db")) { mkdir -p "$DDLS/$db" }
    IF (-Not (Test-Path "$REPORTS/$db")) { mkdir -p "$REPORTS/$db" }

    Write-Output "Processing Database $db"
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

}




