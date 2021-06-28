## ---------------------------------------------------------------
## Modify the following settings
## ---------------------------------------------------------------

SNOWFLAKE_DB_NAME="type your snowflake database name here"
SNOWFLAKE_WAREHOUSE_NAME="type your snowflake warehouse name here"
SNOWFLAKE_FILE_FORMAT_NAME="PIPE_DELIMITED"
SNOWFLAKE_STAGE_NAME="TERADATA_SOURCE_STAGE"

# Location of the data extract files
DATA_FILE_LOCATION="../output/data_extracts"

## Enter the Teradata Database Names to Generate Load Scripts
TERADATA_DATABASES_TO_LOAD=(TERADATA_DATABASE1, TERADATA_DATABASE2)

## ---------------------------------------------------------------
## Do not change below
## ---------------------------------------------------------------

for TERADATA_DATABASE in "${TERADATA_DATABASES_TO_LOAD[@]}"
do

  SNOWFLAKE_SCHEMA_NAME=$(echo ${TERADATA_DATABASE})

  OUTPUT_FILE="../output/object_extracts/load_files_to_snowflake.$TERADATA_DATABASE.sql"
  touch $OUTPUT_FILE;

  USE_DB_SCHEMA_WH="
  use ${SNOWFLAKE_DB_NAME}.${SNOWFLAKE_SCHEMA_NAME};
  use warehouse ${SNOWFLAKE_WAREHOUSE_NAME};
  "

  CREATE_FILE_FORMAT="
  CREATE OR REPLACE FILE FORMAT ${SNOWFLAKE_DB_NAME}.${SNOWFLAKE_SCHEMA_NAME}.${SNOWFLAKE_FILE_FORMAT_NAME} 
      TYPE = 'CSV' 
      COMPRESSION = 'AUTO' 
      FIELD_DELIMITER = '|' 
      RECORD_DELIMITER = '\n' 
      SKIP_HEADER = 0 
      FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' 
      TRIM_SPACE = FALSE 
      ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
      ESCAPE = '\134' 
      ESCAPE_UNENCLOSED_FIELD = '\134' 
      DATE_FORMAT = 'AUTO' 
      TIMESTAMP_FORMAT = 'AUTO' 
      NULL_IF = ('\\N');
  "

  CREATE_STAGE="
  CREATE OR REPLACE STAGE ${SNOWFLAKE_DB_NAME}.${SNOWFLAKE_SCHEMA_NAME}.${SNOWFLAKE_STAGE_NAME};
  "

  PUT_STATEMENT="
  -- This PUT needs to be executed from snowsql and have access to the data files locally
  put file://${DATA_FILE_LOCATION}/${TERADATA_DATABASE}*.dat* @${SNOWFLAKE_DB_NAME}.${SNOWFLAKE_SCHEMA_NAME}.${SNOWFLAKE_STAGE_NAME} auto_compress=true;
  "

  echo "$USE_DB_SCHEMA_WH" > $OUTPUT_FILE
  echo "$CREATE_FILE_FORMAT" >> $OUTPUT_FILE
  echo "$CREATE_STAGE" >> $OUTPUT_FILE
  echo "$PUT_STATEMENT" >> $OUTPUT_FILE

  COPY_INTO="
  copy into ${SNOWFLAKE_DB_NAME}.${SNOWFLAKE_SCHEMA_NAME}.TD_TABLE_NAME 
    from @${SNOWFLAKE_STAGE_NAME}
    pattern = '.*TD_DATABASE_NAME[.]TD_TABLE_NAME[.].*' 
    file_format = (format_name = ${SNOWFLAKE_FILE_FORMAT_NAME} ENCODING = 'iso-8859-1') 
    FORCE = TRUE on_error = 'skip_file';
  "

  while read p; do
    COPY_TEMP=$COPY_INTO
    IFS='|' read -ra NAMES <<< "$p" 
    td_database_name=$(echo ${NAMES[0]})
    td_table_name=$(echo ${NAMES[1]})
    UPPER_TD_DATABASE_NAME=$(echo $td_database_name | tr a-z A-Z)
    UPPER_TD_TABLE_NAME=$(echo $td_table_name | tr a-z A-Z)

    if [ $TERADATA_DATABASE = $UPPER_TD_DATABASE_NAME ]; then
      replace1=$(echo ${COPY_TEMP//TD_DATABASE_NAME/$UPPER_TD_DATABASE_NAME})
      echo ${replace1//TD_TABLE_NAME/$UPPER_TD_TABLE_NAME} >> $OUTPUT_FILE
    fi

  done < ../output/object_extracts/Reports/table_list.txt

done

## End of Script