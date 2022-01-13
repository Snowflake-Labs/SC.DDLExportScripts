#!/bin/bash

#use one of the 2 CLI clients below to connect
#adjust arguments below to connect to your environment, using username,password or keytab

HOST=localhost
PORT=10000

#hivecmd="hive -e"  #use HIVE CLI
hivecmd="beeline -u jdbc:hive2://${HOST}:${PORT} --showHeader=false --outputformat=tsv2 -e " #use beeline CLI

root="ddl_extract" #folder created below where script executes
databasefilter="*"  #HIVE DATABASE name FILTER.  use * for wildcard. example: *db*
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
  	echo " " > $expfile
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
