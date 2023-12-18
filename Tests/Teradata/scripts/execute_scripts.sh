#
#####Constants
STEP_MESSAGE='\033[0;34m' # Green
ERROR='\033[0;31m' # Red
NC='\033[0m' # No Color

#####Parameters
##### 1 - Source code folder name
##### 2 - Extracted code folder name
##### 3 to n - Extraction parameters in the following format key="value" 

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
   extraction_parameters="$extraction_parameters \"$ARGUMENT\""
done

echo "${STEP_MESSAGE}Step 1/3 Deplying database...${NC}"
source execute_deploy_database_script.sh $source_code_folder_name
echo "${STEP_MESSAGE}Step 2/3 Extracting database...${NC}"
eval "source execute_extract_database_script.sh $source_code_folder_name $extracted_source_code_folder_name $extraction_parameters"
echo "${STEP_MESSAGE}Step 3/3 Removing database...${NC}"
source execute_drop_database_script.sh $source_code_folder_name
