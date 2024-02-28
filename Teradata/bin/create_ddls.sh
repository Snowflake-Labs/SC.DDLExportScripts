#
#Version 2020-11-05: Script created.
#Version 2021-12-10: Fix error messages. 
#Version 2023-08-11: Add command to copy the scripts from scripts_template.
#Version 2024-02-01: Add spliting mechanism for output code.
#Version 2024-02-23: Remove spliting mechanism for output code.
#Version 2024-02-27: Update output text with more detailed information about the execution.

##### PARAMETERS 
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

##### CONSTANTS 
steps="5"

function get_current_timestamp
{
    date '+%Y/%m/%d %l:%M:%S%p'
}

echo "[$(get_current_timestamp)] Info: Step 1/${steps} - Creating Directories: Started"
mkdir -p ../log
mkdir -p ../temp
mkdir -p ../output
mkdir -p ../output/object_extracts
mkdir -p ../output/object_extracts/DDL
cp -r ../scripts_template ../scripts
touch -- "../output/object_extracts/DDL/.sc_extracted"
echo "[$(get_current_timestamp)] Info: Step 1/${steps} - Creating Directories: Completed"


echo "[$(get_current_timestamp)] Info: Step 2/${steps} - Extracting DDLs: Started"
declare -a scripts_file=(
[0]="create_databases"
[1]="create_functions"
[2]="create_join_indexes"
[3]="create_macros" 
[4]="create_procedures" 
[5]="create_schemas" 
[6]="create_tables"
[7]="create_triggers"
[8]="create_views"
)

declare -a scripts_name=(
[0]="databases"
[1]="functions"
[2]="join indexes"
[3]="macros" 
[4]="procedures" 
[5]="schemas" 
[6]="tables"
[7]="triggers"
[8]="views"
)


for i in "${!scripts_file[@]}"; do
    echo "[$(get_current_timestamp)] Info: Start extracting ${scripts_name[$i]}"

    if [[ ! -f ../scripts/"${scripts_file[$i]}".btq ]]
    then
    echo "[$(get_current_timestamp)] ERROR: file ${scripts_file[$i]} not found"
    fi
    sed -i "s|include_databases|$include_databases|g" ../scripts/"${scripts_file[$i]}".btq
    sed -i "s|exclude_databases|$exclude_databases|g" ../scripts/"${scripts_file[$i]}".btq
    sed -i "s|include_objects|$include_objects|g" ../scripts/"${scripts_file[$i]}".btq
    sed -i "s|connection_string|$connection_string|g" ../scripts/"${scripts_file[$i]}".btq
    bteq <../scripts/"${scripts_file[$i]}".btq >../log/${scripts_file[$i]}.log 2>&1
    
    echo "[$(get_current_timestamp)] Info: Extracted ${scripts_name[$i]}"

done
echo "[$(get_current_timestamp)] Info: Step 2/${steps} - Extracting DDLs: Completed"


echo "[$(get_current_timestamp)] Info: Step 3/${steps} - Removing unnecessary comments: Started"
[[ ! -f ../output/object_extracts/DDL/DDL_Tables.sql ]]         || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Tables.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Join_Indexes.sql ]]   || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Join_Indexes.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Views.sql ]]          || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Views.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Functions.sql ]]      || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Functions.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Macros.sql ]]         || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Macros.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Procedures.sql ]]     || sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Procedures.sql
[[ ! -f ../output/object_extracts/DDL/DDL_SF_Schemas.sql ]]     || sed -i "s|    |\n|g" ../output/object_extracts/DDL/DDL_SF_Schemas.sql
echo "[$(get_current_timestamp)] Info: Step 3/${steps} - Removing unnecessary comments: Completed"

echo "[$(get_current_timestamp)] Info: Step 4/${steps} - Replacing unicode values: Started"
[[ ! -f ../output/object_extracts/DDL/DDL_Tables.sql ]]         || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Tables.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Join_Indexes.sql ]]   || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Join_Indexes.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Views.sql ]]          || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Views.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Functions.sql ]]      || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Functions.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Macros.sql ]]         || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Macros.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Procedures.sql ]]     || sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Procedures.sql
echo "[$(get_current_timestamp)] Info: Step 4/${steps} - Replacing unicode values: Completed"

echo "[$(get_current_timestamp)] Info: Step 5/${steps} - Removing temporal files: Started"
rm -r ../temp
rm -r ../scripts

echo "[$(get_current_timestamp)] Info: Step 5/${steps} - Removing temporal files: Completed"