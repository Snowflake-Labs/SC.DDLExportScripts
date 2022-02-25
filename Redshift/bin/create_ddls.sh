# GENERAL INSTRUCTIONS: This script is used to extract object DDL from your RedShift Cluster. Please adjust the variables with enclosed by <>
#                       below to match your environment. Once completed, your extracted DDL code will be stored in the object_extracts folder.

# ---- Variables to change ----

# General Variables
OUTPUT_PATH="<output_path>"

# AWS RedShift Variables
RS_CLUSTER="<redshift_cluster_identifier>"
RS_DATABASE="<redshift_database>"
RS_SECRET_ARN="<secret_arn>"

#Script Variables
SCHEMA_FILTER="lower(schemaname) LIKE '%'"
BATCH_WAIT="0.2"
# ---- END: Variables to change ----

mkdir -p $OUTPUT_PATH
mkdir -p $OUTPUT_PATH/log
#mkdir -p $OUTPUT_PATH%/temp
mkdir -p $OUTPUT_PATH/object_extracts
mkdir -p $OUTPUT_PATH/object_extracts/DDL
#mkdir -p $OUTPUT_PATH/object_extracts/Reports
#mkdir -p $OUTPUT_PATH/object_extracts/Storage

python ../scripts/bash_test.py "$RS_CLUSTER" "$RS_DATABASE" "$RS_SECRET_ARN" "$OUTPUT_PATH" "$SCHEMA_FILTER" "$BATCH_WAIT"