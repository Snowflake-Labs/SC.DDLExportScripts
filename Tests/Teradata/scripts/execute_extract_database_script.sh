#
#Version 20230810: Script created

#####Constants
MESSAGE='\033[0;32m' # Green
ERROR='\033[0;31m' # Red
NC='\033[0m' # No Color
folder_name="Teradata_Extraction"

#####Parameters
# First: The database folder to be used.
# Second to n: The extraction parameters to be used, for example: 
# include_databases="(UPPER(T1.DATABASENAME) = 'SC_EXAMPLE_DEMO')" exclude_databases="(UPPER(T1.DATABASENAME) NOT IN ('SYS_CALENDAR','ALL','CONSOLE','CRASHDUMPS','DBC','DBCMANAGER','DBCMNGR','DEFAULT','EXTERNAL_AP','EXTUSER','LOCKLOGSHREDDER','PDCRADM','PDCRDATA','PDCRINFO','PUBLIC','SQLJ','SYSADMIN','SYSBAR','SYSJDBC','SYSLIB','SYSSPATIAL','SYSTEMFE','SYSUDTLIB','SYSUIF','TD_SERVER_DB','TD_SYSFNLIB','TD_SYSFNLIB','TD_SYSGPL','TD_SYSXML','TDMAPS', 'TDPUSER','TDQCD','TDSTATS','TDWM','VIEWPOINT','PDCRSTG'))"

source_code_folder_name="$1"
extracted_source_code_folder_name="$2"
if [ ! "$source_code_folder_name" ] || [ ! -d "../source_code/$source_code_folder_name/" ] ; then
   echo "${ERROR}Invalid parameter '$source_code_folder_name', options are [$(ls ../source_code)]${NC}"
   exit 1
fi
if [ ! "$extracted_source_code_folder_name" ] ; then
   echo "${ERROR}Invalid parameter '$extracted_source_code_folder_name', this value is the output folder name.${NC}"
   exit 1
fi


for ARGUMENT in "${@:3}"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

echo "${MESSAGE}Using the following extraction parameters:${NC}"
echo "include_databases = $include_databases"
echo "exclude_databases = $exclude_databases"
echo "include_objects = $include_objects"
echo "ddl_leng_max_limit_dic = $ddl_leng_max_limit_dic"
echo "ddl_leng_max_limit_dic = $ddl_leng_max_limit_dic"

#####Import config variables
echo "${MESSAGE}Importing connection variables...${NC}"
. config.sh

##### Commands
echo "${MESSAGE}Copying Teradata Script...${NC}"
cp -fr ../../../Teradata $folder_name
mkdir -p ../extracted_code/
rm -fr ../extracted_code/$extracted_source_code_folder_name


echo "${MESSAGE}Replacing Teradata Script parameters...${NC}"
sed -i '' "s/connection_string=/connection_string=${logon_command} #/g" $folder_name/bin/create_ddls.sh

#### Replace the variable include_databases, if it was defined in the imported script
if [ ! -z ${include_databases+x} ]; then 
sed -i '' "s/include_databases=/include_databases=\"${include_databases}\" #/g" $folder_name/bin/create_ddls.sh
fi

if [ ! -z ${exclude_databases+x} ]; then 
sed -i '' "s/exclude_databases=/exclude_databases=\"${exclude_databases}\" #/g" $folder_name/bin/create_ddls.sh
fi

if [ ! -z ${include_objects+x} ]; then 
sed -i '' "s/include_objects=/include_objects=\"${include_objects}\" #/g" $folder_name/bin/create_ddls.sh
fi

if [ ! -z ${ddl_leng_max_limit_dic+x} ]; then 
sed -i '' "s/ddl_leng_max_limit_dic=/ddl_leng_max_limit_dic=${ddl_leng_max_limit_dic} #/g" $folder_name/bin/create_ddls.sh
fi

echo "${MESSAGE}Removing previous execution output...${NC}"
rm -fr $folder_name/output
rm -fr $folder_name/log


echo "${MESSAGE}Sending Teradata scripts to the Virual Machine...${NC}"
scp -P $vm_ssh_port -r $folder_name $vm_connection:/root/sc_testing_folder/$folder_name
rm -fr $folder_name


echo "${MESSAGE}Executing scripts in the Virtual Machine...${NC}"
ssh $vm_connection -p $vm_ssh_port "cd /root/sc_testing_folder/$folder_name/bin && bash create_ddls.sh"


echo "${MESSAGE}Retrieving the output folder and removing the sent files...${NC}"
scp -r -OT -P $vm_ssh_port $vm_connection:"/root/sc_testing_folder/$folder_name/output /root/sc_testing_folder/$folder_name/log" ../extracted_code/$extracted_source_code_folder_name
ssh -q $vm_connection -p $vm_ssh_port rm -r /root/sc_testing_folder/$folder_name 
