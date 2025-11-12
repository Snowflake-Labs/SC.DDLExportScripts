# GENERAL INSTRUCTIONS: This script is used to extract object DDL from your RedShift Cluster. Please adjust the variables with enclosed by <>
#                       below to match your environment. Once completed, your extracted DDL code will be stored in the object_extracts folder.

# Script version
VERSION="0.1.0"

# ---- Variables to change ----

# General Variables
OUTPUT_PATH="/example/path"

# AWS RedShift Variables
RS_CLUSTER="<redshift_cluster_identifier>"
RS_DATABASE="<redshift_database>"
RS_SECRET_ARN="<secret_arn>"

#Script Variables
SCHEMA_FILTER="lower(schemaname) LIKE '%'"
MAX_ITERATIONS=60 #Every iteration waits 5 seconds. Must be > 0.
# ---- END: Variables to change ----

OUTPUT_PATH="${OUTPUT_PATH/%\//}"

# Validate if max iterations value is valid
if [ $MAX_ITERATIONS -lt 0 ]
then
  MAX_ITERATIONS=60
  echo "Detected iterations less than 0. Setting to 60."
fi

# Check if AWS Cli exists
hash aws &> /dev/null
if [ $? -eq 1 ]; then
    echo >&2 "AWS Cli not found. Please check this link on how to install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

echo "Creating output folders..."

ddl_output=$OUTPUT_PATH/object_extracts/DDL
log_output=$OUTPUT_PATH/log
temp_output=$OUTPUT_PATH/temp

mkdir -p "$ddl_output"
mkdir -p "$log_output"
mkdir -p "$temp_output"
mkdir -p "$OUTPUT_PATH/object_extracts"
mkdir -p "$OUTPUT_PATH/object_extracts/DDL"
touch -- "${OUTPUT_PATH}/object_extracts/DDL/.sc_extracted"

# Create log files and tracking variables
echo "--------------" >> "$log_output/log.txt"
echo "Starting new extraction" >> "$log_output/log.txt"
echo "Variables:" >> "$log_output/log.txt"
echo "$OUTPUT_PATH" >> "$log_output/log.txt"
echo "$SCHEMA_FILTER" >> "$log_output/log.txt"

# Define main variables
cd ../scripts/
echo "Getting queries from files..."
files=$(ls *.sql)
declare -a queries
i=0

echo "Sending queries to execute..."
for f in $files
do
  # Read queries from scripts folder
  query=$(<$f)
  # Replace {schema_filter} in the query template
  final_query="${query/\{schema_filter\}/$SCHEMA_FILTER}"
  # Execute query
  response=$(aws redshift-data execute-statement --cluster-identifier $RS_CLUSTER --database $RS_DATABASE --secret-arn $RS_SECRET_ARN --sql "$final_query" --output yaml 2>&1)
  if [ $? -ne 0 ]
  then
    # Log and print if there is an error
    echo $response | tee -a "$log_output/log.txt"
  else
    # Extract Id from response
    re="Id: ([[:xdigit:]]{8}(-[[:xdigit:]]{4}){3}-[[:xdigit:]]{12})"
    [[ $response =~ $re ]] && queries[$i]="$f=${BASH_REMATCH[1]}"
    i=$((i+1))
  fi
done

if [ ${#queries[@]} -eq 0 ]
then
  echo "Unable to send queries to execute. Please make sure that the connection to AWS is properly configured and that the connection parameters are correct."
  exit 1
fi

echo "Waiting 20 seconds for queries to finish..."
sleep 20

echo "Starting query validation and extraction iterations..."
i=0
while [ $i -ne  $MAX_ITERATIONS ]
do
  i=$((i+1))
  if [ ${#queries[@]} -ne 0 ]
  then
    # List to remove queries from queries list for next iteration when finished
    to_remove=()
    for query in "${queries[@]}"
    do
      # Split value from array
      IFS='='
      read -ra parts <<< "$query"
      echo "Validating completion for query ${parts[0]}..."
      statement_response=$(aws redshift-data describe-statement --id ${parts[1]} --output yaml)
      # Get statement status
      re="Status: ([a-zA-Z]*)"
      [[ $statement_response =~ $re ]] && status="${BASH_REMATCH[1]}"
	    if [ "$status" = "FINISHED" ]
      then
        echo "Query finished, starting extraction..."
        # Extract query result into file
        aws redshift-data get-statement-result --id ${parts[1]} --output text > "$temp_output/${parts[0]}"
        # Clean output (remove first 2 lines and prefix for RECORDS keyword
        sed -e 1,2d "$temp_output/${parts[0]}" > "$temp_output/${parts[0]}.clean"
        perl -i -pe 's/^RECORDS\s//g' "$temp_output/${parts[0]}.clean"
        # Add comment header to the final file
        echo "-- <sc_extraction_script> Redshift code extracted using script version $VERSION on $(date +%m/%d/%Y) <sc_extraction_script>" > "$ddl_output/${parts[0]}"
        cat "$temp_output/${parts[0]}.clean" >> "$ddl_output/${parts[0]}"
        # Add query to the remove list
        to_remove+=("$query")
      elif [ "$status" = "FAILED" ]
      then
        echo "Query failed... Error message:"
        # Extract error messge from response
        error_re="Error: '(.*)'\\s+\\w+:"
        [[ $statement_response =~ $error_re ]] && error_msg="${BASH_REMATCH[1]}"
        # Save error to log
        echo "Failed query:" >> "$log_output/log.txt"
        echo "${parts[0]}" >> "$log_output/log.txt"
        echo "${parts[1]}" >> "$log_output/log.txt"
        echo "$error_msg" | tee -a "$log_output/log.txt"
        # Add query to the remove list
        to_remove+=("$query")
      else
        echo "Query still pending. Validating again in some seconds."
      fi
    done

    # Iteration to remove queries from queue when finished
    for ele in "${to_remove[@]}"; do
      for i in "${!queries[@]}"; do
        if [[ "${queries[i]}" = "$ele" ]]; then
          unset queries[i]
        fi
      done
    done

    # Wait 5 seconds to give some more time to queries to finish
    sleep 5

  else
    break
  fi
done

# Validate if there are queries pending
if [ ${#queries[@]} -gt 0 ]
then
  echo "Finished process, but not all queries finished due to timeout." >> "$log_output/log.txt"
  echo "Not all queries have finished. Consider increasing iterations value to increase timeout."
else
  echo "Finished extracting Redshift DDL. Please check for output in the specified folder."
fi