#
#Version 20201105: Script created
#Version 20211210: Updated to fix error messages 


##### Modify the connection information
connection_string="127.0.0.1/dbc,dbc"

##### Modify the condition for the databases and/or objects to include.  
##### You can change the operator 'LIKE ANY' to 'IN' or '=' 
##### Use uppercase names.
include_databases="(UPPER(T1.DATABASENAME) LIKE ANY ('%'))"

##### Modify the condition for the databases to exclude.  
##### Do not use the LIKE ANY in this condition if already used in the previous condition for include_databases
##### Use uppercase names.
exclude_databases="(UPPER(T1.DATABASENAME) NOT IN ('SYS_CALENDAR','ALL','CONSOLE','CRASHDUMPS','DBC','DBCMANAGER','DBCMNGR','DEFAULT','EXTERNAL_AP','EXTUSER','LOCKLOGSHREDDER','PDCRADM','PDCRDATA','PDCRINFO','PUBLIC','SQLJ','SYSADMIN','SYSBAR','SYSJDBC','SYSLIB','SYSSPATIAL','SYSTEMFE','SYSUDTLIB','SYSUIF','TD_SERVER_DB','TD_SYSFNLIB','TD_SYSFNLIB','TD_SYSGPL','TD_SYSXML','TDMAPS', 'TDPUSER','TDQCD','TDSTATS','TDWM','VIEWPOINT','PDCRSTG'))"

##### Modify the condition to include specific object names (tables/views/procedures.  
##### You can change the operator 'LIKE ANY' to 'IN' or '=' 
##### Use uppercase names.
include_objects="(UPPER(T1.TABLENAME) LIKE ANY ('%'))"


##### Creates directory for output and log files.
mkdir -p ../log
mkdir -p ../temp
mkdir -p ../output
mkdir -p ../output/object_extracts
mkdir -p ../output/object_extracts/DDL
mkdir -p ../output/object_extracts/Reports
mkdir -p ../output/object_extracts/Usage


##### Updates BTEQ files with the correct list of databases and connection info.
sed -i "s|include_databases|$include_databases|g" ../scripts/create_ddls.btq
sed -i "s|exclude_databases|$exclude_databases|g" ../scripts/create_ddls.btq
sed -i "s|include_objects|$include_objects|g" ../scripts/create_ddls.btq
sed -i "s|connection_string|$connection_string|g" ../scripts/create_ddls.btq

sed -i "s|include_databases|$include_databases|g" ../scripts/create_reports.btq
sed -i "s|exclude_databases|$exclude_databases|g" ../scripts/create_reports.btq
sed -i "s|include_objects|$include_objects|g" ../scripts/create_reports.btq
sed -i "s|connection_string|$connection_string|g" ../scripts/create_reports.btq

sed -i "s|include_databases|$include_databases|g" ../scripts/data_profiling.btq 
sed -i "s|exclude_databases|$exclude_databases|g" ../scripts/data_profiling.btq
sed -i "s|include_objects|$include_objects|g" ../scripts/data_profiling.btq
sed -i "s|connection_string|$connection_string|g" ../scripts/data_profiling.btq

sed -i "s|include_databases|$include_databases|g" ../scripts/invalid_objects.btq
sed -i "s|exclude_databases|$exclude_databases|g" ../scripts/invalid_objects.btq
sed -i "s|include_objects|$include_objects|g" ../scripts/invalid_objects.btq
sed -i "s|connection_string|$connection_string|g" ../scripts/invalid_objects.btq

sed -i "s|connection_string|$connection_string|g" ../scripts/create_usage_reports.btq

sed -i "s|include_databases|$include_databases|g" ../scripts/create_sample_inserts.btq
sed -i "s|exclude_databases|$exclude_databases|g" ../scripts/create_sample_inserts.btq
sed -i "s|include_objects|$include_objects|g" ../scripts/create_sample_inserts.btq
sed -i "s|connection_string|$connection_string|g" ../scripts/create_sample_inserts.btq


##### Executes DDL extracts and DDL Reports
echo 'Creating DDLS...'
bteq <../scripts/create_ddls.btq >../log/create_ddls.log 2>&1

[[ ! -f ../output/object_extracts/DDL/DDL_Tables.sql ]]         || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Tables.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Join_Indexes.sql ]]   || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Join_Indexes.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Views.sql ]]          || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Views.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Functions.sql ]]      || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Functions.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Macros.sql ]]         || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Macros.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Procedures.sql ]]     || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Procedures.sql
[[ ! -f ../output/object_extracts/DDL/DDL_SF_Schemas.sql ]]     || sed -i "s|    |\n|g" ../output/object_extracts/DDL/DDL_SF_Schemas.sql

[[ ! -f ../output/object_extracts/DDL/DDL_Tables.sql ]]         || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Tables.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Join_Indexes.sql ]]   || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Join_Indexes.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Views.sql ]]          || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Views.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Functions.sql ]]      || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Functions.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Macros.sql ]]         || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Macros.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Procedures.sql ]]     || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Procedures.sql

echo '...DDL Creation Complete'

echo "Creating Reports..."
bteq <../scripts/create_reports.btq >../log/create_reports.log 2>&1
[[ ! -f ../output/object_extracts/Reports/special_columns_list.txt ]] || sed -i "s|          | |g" ../output/object_extracts/Reports/special_columns_list.txt
echo "...Completed Reports"

echo "Profiling Key Data Types..."
bteq <../scripts/data_profiling.btq >../log/data_profiling.log 2>&1
[[ ! -f ../output/object_extracts/Reports/Data_Profile_Numbers.txt ]] || sed -i "s|-.*-||g" ../output/object_extracts/Reports/Data_Profile_Numbers.txt
echo "...Profiling Complete"

echo "Testing for invalid Views..."
bteq <../scripts/invalid_objects.btq >../output/object_extracts/invalid_objects.log 2>&1
echo "...Testing Completed"

##### Executes Creation of Usage Reports
echo "Creating Usage Reports..."
bteq <../scripts/create_usage_reports.btq >../log/create_usage_reports.log 2>&1
echo "...Completed Usage Reports"

##### Executes Creation of Insert Statements with Mock Data
echo "Creating Dummy Data Insert Statements..."
bteq <../scripts/create_sample_inserts.btq >../log/create_sample_inserts.log 2>&1
sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/insert_statements.sql
sed -i "s|    |\n|g" ../output/object_extracts/DDL/insert_statements.sql
echo "...Dummy Data Creation Completed"

rm ../temp/Invalid_Object_Test.sql
rm ../temp/SHOW_Tables.sql
rm ../temp/SHOW_Join_Indexes.sql
rm ../temp/NUMBER_COLUMNS.sql
rm ../temp/SHOW_Views.sql
rm ../temp/SHOW_Macros.sql
rm ../temp/SHOW_Procedures.sql
rm ../temp/SHOW_Functions.sql


