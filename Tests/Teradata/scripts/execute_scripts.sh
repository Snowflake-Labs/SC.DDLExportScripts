#
#####Constants
STEP_MESSAGE='\033[0;34m' # Green
ERROR='\033[0;31m' # Red
NC='\033[0m' # No Color

#####Parameters
source_code_folder_name="$1"
if [ ! "$source_code_folder_name" ] || [ ! -d "../source_code/$source_code_folder_name/" ] ; then
   echo "${ERROR}Invalid parameter '$source_code_folder_name', options are [$(ls ../source_code)]${NC}"
   exit 1
fi

echo "${STEP_MESSAGE}Step 1/3 Deplying database...${NC}"
source execute_deploy_database_script.sh $source_code_folder_name
echo "${STEP_MESSAGE}Step 2/3 Extracting database...${NC}"
source execute_extract_database_script.sh $source_code_folder_name
echo "${STEP_MESSAGE}Step 3/3 Removing database...${NC}"
source execute_drop_database_script.sh $source_code_folder_name