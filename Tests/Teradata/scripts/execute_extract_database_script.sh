#
#Version 20230810: Script created

#####Constants
MESSAGE='\033[0;32m' # Green
ERROR='\033[0;31m' # Red
NC='\033[0m' # No Color
folder_name="Teradata_Extraction"

#####Parameters
source_code_folder_name="$1"
if [ ! "$source_code_folder_name" ] || [ ! -d "../source_code/$source_code_folder_name/" ] ; then
   echo "${ERROR}Invalid parameter '$source_code_folder_name', options are [$(ls ../source_code)]${NC}"
   exit 1
fi

#####Import config variables
source config.sh

##### Commands
echo "${MESSAGE}Copying Teradata Script...${NC}"
cp -fr ../../../Teradata $folder_name
cp ../source_code/$source_code_folder_name/extraction_parameters.sh $folder_name/bin/parameters.sh
sed -i '' "s/connection_string_value/${logon_command}/g" $folder_name/bin/parameters.sh
mkdir -p ../extracted_code/

echo "${MESSAGE}Removing previous execution output...${NC}"
rm -r $folder_name/output
rm -r $folder_name/log
rm -r ../extracted_code/$source_code_folder_name

echo "${MESSAGE}Sending Teradata scripts to the Virual Machine...${NC}"
scp -r $folder_name $vm_connection:/root/$folder_name
rm -r $folder_name

echo "${MESSAGE}Executing scripts in the Virtual Machine...${NC}"
ssh $vm_connection "cd /root/$folder_name/bin && bash create_ddls.sh"

echo "${MESSAGE}Retrieving the output folder and removing the sent files...${NC}"
scp -r -OT $vm_connection:"/root/$folder_name/output /root/$folder_name/log" ../extracted_code/$source_code_folder_name
ssh -q $vm_connection rm -r /root/$folder_name 
