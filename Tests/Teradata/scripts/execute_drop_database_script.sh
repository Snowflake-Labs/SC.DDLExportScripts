#
#####Version 20230810: Script created

#####Constants
MESSAGE='\033[0;32m' # Green
ERROR='\033[0;31m' # Red
NC='\033[0m' # No Color

#####Parameters
source_code_folder_name="$1"
if [ ! "$source_code_folder_name" ] || [ ! -d "../source_code/$source_code_folder_name/" ] ; then
   echo "${ERROR}Invalid parameter '$source_code_folder_name', options are [$(ls ../source_code)]${NC}"
   exit 1
fi

#####Import config variables
source config.sh

#####Commands
echo "${MESSAGE}Executing scripts in the Virtual Machine...${NC}"
ssh $vm_connection "cd /root/$source_code_folder_name && bash drop_database.sh $logon_command"