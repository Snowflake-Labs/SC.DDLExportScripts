##VERSION @@VERSION##

##### Modify the connection information
connection_string="@@SERVER/@@USER,@@PASSWORD"

##### Modify the condition for the databases and/or objects to include.  
##### You can change the operator 'LIKE ANY' to 'IN' or '=' 
##### Use uppercase names.
include_databases="(UPPER(T1.DATABASENAME) LIKE ANY ('%'))"

##### Modify the condition for the databases to exclude.  
##### Do not use the LIKE ANY in this condition if already used in the previous condition for include_databases
##### Use uppercase names.
exclude_databases="(UPPER(T1.DATABASENAME) NOT IN ('SYS_CALENDAR','ALL','CONSOLE','CRASHDUMPS','DBC','DBCMANAGER','DBCMNGR','DEFAULT','EXTERNAL_AP','EXTUSER','LOCKLOGSHREDDER','PDCRADM','PDCRDATA','PDCRINFO','PUBLIC','SQLJ','SYSADMIN','SYSBAR','SYSJDBC','SYSLIB','SYSSPATIAL','SYSTEMFE','SYSUDTLIB','SYSUIF','SYSDBA','TD_SERVER_DB','TD_SYSFNLIB','TD_SYSFNLIB','TD_SYSGPL','TD_SYSXML','TDMAPS', 'TDPUSER','TDQCD','TDSTATS','TDWM','VIEWPOINT'))"

##### Modify the condition to include specific object names (tables/views/procedures.  
##### You can change the operator 'LIKE ANY' to 'IN' or '=' 
##### Use uppercase names.
include_objects="(UPPER(T1.TABLENAME) LIKE ANY ('%'))"

##### TPT Script Parameters
##### file_size_split_GB parameter tells TPT script at what size to begin separating a table's data into multiple files
##### There is no need to update any of these parameters unless you are planning to extract data from Teradata for loading to Snowflake.
file_size_split_GB="0.2"
tpt_delimiter="\|"  #Certain characters must be escaped with a backslash, such as pipe in order for the sed replace to work properly below
conn_str="@@SERVER"
conn_usr="@@USER"
conn_pwd="@@PASSWORD"

##### Creates directory for output and log files.
mkdir -p ../temp
mkdir -p ../output/log
mkdir -p ../output/object_extracts
mkdir -p ../output/object_extracts/SF_DDL
mkdir -p ../output/object_extracts/DDL
mkdir -p ../output/object_extracts/DDL/function
mkdir -p ../output/object_extracts/DDL/macro
mkdir -p ../output/object_extracts/DDL/procedure
mkdir -p ../output/object_extracts/DDLExtra
mkdir -p ../output/object_extracts/Reports
mkdir -p ../output/object_extracts/Usage
mkdir -p ../output/object_extracts/Exports
mkdir -p ../output/object_extracts/Exports/scripts 


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

sed -i "s|include_databases|$include_databases|g" ../scripts/create_tpt_script.btq 
sed -i "s|exclude_databases|$exclude_databases|g" ../scripts/create_tpt_script.btq
sed -i "s|include_objects|$include_objects|g" ../scripts/create_tpt_script.btq
sed -i "s|connection_string|$connection_string|g" ../scripts/create_tpt_script.btq
sed -i "s|file_size_split_GB|$file_size_split_GB|g" ../scripts/create_tpt_script.btq
sed -i "s|conn_str|$conn_str|g" ../scripts/create_tpt_script.btq
sed -i "s|conn_usr|$conn_usr|g" ../scripts/create_tpt_script.btq
sed -i "s|conn_pwd|$conn_pwd|g" ../scripts/create_tpt_script.btq
sed -i "s|tpt_delimiter|$tpt_delimiter|g" ../scripts/create_tpt_script.btq

sed -i "s|include_databases|$include_databases|g" ../scripts/create_sample_inserts.btq
sed -i "s|exclude_databases|$exclude_databases|g" ../scripts/create_sample_inserts.btq
sed -i "s|include_objects|$include_objects|g" ../scripts/create_sample_inserts.btq
sed -i "s|connection_string|$connection_string|g" ../scripts/create_sample_inserts.btq


##### Executes DDL extracts and DDL Reports
echo 'Creating DDLS...'
bteq <../scripts/create_ddls.btq >../output/log/create_ddls.log 2>&1
[ -f ../output/object_extracts/DDL/DDL_Tables.sql            ] && sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Tables.sql
[ -f ../output/object_extracts/DDL/DDL_Views.sql             ] && sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Views.sql
[ -f ../output/object_extracts/DDL/DDL_Functions.allsql      ] && sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Functions.allsql
[ -f ../output/object_extracts/DDL/DDL_Macros.allsql         ] && sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Macros.allsql
[ -f ../output/object_extracts/DDL/DDL_Procedures.allsql     ] && sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDL/DDL_Procedures.allsql
[ -f ../output/object_extracts/DDLExtra/DDL_Join_Indexes.sql ] && sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDLExtra/DDL_Join_Indexes.sql

## Process scripts for schemas
sed -i "s|    |\n|g" ../output/object_extracts/SF_DDL/DDL_SF_Schemas.sql

[ -f ../output/object_extracts/DDL/DDL_Tables.sql            ] && sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Tables.sql
[ -f ../output/object_extracts/DDL/DDL_Views.sql             ] && sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Views.sql
[ -f ../output/object_extracts/DDL/DDL_Functions.allsql      ] && sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Functions.allsql
[ -f ../output/object_extracts/DDL/DDL_Macros.allsql         ] && sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Macros.allsql
[ -f ../output/object_extracts/DDL/DDL_Procedures.allsql     ] && sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDL/DDL_Procedures.allsql
[ -f ../output/object_extracts/DDLExtra/DDL_Join_Indexes.sql ] && sed -i -e "s|\U2013|-|g" -e "s|\U00D8|0|g" -e "s|\U00A0| |g" -e "s|\U1680| |g" -e "s|\U180E| |g" -e "s|\U2000| |g" -e "s|\U2001| |g" -e "s|\U2002| |g" -e "s|\U2003| |g" -e "s|\U2004| |g" -e "s|\U2005| |g" -e "s|\U2006| |g" -e "s|\U2007| |g" -e "s|\U2008| |g" -e "s|\U2009| |g" -e "s|\U200A| |g" -e "s|\U200B| |g" -e "s|\U202F| |g" -e "s|\U205F| |g" -e "s|\U3000| |g" -e "s|\UFEFF| |g" ../output/object_extracts/DDLExtra/DDL_Join_Indexes.sql




## Split Functions / Macros and Procedures
sc-tera-split-ddl --inputfile ../output/object_extracts/DDL/DDL_Functions.allsql  --outdir ../output/object_extracts/DDL --duplicates ../output/object_extracts/DDLExtra/dup_function
sc-tera-split-ddl --inputfile ../output/object_extracts/DDL/DDL_Macros.allsql     --outdir ../output/object_extracts/DDL --duplicates ../output/object_extracts/DDLExtra/dup_macro
sc-tera-split-ddl --inputfile ../output/object_extracts/DDL/DDL_Procedures.allsql --outdir ../output/object_extracts/DDL --duplicates ../output/object_extracts/DDLExtra/dup_procedure
rm -f ../output/object_extracts/DDL/DDL_Functions.allsql
rm -f ../output/object_extracts/DDL/DDL_Macros.allsql
rm -f ../output/object_extracts/DDL/DDL_Procedures.allsql


echo '...DDL Creation Complete'

echo "Creating Reports..."
bteq <../scripts/create_reports.btq >../output/log/create_reports.log 2>&1
sed -i "s|          | |g" ../output/object_extracts/Reports/special_columns_list.txt
echo "...Completed Reports"

echo "Profiling Key Data Types..."
bteq <../scripts/data_profiling.btq >../output/log/data_profiling.log 2>&1
sed -i "s|-.*-||g" ../output/object_extracts/Reports/Data_Profile_Numbers.txt
echo "...Profiling Complete"

echo "Testing for invalid Views..."
bteq <../scripts/invalid_objects.btq >../output/object_extracts/invalid_objects.log 2>&1
echo "...Testing Completed"

##### Executes Creation of Usage Reports
echo "Creating Usage Reports..."
bteq <../scripts/create_usage_reports.btq >../output/log/create_usage_reports.log 2>&1
echo "...Completed Usage Reports"

##### Executes Creation of TPT Scripts
echo "Creating TPT Scripts..."
bteq <../scripts/create_tpt_script.btq >../output/log/create_tpt_script.log 2>&1
sed -i "s|--------------.*--------------||g" ../output/object_extracts/Exports/tpt_export_single_script.tpt
sed -i "s|--------------.*--------------||g" ../output/object_extracts/Exports/tpt_export_multiple_scripts.tpt
sed -i "s|    |\n|g" ../output/object_extracts/Exports/tpt_export_single_script.tpt
sed -i "s|    |\n|g" ../output/object_extracts/Exports/tpt_export_multiple_scripts.tpt
csplit -n 3  -s -f outfile -z ../output/object_extracts/Exports/tpt_export_multiple_scripts.tpt "/**** END JOB ****/+1" "{*}"
mv -f outfile* ../output/object_extracts/Exports/scripts
sed -i "s|\/\* Begin Script \*\/||g" ../output/object_extracts/Exports/scripts/outfile000;


for file in ../output/object_extracts/Exports/scripts/*
do
  sed -i "s|\/\*\*\*\* BEGIN JOB \*\*\*\*\/||g" $file;
  sed -i '/^[[:space:]]*$/d' $file;
  line=$(head -n 1 $file);
  fname=${line:26};
  mv "$file" "../output/object_extracts/Exports/scripts/${fname}.tpt";  
done
echo "...TPT Script Creation Completed"

##### Executes Creation of Insert Statements with Mock Data
echo "Creating Dummy Data Insert Statements..."
bteq <../scripts/create_sample_inserts.btq >../output/log/create_sample_inserts.log 2>&1
sed -i "s|--------------.*--------------||g" ../output/object_extracts/DDLExtra/insert_statements.sql
sed -i "s|    |\n|g" ../output/object_extracts/DDLExtra/insert_statements.sql
echo "...Dummy Data Creation Completed"

##### Commands in the section below will run the consolidated single TPT script generated to 
##### export all table data. Uncomment with caution!!
#mkdir -p ../output/data_extracts
#mkdir -p ../output/data_extracts/lob_files
#echo "Creating Data Files..."
#tbuild -f ../output/object_extracts/Exports/tpt_export_single_script.tpt -C >../output/log/tpt_export_script.log
#for file in ../output/data_extracts/*
#do 
#	sed -i "s|XZX_EMPTY_XZX *|''|g" $file;
#	sed -i "s|XZX_CHARS_XZX||g" $file;
#done
#echo "...Data File Creation Complete"


##### Commands in the section below will run the individual TPT scripts generated in the section above to 
##### export all table data. Uncomment with caution!!
#mkdir -p ../output/data_extracts
#mkdir -p ../output/data_extracts/lob_files
#echo "Creating Data Files..."
#for file in ../output/object_extracts/Exports/scripts/*
#do
#  line=$(head -n 1 $file);
#  fname=${line:26};
#  tbuild -f $file -C >../output/log/${fname}.log
#done
#for file in ../output/data_extracts/*
#do 
#	sed -i "s|XZX_EMPTY_XZX *|''|g" $file;
#	sed -i "s|XZX_CHARS_XZX||g" $file;
#done
#echo "...Data File Creation Complete"

rm ../temp/Invalid_Object_Test.sql
rm ../temp/SHOW_Tables.sql
rm ../temp/SHOW_Join_Indexes.sql
rm ../temp/NUMBER_COLUMNS.sql
rm ../temp/SHOW_Views.sql
rm ../temp/SHOW_Macros.sql
rm ../temp/SHOW_Procedures.sql