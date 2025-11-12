#!/bin/bash
VERSION="0.1.1"

# This script extracts DDLs from Hive databases using Beeline or Hive CLI.
# It connects to a Hive server and retrieves the DDL statements for all tables and views in specified databases.
# The output is written to a CSV file and individual SQL files for each database.

# Function to generate sc_extraction_script header comment
generate_header_comment() {
    local current_date=$(date '+%Y-%m-%d %H:%M:%S')
    local language_name="Hive DDL"
    echo "-- <sc_extraction_script> ${language_name} code extracted using script version ${VERSION} on ${current_date} <sc_extraction_script>"
} 
export versionParam=$1

if [ "$versionParam" = "--version" ]; then
    echo "You are using the $VERSION of the extraction scripts"
    exit 1
fi

# --------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT CUSTOMIZATION
#    HOST
#        The host name of the server where Hive is running used to make a JDBC connection.
#
#        Default: localhost
#
#    PORT
#        Port of the server where Hive is running used to make a JDBC connection.
#
#        Default: 10000
#
#    databasefilter
#        Hive database name to filter for DDL extraction. Hive <4.0 use * (asterisk) and Hive >=4.0 use % (percent)
#        for wildcard. May also be explicit database name or wildcard for all databases in system.
#
#        For example:
#            Hive <4:  "db*" or "*db*" or "my_db" (no wildcard) or * (all databases)
#            Hive >=4: "db%" or "%db%" or "my_db" (no wildcard) or % (all databases)
#        See https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL#LanguageManualDDL-ShowDatabases
#
#        Default: * (Hive <4.0 support)
#
#    root
#        Name of folder to be created in the same path as the extraction script where output files will be written.
# --------------------------------------------------------------------------------------------------------------------

HOST=localhost # Update as required
PORT=10000 # Update as reuqired
databasefilter="%" # Hive database name to filter for DDL extraction. Hive <4.0 use * and Hive >=4.0 use % wildcard
root="ddl_extract" # Folder name created below where script executes to store output

# --------------------------------------------------------------------------------------------------------------------
# HIVE EXTRACTION COMMAND OPTIONS
#    Beeline connection through JDBC is preferred. If beeline is not available, hive may be used directly from
#    the server.
# --------------------------------------------------------------------------------------------------------------------

hivecmd="beeline -u jdbc:hive2://${HOST}:${PORT} --showHeader=false --outputformat=tsv2 -e " # Use beeline CLI (preferred)
#hivecmd="hive -e" # Use hive CLI (fallback)

# --------------------------------------------------------------------------------------------------------------------
# EXTRACTION ROUTINE
#    Customization not rueqired for this section. Do NOT make changes unless there is a extraction error due to
#    unique system configuration.
# --------------------------------------------------------------------------------------------------------------------

current_time=$(date "+%Y%m%d%-H%-M%-S")
csv="${root}/all_objects.${current_time}.csv"  #master list of all tables/views found

mkdir -p ${root}
echo "database,object_name,object_type,size_in_bytes,hdfs_location,serde,inputformat,outputformat" >$csv

set -f #turn off expansion for wildcard
databases=$(${hivecmd} "show databases like '${databasefilter}';")
set +f  #turn on expansion for wildcard

all_db_names=${databases}

for db in $all_db_names
do
  expfile=$root/${db}.sql
  
  tables=$(${hivecmd} "show tables in ${db};")
  all_tab_names=`echo "${tables}"`
  
  if [ ! -z "${all_tab_names}" ]
  then
  	# Initialize file with sc_extraction_script header comment
  	generate_header_comment > $expfile
  	echo "" >> $expfile
  	echo " /****  Start DDLs for Tables in ${db} ****/ " >> $expfile
  fi
  
   for table in $all_tab_names
    do
      sql="show create table ${db}.${table};"
      echo " ====== Running SHOW CREATE TABLE Statement for $db.${table} ======= : "
      results=`${hivecmd} "use ${db}; $sql"` 
      loc=$(echo "$results" | awk -F 'LOCATION' '{print $2}' | awk '{print $1;}' | awk -F '/' '{for (i=4; i<NF; i++) printf $i "/"; printf $NF}') 
      loc=$(echo "${loc}" |  sed s/\'//g)
      serde=$(echo "$results" | awk -F 'ROW FORMAT SERDE' '{print $2}' | awk '{print $1;}')
      inputformat=$(echo "$results" | awk -F 'STORED AS INPUTFORMAT' '{print $2}' | awk '{print $1;}')
      outputformat=$(echo "$results" | awk -F 'OUTPUTFORMAT' '{print $2}' | awk '{print $1;}')
      if [[ -z "${loc// }" ]]; then  #check if location is found
        size="0"
      else
        echo "LOCATION=$loc"
        size=$(hdfs dfs -du -s -h /${loc} | awk '{print $1}') #find size of files in HDFS
        echo "size=${size}" 
      fi

      objtype="TABLE"
      if [[ "$results" == *"CREATE VIEW"* ]]; then
        objtype="VIEW"
      fi
      echo "${results}; "  >> $expfile
      echo "" >> $expfile
      echo "${db},${table},${objtype},${size},${loc},${serde},${inputformat},${outputformat}" >>$csv
    done
  
  if [ ! -z "${all_tab_names}" ]
  then
	echo " /****  End DDLs for Tables in ${db} ****/ " >> $expfile
  fi
done