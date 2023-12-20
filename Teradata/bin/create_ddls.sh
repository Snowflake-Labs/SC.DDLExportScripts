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
mkdir -p ../output/object_extracts/Splits
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


##SPLIT FILES AND ORGANIZE INTO DATABASES BY OBJECT TYPE

echo 'Create Database Folders...'
cp ../output/object_extracts/DDL/DDL_Databases.sql ../output/object_extracts/DDL/DDL_Databases2.sql
[[ ! -f ../output/object_extracts/DDL/DDL_Databases2.sql ]]     || sed -i -e "s/CREATE DATABASE //g" -e "s|\sFROM.*||g" -e 's/.*/"&"/' ../output/object_extracts/DDL/DDL_Databases2.sql
cd ../output/object_extracts/
xargs mkdir -p < DDL/DDL_Databases2.sql
rm DDL/DDL_Databases2.sql

for dir in */; do 
  mkdir -- "$dir/Tables"; 
  mkdir -- "$dir/Views"; 
  mkdir -- "$dir/Join_Indexes"; 
  mkdir -- "$dir/Functions"; 
  mkdir -- "$dir/Macros"; 
  mkdir -- "$dir/Procedures"; 
  mkdir -- "$dir/Triggers"; 
done


echo 'Splitting...'

mkdir -p Splits/Tables
mkdir -p Splits/Views
mkdir -p Splits/Join_Indexes
mkdir -p Splits/Functions
mkdir -p Splits/Macros
mkdir -p Splits/Procedures
mkdir -p Splits/Triggers


echo '...Tables..'
cd Splits/Tables
SPLIT_TERM=sc-table
FILE=../../DDL/DDL_Tables.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 15-)
    DBNAME=$(grep -o -P '(?<=<sc-table> )(.*?)(?=\..* </sc-table>)' $file)
    mv $file ../../"$DBNAME"/Tables/"$FLNAME.sql"
done



echo '...Views..'
cd ../Views
SPLIT_TERM=sc-view
FILE=../../DDL/DDL_Views.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 14-)
    DBNAME=$(grep -o -P '(?<=<sc-view> )(.*?)(?=\..* </sc-view>)' $file)
    mv $file ../../"$DBNAME"/Views/"$FLNAME.sql"
done



echo '...Join Indexes..'
cd ../Join_Indexes
SPLIT_TERM=sc-joinindex
FILE=../../DDL/DDL_Join_Indexes.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 20-)
    DBNAME=$(grep -o -P '(?<=<sc-joinindex> )(.*?)(?=\..* </sc-joinindex>)' $file)
    mv $file ../../"$DBNAME"/Join_Indexes/"$FLNAME.sql"
done



echo '...Functions..'
cd ../Functions
SPLIT_TERM=sc-function
FILE=../../DDL/DDL_Functions.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 18-)
    DBNAME=$(grep -o -P '(?<=<sc-function> )(.*?)(?=\..* </sc-function>)' $file)
    mv $file ../../"$DBNAME"/Functions/"$FLNAME.sql"
done



echo '...Macros..'
cd ../Macros
SPLIT_TERM=sc-macro
FILE=../../DDL/DDL_Macros.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 15-)
    DBNAME=$(grep -o -P '(?<=<sc-macro> )(.*?)(?=\..* </sc-macro>)' $file)
    mv $file ../../"$DBNAME"/Macros/"$FLNAME.sql"
done



echo '...Procedures..'
cd ../Procedures
SPLIT_TERM=sc-procedure
FILE=../../DDL/DDL_Procedures.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 19-)
    DBNAME=$(grep -o -P '(?<=<sc-procedure> )(.*?)(?=\..* </sc-procedure>)' $file)
    mv $file ../../"$DBNAME"/Procedures/"$FLNAME.sql"
done



echo '...Triggers..'
cd ../Triggers
SPLIT_TERM=sc-trigger
FILE=../../DDL/DDL_Triggers.sql
csplit -f File_ -b "%07d.sql" -s $FILE /$SPLIT_TERM/ "{$(($(grep -c -- $SPLIT_TERM $FILE)-1))}"
rm File_0000000.sql

for file in File_*; do
    FLNAME=$(grep -o -P '.+?(?= <\/sc)' $file | cut -c 17-)
    DBNAME=$(grep -o -P '(?<=trigger> )(.*?)(?=\..* </sc-trigger>)' $file)
    mv $file ../../"$DBNAME"/Triggers/"$FLNAME.sql"
done


echo '...Cleaning Up Files'

cd ../../../../bin
mv ../output/object_extracts/DDL/DDL_Databases.sql ../output/DDL_Databases.sql
mv ../output/object_extracts/DDL/DDL_SF_Schemas.sql ../output/DDL_SF_Schemas.sql
rm -r ../output/object_extracts/DDL
rm -r ../output/object_extracts/Splits
rm -r ../temp
rm -r ../scripts

cd ../output/object_extracts
find . -type d -empty -delete

echo '...DDL Creation Complete'


