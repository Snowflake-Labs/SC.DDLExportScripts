#
#Version 20201105: Script created
#Version 20211210: Fix error messages 
#Version 20230811: Add command to copy the scripts from scripts_template.
#Version 20240201: Add spliting mechanism for output code.

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

##### Creates directory for output and log files.
mkdir -p ../log
mkdir -p ../temp
mkdir -p ../output
mkdir -p ../output/object_extracts
mkdir -p ../output/object_extracts/DDL
mkdir -p ../output/object_extracts/Splits
cp -r ../scripts_template ../scripts
touch -- "../output/object_extracts/DDL/.sc_extracted"

##### Updates BTEQ files with the correct list of databases and connection info.
sed -i "s|include_databases|$include_databases|g" ../scripts/create_ddls.btq
sed -i "s|exclude_databases|$exclude_databases|g" ../scripts/create_ddls.btq
sed -i "s|include_objects|$include_objects|g" ../scripts/create_ddls.btq
sed -i "s|connection_string|$connection_string|g" ../scripts/create_ddls.btq

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


##SPLIT FILES AND ORGANIZE INTO DATABASES BY OBJECT TYPE

echo 'Create Database Folders...'
cp ../output/object_extracts/DDL/DDL_Databases.sql ../output/object_extracts/DDL/DDL_Databases2.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Databases2.sql ]]     || sed -i -e "s/CREATE DATABASE //g" -e "s|\sFROM.*||g" -e 's/.*/"&"/' ../output/object_extracts/DDL/DDL_Databases2.sql
cd ../output/object_extracts/
xargs mkdir -p < DDL/DDL_Databases2.sql
rm DDL/DDL_Databases2.sql

for dir in */; do 
  mkdir -- "$dir/table"; 
  mkdir -- "$dir/view"; 
  mkdir -- "$dir/joinindex"; 
  mkdir -- "$dir/function"; 
  mkdir -- "$dir/macro"; 
  mkdir -- "$dir/procedure"; 
  mkdir -- "$dir/trigger"; 
  mkdir -- "$dir/schema"; 
  mkdir -- "$dir/unknown"; 
done


echo 'Splitting...'

mkdir -p Splits/table
mkdir -p Splits/view
mkdir -p Splits/joinindex
mkdir -p Splits/function
mkdir -p Splits/macro
mkdir -p Splits/procedure
mkdir -p Splits/trigger
mkdir -p Splits/schema
mkdir -p Splits/unknown


echo '...Tables..'
cd Splits/table
SPLIT_TERM=sc-table
FILE=../../DDL/DDL_Tables.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 15-)
    DBNAME=$(grep -o -P '(?<=<sc-table> )(.*?)(?=\..* </sc-table>)' $file)
    FLNAME=${FLNAME/$DBNAME\./}
    mkdir -p ../../table/"$DBNAME"
    mv $file ../../table/"$DBNAME"/"$FLNAME.sql"
done



echo '...Views..'
cd ../view
SPLIT_TERM=sc-view
FILE=../../DDL/DDL_Views.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 14-)
    DBNAME=$(grep -o -P '(?<=<sc-view> )(.*?)(?=\..* </sc-view>)' $file)
    FLNAME=${FLNAME/$DBNAME\./}
    mkdir -p ../../view/"$DBNAME"
    mv $file ../../view/"$DBNAME"/"$FLNAME.sql"
done



echo '...Join Indexes..'
cd ../joinindex
SPLIT_TERM=sc-joinindex
FILE=../../DDL/DDL_Join_Indexes.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 19-)
    DBNAME=$(grep -o -P '(?<=<sc-joinindex> )(.*?)(?=\..* </sc-joinindex>)' $file)
    FLNAME=${FLNAME/$DBNAME\./}
    mkdir -p ../../joinindex/"$DBNAME"
    mv $file ../../joinindex/"$DBNAME"/"$FLNAME.sql"
done



echo '...Functions..'
cd ../function
SPLIT_TERM=sc-function
FILE=../../DDL/DDL_Functions.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 18-)
    DBNAME=$(grep -o -P '(?<=<sc-function> )(.*?)(?=\..* </sc-function>)' $file)
    FLNAME=${FLNAME/$DBNAME\./}
    mkdir -p ../../function/"$DBNAME"
    mv $file ../../function/"$DBNAME"/"$FLNAME.sql"
done



echo '...Macros..'
cd ../macro
SPLIT_TERM=sc-macro
FILE=../../DDL/DDL_Macros.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 15-)
    DBNAME=$(grep -o -P '(?<=<sc-macro> )(.*?)(?=\..* </sc-macro>)' $file)
    FLNAME=${FLNAME/$DBNAME\./}
    mkdir -p ../../macro/"$DBNAME"
    mv $file ../../macro/"$DBNAME"/"$FLNAME.sql"
done



echo '...Procedures..'
cd ../procedure
SPLIT_TERM=sc-procedure
FILE=../../DDL/DDL_Procedures.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 19-)
    DBNAME=$(grep -o -P '(?<=<sc-procedure> )(.*?)(?=\..* </sc-procedure>)' $file)
    FLNAME=${FLNAME/$DBNAME\./}
    mkdir -p ../../procedure/"$DBNAME"
    mv $file ../../procedure/"$DBNAME"/"$FLNAME.sql"
done



echo '...Triggers..'
cd ../trigger
SPLIT_TERM=sc-trigger
FILE=../../DDL/DDL_Trigger.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 17-)
    DBNAME=$(grep -o -P '(?<=trigger> )(.*?)(?=\..* </sc-trigger>)' $file)
    FLNAME=${FLNAME/$DBNAME\./}
    mkdir -p ../../trigger/"$DBNAME"
    mv $file ../../trigger/"$DBNAME"/"$FLNAME.sql"
done

echo '...Schemas..'
cd ../schema
SPLIT_TERM=sc-schema
FILE=../../DDL/DDL_SF_Schemas.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 15-)

    mkdir -p ../../schema/NO_SCHEMA
    mv $file ../../schema/NO_SCHEMA/"$FLNAME.sql"
done

echo '...Cleaning Up Files'

cd ../../../../bin
mkdir -p ../output/object_extracts/unknown/NO_SCHEMA
mv ../output/object_extracts/DDL/DDL_Databases.sql ../output/object_extracts/unknown/NO_SCHEMA/DDL_Databases.sql
rm -r ../output/object_extracts/DDL
rm -r ../output/object_extracts/Splits
rm -r ../temp
rm -r ../scripts

cd ../output/object_extracts
find . -type d -empty -delete

echo '...DDL Creation Complete'


