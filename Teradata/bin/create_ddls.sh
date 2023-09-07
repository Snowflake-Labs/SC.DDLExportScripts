#
#Version 20201105: Script created
#Version 20211210: Updated to fix error messages 
#Version 20230811: Added command to copy the scripts from scripts_template.


##### Modify the connection information
connection_string="dbc,dbc"

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

###### Constant ddl_leng, max limit in dictionary table is 12500.
ddl_leng_max_limit_dic=12400

##### Creates directory for output and log files.
mkdir -p ../log
mkdir -p ../temp
mkdir -p ../output
mkdir -p ../output/object_extracts
mkdir -p ../output/object_extracts/DDL
cp -r ../scripts_template ../scripts

##### Updates BTEQ files with the correct list of databases and connection info.
sed -i "s|include_databases|$include_databases|g" ../scripts/create_ddls.btq
sed -i "s|exclude_databases|$exclude_databases|g" ../scripts/create_ddls.btq
sed -i "s|include_objects|$include_objects|g" ../scripts/create_ddls.btq
sed -i "s|connection_string|$connection_string|g" ../scripts/create_ddls.btq
sed -i "s|ddl_leng_max_limit_dic|$ddl_leng_max_limit_dic|g" ../scripts/create_ddls.btq

##### Executes DDL extracts and DDL Reports
echo 'Creating DDLS...'
bteq <../scripts/create_ddls.btq >../log/create_ddls.log 2>&1

echo 'Removing unnecessary comments...'
[[ ! -f ../output/object_extracts/DDL/DDL_Tables.sql ]]         || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Tables.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Join_Indexes.sql ]]   || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Join_Indexes.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Views.sql ]]          || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Views.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Functions.sql ]]      || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Functions.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Macros.sql ]]         || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Macros.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Procedures.sql ]]     || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Procedures.sql
[[ ! -f ../output/object_extracts/DDL/DDL_SF_Schemas.sql ]]     || sed -i "s|    |\n|g" ../output/object_extracts/DDL/DDL_SF_Schemas.sql

echo 'Replacing unicode values...'
[[ ! -f ../output/object_extracts/DDL/DDL_Tables.sql ]]         || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Tables.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Join_Indexes.sql ]]   || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Join_Indexes.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Views.sql ]]          || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Views.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Functions.sql ]]      || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Functions.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Macros.sql ]]         || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Macros.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Procedures.sql ]]     || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Procedures.sql

echo '...DDL Creation Complete'

rm -r ../temp
rm -r ../scripts


