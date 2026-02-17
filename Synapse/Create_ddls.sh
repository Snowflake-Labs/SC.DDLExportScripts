#!/bin/bash

# Script version
VERSION="0.2.0"

# Scripts source
SQL_SCRIPTS_SOURCE_DIR="./Scripts"

# --- User Configuration ---

# Azure Synapse Connection Details
# SERVER CONFIGURATION: Leave empty to disable pool type extraction
# For dedicated pools - Leave empty ("") to skip dedicated pool extraction
DEDICATED_SERVER=""

# For serverless pools - Leave empty ("") to skip serverless pool extraction
SERVERLESS_SERVER=""

# POOL CONFIGURATION: Simplified configuration using separate variables
# For dedicated pools: pool name = database name
# For serverless pools: one pool with multiple databases
# NOTE: These configurations only take effect if the corresponding SERVER variable is set above

# DEDICATED POOLS: List of dedicated pool names (database name will be the same)
# Only processed if DEDICATED_SERVER is not empty
POOL_DEDICATED_NAMES=(
    # Add more dedicated pools here as needed
)

# SERVERLESS CONFIGURATION: One serverless pool with multiple databases
# Only processed if SERVERLESS_SERVER is not empty
POOL_SERVELESS_NAME="Built-in"
POOL_SERVELESS_DATABASE_NAMES=(
    "master"
    # Add more databases here as needed
)

# Authentication Method:
# Choose ONE of the options below.

# OPTION 1: Azure AD Authentication (Recommended for Azure environments)
# If using Azure AD authentication, leave USERNAME and PASSWORD commented out.
# This requires you to be logged into Azure CLI (az login) with an account
# that has permissions to the Synapse database.
AUTH_FLAGS="-G -I"

# OPTION 2: SQL Server Authentication (Username and Password)
# Uncomment and set your SQL username and password.
# IMPORTANT: Storing passwords directly in scripts is not recommended for production.
# Consider Azure Key Vault or other secure methods for production environments.
# AUTH_FLAGS="-U your_sql_username -P your_sql_password -I" # REPLACE 'your_sql_username' and 'your_sql_password' with actual credentials.

# --- User Configuration End ---

# --- Advanced Configuration (Modify only if necessary) ---
# Base directory for parsed .sql definition files
# The structure will be: BASE_PARSED_SQL_DIR/pool_name/schema_name/object_type/object_name.sql
BASE_PARSED_SQL_DIR="./parsed_sql_definitions"

# Log directory for .txt files without proper labels/tags
# The structure will be: LOG_DIR/pool_name/database_name/original_filename.txt
LOG_DIR="./logs"

# Internal Delimiters (These must exactly match what your SQL scripts output)
# Your SQL should format the output like:
# @@START_SCHEMA@@YourSchema@@END_SCHEMA@@@@START_NAME@@YourObject@@END_NAME@@@@START_OBJECT_DEFINITION@@
# Your object DDL goes here
# @@END_OBJECT_DEFINITION@@
START_SCHEMA_DELIM="@@START_SCHEMA@@"
END_SCHEMA_DELIM="@@END_SCHEMA@@"
START_NAME_DELIM="@@START_NAME@@"
END_NAME_DELIM="@@END_NAME@@"
START_OBJ_DELIM="@@START_OBJECT_DEFINITION@@"
END_OBJ_DELIM="@@END_OBJECT_DEFINITION@@"

# --- Setup Base Directories ---
echo "--- Setting up base directories ---"
mkdir -p "$SQL_SCRIPTS_SOURCE_DIR"
mkdir -p "$BASE_PARSED_SQL_DIR"
mkdir -p "$LOG_DIR"
echo "Base directories and logs directory checked/created."

# Generate individual database files for each pool
echo "--- Generating individual database files ---"

# Process dedicated pools (pool name = database name)
if [ "$dedicated_enabled" = true ]; then
    for POOL_NAME in "${POOL_DEDICATED_NAMES[@]}"; do
        DATABASE_NAME="$POOL_NAME"
        
        # Create databases directory for this pool
        POOL_DATABASES_DIR="$BASE_PARSED_SQL_DIR/$POOL_NAME/databases"
        mkdir -p "$POOL_DATABASES_DIR"
        
        # Create individual database file
        DATABASE_FILE="$POOL_DATABASES_DIR/${DATABASE_NAME}.sql"
        
        # Generate the database creation file
        cat > "$DATABASE_FILE" << EOF
-- <GeneratedByScript> Extract using script version $VERSION on $(date +%m/%d/%Y) <GeneratedByScript>
-- ${DATABASE_NAME}.sql
-- CREATE DATABASE statement for database: ${DATABASE_NAME}
-- Pool: ${POOL_NAME} (dedicated)

CREATE DATABASE [${DATABASE_NAME}];
GO
EOF
        
        echo "Generated database file: $DATABASE_FILE"
    done
else
    echo "Skipping dedicated pool database file generation (DEDICATED_SERVER not configured)"
fi

# Process serverless pool with multiple databases
if [ "$serverless_enabled" = true ]; then
    # Create databases directory for serverless pool
    POOL_DATABASES_DIR="$BASE_PARSED_SQL_DIR/$POOL_SERVELESS_NAME/databases"
    mkdir -p "$POOL_DATABASES_DIR"
    
    for DATABASE_NAME in "${POOL_SERVELESS_DATABASE_NAMES[@]}"; do
        # Create individual database file
        DATABASE_FILE="$POOL_DATABASES_DIR/${DATABASE_NAME}.sql"
        
        # Generate the database creation file
        cat > "$DATABASE_FILE" << EOF
-- <sc_extraction_script> Extracted using script version $VERSION on $(date +%m/%d/%Y) <sc_extraction_script>
-- ${DATABASE_NAME}.sql
-- CREATE DATABASE statement for database: ${DATABASE_NAME}
-- Pool: ${POOL_SERVELESS_NAME} (serverless)

CREATE DATABASE [${DATABASE_NAME}];
GO
EOF
        
        echo "Generated database file: $DATABASE_FILE"
    done
else
    echo "Skipping serverless pool database file generation (SERVERLESS_SERVER not configured)"
fi

echo "All individual database files generated."

# Generate .sc_extract file with version information
echo "--- Generating .sc_extract file ---"
SC_EXTRACT_FILE="$BASE_PARSED_SQL_DIR/.sc_extract"

touch "$SC_EXTRACT_FILE"

echo "Generated .sc_extract file at: $SC_EXTRACT_FILE"

# Validate configuration
if [ -n "$DEDICATED_SERVER" ] && [ ${#POOL_DEDICATED_NAMES[@]} -gt 0 ]; then
    dedicated_enabled=true
else
    dedicated_enabled=false
fi

if [ -n "$SERVERLESS_SERVER" ] && [ -n "$POOL_SERVELESS_NAME" ] && [ ${#POOL_SERVELESS_DATABASE_NAMES[@]} -gt 0 ]; then
    serverless_enabled=true
else
    serverless_enabled=false
fi

if [ "$dedicated_enabled" = false ] && [ "$serverless_enabled" = false ]; then
    echo "ERROR: No pools configured. Please configure at least one pool type:"
    echo "  - For dedicated pools: Set DEDICATED_SERVER and define POOL_DEDICATED_NAMES"
    echo "  - For serverless pools: Set SERVERLESS_SERVER and define POOL_SERVELESS_NAME with POOL_SERVELESS_DATABASE_NAMES"
    exit 1
fi

echo -e "\n--- Pool Configuration Summary ---"
if [ "$dedicated_enabled" = true ]; then
    dedicated_count=${#POOL_DEDICATED_NAMES[@]}
else
    dedicated_count=0
fi

if [ "$serverless_enabled" = true ]; then
    serverless_count=${#POOL_SERVELESS_DATABASE_NAMES[@]}
else
    serverless_count=0
fi

TOTAL_CONFIGS=$((dedicated_count + serverless_count))
echo "Total pool/database configurations: $TOTAL_CONFIGS"

if [ "$dedicated_enabled" = true ]; then
    echo "Dedicated pools: (ENABLED)"
    for POOL_NAME in "${POOL_DEDICATED_NAMES[@]}"; do
        echo "  Pool: '$POOL_NAME' -> Database: '$POOL_NAME' (dedicated)"
    done
else
    echo "Dedicated pools: (DISABLED - DEDICATED_SERVER not configured)"
fi

if [ "$serverless_enabled" = true ]; then
    echo "Serverless pool: '$POOL_SERVELESS_NAME' (ENABLED)"
    for DATABASE_NAME in "${POOL_SERVELESS_DATABASE_NAMES[@]}"; do
        echo "  Database: '$DATABASE_NAME' (serverless)"
    done
else
    echo "Serverless pools: (DISABLED - SERVERLESS_SERVER not configured)"
fi

# --- Main Processing Loop for Each Database/Pool ---
CONFIG_NUMBER=0

# Process dedicated pools
if [ "$dedicated_enabled" = true ]; then
    for POOL_NAME in "${POOL_DEDICATED_NAMES[@]}"; do
        DATABASE_NAME="$POOL_NAME"
        POOL_TYPE="dedicated"
        CONFIG_NUMBER=$((CONFIG_NUMBER + 1))
    
    echo -e "\n========================================"
    echo "Processing Configuration $CONFIG_NUMBER: Pool '$POOL_NAME' -> Database '$DATABASE_NAME' (Type: '$POOL_TYPE')"
    echo "========================================"
    
    # Determine Server based on Pool Type
    SERVER="$DEDICATED_SERVER"
    ACTUAL_DATABASE="$DATABASE_NAME"
    echo "DEDICATED pool configuration: Server=$SERVER, Database=$ACTUAL_DATABASE"
    
    # Create safe directory names (replace problematic characters)
    SAFE_POOL_NAME=$(echo "$POOL_NAME" | sed 's/[^a-zA-Z0-9_-]/_/g')
    SAFE_DATABASE_NAME=$(echo "$DATABASE_NAME" | sed 's/[^a-zA-Z0-9_-]/_/g')
    
    # Pool and database-specific directories
    TEMP_OUTPUT_TXT_DIR="./temp_sqlcmd_output_${SAFE_POOL_NAME}_${SAFE_DATABASE_NAME}"
    FINAL_PARSED_SQL_DIR="$BASE_PARSED_SQL_DIR/$POOL_NAME/$DATABASE_NAME"
    
    echo "Temp directory: $TEMP_OUTPUT_TXT_DIR"
    echo "Final directory: $FINAL_PARSED_SQL_DIR"
    
    # Setup pool and database-specific directories
    echo "--- Setting up directories for '$POOL_NAME'/'$DATABASE_NAME' ---"
    mkdir -p "$TEMP_OUTPUT_TXT_DIR"
    mkdir -p "$FINAL_PARSED_SQL_DIR"
    echo "Pool/database-specific directories checked/created."

    ### Step 1: Execute SQL Scripts and Generate Raw Output

    echo -e "\n--- Executing SQL Scripts for '$POOL_NAME'/'$DATABASE_NAME' ---"

    # Determine which SQL scripts to run based on POOL_TYPE
    SQL_FILES_TO_RUN=()

        if [ "$POOL_TYPE" == "dedicated" ]; then
    echo "Targeting a DEDICATED SQL Pool."
    # List dedicated pool specific DDL scripts here
    SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_tables.sql" )
    SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_procedures.sql" )
    SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_views.sql" )
    SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_functions.sql" )
    SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_schemas.sql" )
    SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_external_tables.sql" )
    SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_indexes.sql" )
    elif [ "$POOL_TYPE" == "serverless" ]; then
    echo "Targeting a SERVERLESS SQL Pool."
    # List serverless pool specific DDL scripts here
    SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_external_tables_serveless.sql" )
    SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_external_views.sql" )
    SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_external_data_sources.sql" )
    SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_external_file_formats.sql" )
    SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_schemas.sql" )
fi

    echo "SQL scripts to execute: ${#SQL_FILES_TO_RUN[@]}"

    # Iterate over the determined SQL files
    for sql_file in "${SQL_FILES_TO_RUN[@]}"; do
        if [ -f "$sql_file" ]; then
            base_name=$(basename "$sql_file" .sql)
            output_txt_file="$TEMP_OUTPUT_TXT_DIR/${base_name}.txt"

            echo "Processing $sql_file -> Saving temporary output to $output_txt_file"

            # Execute sqlcmd using the correct database for the pool type
            sqlcmd -S "$SERVER" -d "$ACTUAL_DATABASE" ${AUTH_FLAGS} -h -1 -y 0 -i "$sql_file" > "$output_txt_file"

            if [ $? -eq 0 ]; then
                echo "  [OK] Script '$sql_file' executed and saved temporarily."
            else
                echo "  [ERROR] Problem executing script '$sql_file'. Check '$output_txt_file' for details."
                # Consider adding 'exit 1' here if a script failure should stop the entire process.
            fi
        else
            echo "  [WARNING] SQL script '$sql_file' not found. Skipping."
        fi
    done

    echo "All SQL scripts executed for '$POOL_NAME'/'$DATABASE_NAME'."

    ### Step 2: Parse and Separate Object Definitions

    echo -e "\n--- Parsing and Separating Definitions for '$POOL_NAME'/'$DATABASE_NAME' ---"

    # Check if temp directory has files
    if [ ! -d "$TEMP_OUTPUT_TXT_DIR" ]; then
        echo "WARNING: Temp directory '$TEMP_OUTPUT_TXT_DIR' does not exist. Skipping parsing."
        continue
    fi

    file_count=$(find "$TEMP_OUTPUT_TXT_DIR" -name "*.txt" -type f | wc -l)
    echo "Found $file_count .txt files to process"

    for txt_file in "$TEMP_OUTPUT_TXT_DIR"/*.txt; do
        if [ -f "$txt_file" ]; then
            echo "Processing file: $txt_file"
            
            # Check if file contains proper labels/tags
            if ! grep -q "$START_SCHEMA_DELIM" "$txt_file"; then
                # Create log directory for this pool/database combination
                pool_log_dir="$LOG_DIR/$POOL_NAME/$DATABASE_NAME"
                mkdir -p "$pool_log_dir"
                
                # Save the original .txt file to log directory with descriptive name
                txt_filename=$(basename "$txt_file")
                log_file_name="${txt_filename%.*}_${POOL_NAME}_${DATABASE_NAME}.txt"
                log_file_path="$pool_log_dir/$log_file_name"
                cp "$txt_file" "$log_file_path"
                
                echo "WARNING: File '$txt_filename' contains no proper labels/tags. Saved to logs: $log_file_path"
                continue
            fi

            echo "Processing input file for parsing: $txt_file"

            # --- Determine Object Type Subdirectory (used secondary to schema) ---
            # This relies on your .txt filename containing a keyword (e.g., 'tables', 'procedures').
            txt_base_name=$(basename "$txt_file" .txt)

            object_type_subdir="unknown" # Default if type not recognized
                    case "$txt_base_name" in
            *tables*|*external_tables*)
                object_type_subdir="tables"
                ;;
            *procedures*)
                object_type_subdir="procedures"
                ;;
            *views*|*external_views*)
                object_type_subdir="views"
                ;;
            *functions*)
                object_type_subdir="functions"
                ;;
            *schemas*)
                object_type_subdir="schemas"
                ;;
            *indexes*)
                object_type_subdir="indexes"
                ;;
            *data_sources*)
                object_type_subdir="data_sources"
                ;;
            *file_formats*)
                object_type_subdir="file_formats"
                ;;
            *)
                echo "  [WARNING] Object type not recognized for '$txt_file'. Using 'unknown' object type sub-directory."
                ;;
        esac
            # --- End Object Type Determination ---

            current_definition=""
            current_schema="" # This will hold the schema name (e.g., 'dbo')
            current_object_name_from_tag=""
            in_definition_block=false
            
            while IFS= read -r line || [[ -n "$line" ]]; do
                line_clean=$(echo "$line" | tr -d '\r') # Clean Windows carriage returns

                # Detect the start of a new object definition (Schema, Name, Object Def)
                if [[ "$line_clean" == *"$START_SCHEMA_DELIM"* && "$line_clean" == *"$START_NAME_DELIM"* && "$line_clean" == *"$START_OBJ_DELIM"* ]]; then
                    # If we were already in a block, save the previous block before starting a new one.
                    if [ "$in_definition_block" = true ]; then
                        echo "  [WARNING] End object tag not found for previous block in $txt_file. Forcibly processing."
                        current_definition_temp=$(echo "$current_definition" | awk -v RS="${END_OBJ_DELIM}" 'END{printf "%s", RT ? substr($0, 1, length($0)-length(RT)) : $0}')
                        current_definition_temp=$(echo "$current_definition_temp" | sed -E "s/\n+$//")

                        if [ -n "$current_definition_temp" ] && [ -n "$current_object_name_from_tag" ]; then
                            # MODIFIED PATH TO BE POOL/SCHEMA-FIRST
                            SCHEMA_DIR="$FINAL_PARSED_SQL_DIR/$current_schema"
                            OBJECT_TYPE_DIR="$SCHEMA_DIR/$object_type_subdir"
                            mkdir -p "$OBJECT_TYPE_DIR" # Create pool-specific/schema-specific/type-specific directory
                            output_file_path="$OBJECT_TYPE_DIR/${current_object_name_from_tag}.sql"
                            echo "  (Forced Save) Definition to: $output_file_path"
                            echo "-- <GeneratedByScript> Extract using script version $VERSION on $(date +%m/%d/%Y) <GeneratedByScript>" > "$output_file_path"
                            echo "USE [$DATABASE_NAME];" >> "$output_file_path"
                            echo "GO" >> "$output_file_path"
                            echo "" >> "$output_file_path"
                            echo "$current_definition_temp" >> "$output_file_path"
                        else
                            echo "  [WARNING] Could not save previous block due to empty content or name."
                        fi
                    fi

                    # Start a new object definition block
                    in_definition_block=true
                    current_definition="" # Reset definition
                    
                    # Extract Schema and Name from the current line
                    current_schema=$(echo "$line_clean" | sed -E "s/.*${START_SCHEMA_DELIM}(.*)${END_SCHEMA_DELIM}.*/\1/")
                    current_object_name_from_tag=$(echo "$line_clean" | sed -E "s/.*${START_NAME_DELIM}(.*)${END_NAME_DELIM}.*/\1/")

                    # Remove ALL tags from the line, leaving only the actual SQL DDL.
                    remaining_sql_on_line=$(echo "$line_clean" | \
                        sed -E "s/${START_SCHEMA_DELIM}[^@]*${END_SCHEMA_DELIM}//; \
                                 s/${START_NAME_DELIM}[^@]*${END_NAME_DELIM}//; \
                                 s/${START_OBJ_DELIM}//")
                    
                    # Remove any leading whitespace after stripping tags
                    remaining_sql_on_line=$(echo "$remaining_sql_on_line" | sed -E 's/^[[:space:]]+//')

                    # Add the remaining content (which is the start of the DDL) to current_definition
                    current_definition+="$remaining_sql_on_line"$'\n'
                    
                    continue
                fi

                # Detect the end of an object definition
                if [[ "$line_clean" == *"$END_OBJ_DELIM"* ]]; then
                    if [ "$in_definition_block" = true ]; then
                        current_definition_temp=$(echo "$current_definition" | awk -v RS="${END_OBJ_DELIM}" 'END{printf "%s", RT ? substr($0, 1, length($0)-length(RT)) : $0}')
                        current_definition_temp=$(echo "$current_definition_temp" | sed -E "s/\n+$//")

                        if [ -n "$current_definition_temp" ] && [ -n "$current_object_name_from_tag" ]; then
                            # MODIFIED PATH TO BE POOL/SCHEMA-FIRST
                            SCHEMA_DIR="$FINAL_PARSED_SQL_DIR/$current_schema"
                            OBJECT_TYPE_DIR="$SCHEMA_DIR/$object_type_subdir"
                            mkdir -p "$OBJECT_TYPE_DIR" # Create pool-specific/schema-specific/type-specific directory
                            output_file_path="$OBJECT_TYPE_DIR/${current_object_name_from_tag}.sql"
                            echo "  Saving definition to: $output_file_path"
                            echo "-- <GeneratedByScript> Extract using script version $VERSION on $(date +%m/%d/%Y) <GeneratedByScript>" > "$output_file_path"
                            echo "USE [$DATABASE_NAME];" >> "$output_file_path"
                            echo "GO" >> "$output_file_path"
                            echo "" >> "$output_file_path"
                            echo "$current_definition_temp" >> "$output_file_path"
                        else
                            echo "  [WARNING] End object tag detected, but content or name is empty for this block in $txt_file."
                        fi
                    fi
                    current_definition=""
                    current_schema=""
                    current_object_name_from_tag=""
                    in_definition_block=false
                    continue
                fi

                # If we are inside an object definition block and the line is not a delimiter
                if [ "$in_definition_block" = true ]; then
                    current_definition+="$line_clean"$'\n'
                fi

            done < "$txt_file"

            # Handle case where file ends and an object definition block was left open
            if [ "$in_definition_block" = true ] && [ -n "$current_definition" ]; then
                echo "  [WARNING] Open definition block at end of file $txt_file. Saving incomplete content."
                current_definition_temp=$(echo "$current_definition" | awk -v RS="${END_OBJ_DELIM}" 'END{printf "%s", RT ? substr($0, 1, length($0)-length(RT)) : $0}')
                current_definition_temp=$(echo "$current_definition_temp" | sed -E "s/\n+$//")

                if [ -n "$current_definition_temp" ] && [ -n "$current_object_name_from_tag" ]; then
                    # MODIFIED PATH TO BE POOL/SCHEMA-FIRST
                    SCHEMA_DIR="$FINAL_PARSED_SQL_DIR/$current_schema"
                    OBJECT_TYPE_DIR="$SCHEMA_DIR/$object_type_subdir"
                    mkdir -p "$OBJECT_TYPE_DIR" # Create pool-specific/schema-specific/type-specific directory
                    output_file_path="$OBJECT_TYPE_DIR/${current_object_name_from_tag}.sql"
                                            echo "  (Final Save) Definition to: $output_file_path"
                        echo "-- <GeneratedByScript> Extract using script version $VERSION on $(date +%m/%d/%Y) <GeneratedByScript>" > "$output_file_path"
                        echo "USE [$DATABASE_NAME];" >> "$output_file_path"
                        echo "GO" >> "$output_file_path"
                        echo "" >> "$output_file_path"
                        echo "$current_definition_temp" >> "$output_file_path"
                fi
            fi
        else
            echo "No .txt files found in $TEMP_OUTPUT_TXT_DIR"
        fi
    done

    echo "Object definitions parsed and saved for '$POOL_NAME'/'$DATABASE_NAME' to '$FINAL_PARSED_SQL_DIR'."

    # --- Pool/database-specific Cleanup ---
    echo -e "\n--- Cleaning up temporary files for '$POOL_NAME'/'$DATABASE_NAME' ---"
    if [ -d "$TEMP_OUTPUT_TXT_DIR" ]; then
        rm -rf "$TEMP_OUTPUT_TXT_DIR"
        echo "Removed temporary directory: $TEMP_OUTPUT_TXT_DIR"
    else
        echo "Temporary directory not found: $TEMP_OUTPUT_TXT_DIR. Nothing to clean."
    fi
    echo "Cleanup complete for '$POOL_NAME'/'$DATABASE_NAME'."

done # End of dedicated pools loop
else
    echo "Skipping dedicated pool processing (DEDICATED_SERVER not configured)"
fi

# Process serverless pool with multiple databases
if [ "$serverless_enabled" = true ]; then
    for DATABASE_NAME in "${POOL_SERVELESS_DATABASE_NAMES[@]}"; do
        POOL_NAME="$POOL_SERVELESS_NAME"
        POOL_TYPE="serverless"
        CONFIG_NUMBER=$((CONFIG_NUMBER + 1))
        
        echo -e "\n========================================"
        echo "Processing Configuration $CONFIG_NUMBER: Pool '$POOL_NAME' -> Database '$DATABASE_NAME' (Type: '$POOL_TYPE')"
        echo "========================================"
        
        # Determine Server based on Pool Type
        SERVER="$SERVERLESS_SERVER"
        ACTUAL_DATABASE="$DATABASE_NAME"
        echo "SERVERLESS pool configuration: Server=$SERVER, Database=$ACTUAL_DATABASE"
        
        # Create safe directory names (replace problematic characters)
        SAFE_POOL_NAME=$(echo "$POOL_NAME" | sed 's/[^a-zA-Z0-9_-]/_/g')
        SAFE_DATABASE_NAME=$(echo "$DATABASE_NAME" | sed 's/[^a-zA-Z0-9_-]/_/g')
        
        # Pool and database-specific directories
        TEMP_OUTPUT_TXT_DIR="./temp_sqlcmd_output_${SAFE_POOL_NAME}_${SAFE_DATABASE_NAME}"
        FINAL_PARSED_SQL_DIR="$BASE_PARSED_SQL_DIR/$POOL_NAME/$DATABASE_NAME"
        
        echo "Temp directory: $TEMP_OUTPUT_TXT_DIR"
        echo "Final directory: $FINAL_PARSED_SQL_DIR"
        
        # Setup pool and database-specific directories
        echo "--- Setting up directories for '$POOL_NAME'/'$DATABASE_NAME' ---"
        mkdir -p "$TEMP_OUTPUT_TXT_DIR"
        mkdir -p "$FINAL_PARSED_SQL_DIR"
        echo "Pool/database-specific directories checked/created."

        ### Step 1: Execute SQL Scripts and Generate Raw Output

        echo -e "\n--- Executing SQL Scripts for '$POOL_NAME'/'$DATABASE_NAME' ---"

        # Determine which SQL scripts to run based on POOL_TYPE
        SQL_FILES_TO_RUN=()

        echo "Targeting a SERVERLESS SQL Pool."
        # List serverless pool specific DDL scripts here
        SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_external_tables_serveless.sql" )
        SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_external_views.sql" )
        SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_external_data_sources.sql" )
        SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_external_file_formats.sql" )
        SQL_FILES_TO_RUN+=( "$SQL_SCRIPTS_SOURCE_DIR/Get_schemas.sql" )

        echo "SQL scripts to execute: ${#SQL_FILES_TO_RUN[@]}"

        # Iterate over the determined SQL files
        for sql_file in "${SQL_FILES_TO_RUN[@]}"; do
            if [ -f "$sql_file" ]; then
                base_name=$(basename "$sql_file" .sql)
                output_txt_file="$TEMP_OUTPUT_TXT_DIR/${base_name}.txt"

                echo "Processing $sql_file -> Saving temporary output to $output_txt_file"

                # Execute sqlcmd using the correct database for the pool type
                sqlcmd -S "$SERVER" -d "$ACTUAL_DATABASE" ${AUTH_FLAGS} -h -1 -y 0 -i "$sql_file" > "$output_txt_file"

                if [ $? -eq 0 ]; then
                    echo "  [OK] Script '$sql_file' executed and saved temporarily."
                else
                    echo "  [ERROR] Problem executing script '$sql_file'. Check '$output_txt_file' for details."
                    # Consider adding 'exit 1' here if a script failure should stop the entire process.
                fi
            else
                echo "  [WARNING] SQL script '$sql_file' not found. Skipping."
            fi
        done

        echo "All SQL scripts executed for '$POOL_NAME'/'$DATABASE_NAME'."

        ### Step 2: Parse and Separate Object Definitions

        echo -e "\n--- Parsing and Separating Definitions for '$POOL_NAME'/'$DATABASE_NAME' ---"

        # Check if temp directory has files
        if [ ! -d "$TEMP_OUTPUT_TXT_DIR" ]; then
            echo "WARNING: Temp directory '$TEMP_OUTPUT_TXT_DIR' does not exist. Skipping parsing."
            continue
        fi

        file_count=$(find "$TEMP_OUTPUT_TXT_DIR" -name "*.txt" -type f | wc -l)
        echo "Found $file_count .txt files to process"

        for txt_file in "$TEMP_OUTPUT_TXT_DIR"/*.txt; do
            if [ -f "$txt_file" ]; then
                echo "Processing file: $txt_file"
                
                # Check if file contains proper labels/tags
                if ! grep -q "$START_SCHEMA_DELIM" "$txt_file"; then
                    # Create log directory for this pool/database combination
                    pool_log_dir="$LOG_DIR/$POOL_NAME/$DATABASE_NAME"
                    mkdir -p "$pool_log_dir"
                    
                    # Save the original .txt file to log directory with descriptive name
                    txt_filename=$(basename "$txt_file")
                    log_file_name="${txt_filename%.*}_${POOL_NAME}_${DATABASE_NAME}.txt"
                    log_file_path="$pool_log_dir/$log_file_name"
                    cp "$txt_file" "$log_file_path"
                    
                    echo "WARNING: File '$txt_filename' contains no proper labels/tags. Saved to logs: $log_file_path"
                    continue
                fi

                echo "Processing input file for parsing: $txt_file"

                # --- Determine Object Type Subdirectory (used secondary to schema) ---
                # This relies on your .txt filename containing a keyword (e.g., 'tables', 'procedures').
                txt_base_name=$(basename "$txt_file" .txt)

                object_type_subdir="unknown" # Default if type not recognized
                case "$txt_base_name" in
                    *tables*|*external_tables*)
                        object_type_subdir="tables"
                        ;;
                    *procedures*)
                        object_type_subdir="procedures"
                        ;;
                    *views*|*external_views*)
                        object_type_subdir="views"
                        ;;
                    *functions*)
                        object_type_subdir="functions"
                        ;;
                    *schemas*)
                        object_type_subdir="schemas"
                        ;;
                    *indexes*)
                        object_type_subdir="indexes"
                        ;;
                    *data_sources*)
                        object_type_subdir="data_sources"
                        ;;
                    *file_formats*)
                        object_type_subdir="file_formats"
                        ;;
                    *)
                        echo "  [WARNING] Object type not recognized for '$txt_file'. Using 'unknown' object type sub-directory."
                        ;;
                esac
                # --- End Object Type Determination ---

                current_definition=""
                current_schema="" # This will hold the schema name (e.g., 'dbo')
                current_object_name_from_tag=""
                in_definition_block=false
                
                while IFS= read -r line || [[ -n "$line" ]]; do
                    line_clean=$(echo "$line" | tr -d '\r') # Clean Windows carriage returns

                    # Detect the start of a new object definition (Schema, Name, Object Def)
                    if [[ "$line_clean" == *"$START_SCHEMA_DELIM"* && "$line_clean" == *"$START_NAME_DELIM"* && "$line_clean" == *"$START_OBJ_DELIM"* ]]; then
                        # If we were already in a block, save the previous block before starting a new one.
                        if [ "$in_definition_block" = true ]; then
                            echo "  [WARNING] End object tag not found for previous block in $txt_file. Forcibly processing."
                            current_definition_temp=$(echo "$current_definition" | awk -v RS="${END_OBJ_DELIM}" 'END{printf "%s", RT ? substr($0, 1, length($0)-length(RT)) : $0}')
                            current_definition_temp=$(echo "$current_definition_temp" | sed -E "s/\n+$//")

                            if [ -n "$current_definition_temp" ] && [ -n "$current_object_name_from_tag" ]; then
                                # MODIFIED PATH TO BE POOL/SCHEMA-FIRST
                                SCHEMA_DIR="$FINAL_PARSED_SQL_DIR/$current_schema"
                                OBJECT_TYPE_DIR="$SCHEMA_DIR/$object_type_subdir"
                                mkdir -p "$OBJECT_TYPE_DIR" # Create pool-specific/schema-specific/type-specific directory
                                output_file_path="$OBJECT_TYPE_DIR/${current_object_name_from_tag}.sql"
                                echo "  (Forced Save) Definition to: $output_file_path"
                                echo "-- <GeneratedByScript> Extract using script version $VERSION on $(date +%m/%d/%Y) <GeneratedByScript>" > "$output_file_path"
                                echo "USE [$DATABASE_NAME];" >> "$output_file_path"
                                echo "GO" >> "$output_file_path"
                                echo "" >> "$output_file_path"
                                echo "$current_definition_temp" >> "$output_file_path"
                            else
                                echo "  [WARNING] Could not save previous block due to empty content or name."
                            fi
                        fi

                        # Start a new object definition block
                        in_definition_block=true
                        current_definition="" # Reset definition
                        
                        # Extract Schema and Name from the current line
                        current_schema=$(echo "$line_clean" | sed -E "s/.*${START_SCHEMA_DELIM}(.*)${END_SCHEMA_DELIM}.*/\1/")
                        current_object_name_from_tag=$(echo "$line_clean" | sed -E "s/.*${START_NAME_DELIM}(.*)${END_NAME_DELIM}.*/\1/")

                        # Remove ALL tags from the line, leaving only the actual SQL DDL.
                        remaining_sql_on_line=$(echo "$line_clean" | \
                            sed -E "s/${START_SCHEMA_DELIM}[^@]*${END_SCHEMA_DELIM}//; \
                                     s/${START_NAME_DELIM}[^@]*${END_NAME_DELIM}//; \
                                     s/${START_OBJ_DELIM}//")
                        
                        # Remove any leading whitespace after stripping tags
                        remaining_sql_on_line=$(echo "$remaining_sql_on_line" | sed -E 's/^[[:space:]]+//')

                        # Add the remaining content (which is the start of the DDL) to current_definition
                        current_definition+="$remaining_sql_on_line"$'\n'
                        
                        continue
                    fi

                    # Detect the end of an object definition
                    if [[ "$line_clean" == *"$END_OBJ_DELIM"* ]]; then
                        if [ "$in_definition_block" = true ]; then
                            current_definition_temp=$(echo "$current_definition" | awk -v RS="${END_OBJ_DELIM}" 'END{printf "%s", RT ? substr($0, 1, length($0)-length(RT)) : $0}')
                            current_definition_temp=$(echo "$current_definition_temp" | sed -E "s/\n+$//")

                            if [ -n "$current_definition_temp" ] && [ -n "$current_object_name_from_tag" ]; then
                                # MODIFIED PATH TO BE POOL/SCHEMA-FIRST
                                SCHEMA_DIR="$FINAL_PARSED_SQL_DIR/$current_schema"
                                OBJECT_TYPE_DIR="$SCHEMA_DIR/$object_type_subdir"
                                mkdir -p "$OBJECT_TYPE_DIR" # Create pool-specific/schema-specific/type-specific directory
                                output_file_path="$OBJECT_TYPE_DIR/${current_object_name_from_tag}.sql"
                                echo "  Saving definition to: $output_file_path"
                                echo "-- <GeneratedByScript> Extract using script version $VERSION on $(date +%m/%d/%Y) <GeneratedByScript>" > "$output_file_path"
                                echo "USE [$DATABASE_NAME];" >> "$output_file_path"
                                echo "GO" >> "$output_file_path"
                                echo "" >> "$output_file_path"
                                echo "$current_definition_temp" >> "$output_file_path"
                            else
                                echo "  [WARNING] End object tag detected, but content or name is empty for this block in $txt_file."
                            fi
                        fi
                        current_definition=""
                        current_schema=""
                        current_object_name_from_tag=""
                        in_definition_block=false
                        continue
                    fi

                    # If we are inside an object definition block and the line is not a delimiter
                    if [ "$in_definition_block" = true ]; then
                        current_definition+="$line_clean"$'\n'
                    fi

                done < "$txt_file"

                # Handle case where file ends and an object definition block was left open
                if [ "$in_definition_block" = true ] && [ -n "$current_definition" ]; then
                    echo "  [WARNING] Open definition block at end of file $txt_file. Saving incomplete content."
                    current_definition_temp=$(echo "$current_definition" | awk -v RS="${END_OBJ_DELIM}" 'END{printf "%s", RT ? substr($0, 1, length($0)-length(RT)) : $0}')
                    current_definition_temp=$(echo "$current_definition_temp" | sed -E "s/\n+$//")

                    if [ -n "$current_definition_temp" ] && [ -n "$current_object_name_from_tag" ]; then
                        # MODIFIED PATH TO BE POOL/SCHEMA-FIRST
                        SCHEMA_DIR="$FINAL_PARSED_SQL_DIR/$current_schema"
                        OBJECT_TYPE_DIR="$SCHEMA_DIR/$object_type_subdir"
                        mkdir -p "$OBJECT_TYPE_DIR" # Create pool-specific/schema-specific/type-specific directory
                        output_file_path="$OBJECT_TYPE_DIR/${current_object_name_from_tag}.sql"
                        echo "  (Final Save) Definition to: $output_file_path"
                        echo "-- <GeneratedByScript> Extract using script version $VERSION on $(date +%m/%d/%Y) <GeneratedByScript>" > "$output_file_path"
                        echo "USE [$DATABASE_NAME];" >> "$output_file_path"
                        echo "GO" >> "$output_file_path"
                        echo "" >> "$output_file_path"
                        echo "$current_definition_temp" >> "$output_file_path"
                    fi
                fi
            else
                echo "No .txt files found in $TEMP_OUTPUT_TXT_DIR"
            fi
        done

        echo "Object definitions parsed and saved for '$POOL_NAME'/'$DATABASE_NAME' to '$FINAL_PARSED_SQL_DIR'."

        # --- Pool/database-specific Cleanup ---
        echo -e "\n--- Cleaning up temporary files for '$POOL_NAME'/'$DATABASE_NAME' ---"
        if [ -d "$TEMP_OUTPUT_TXT_DIR" ]; then
            rm -rf "$TEMP_OUTPUT_TXT_DIR"
            echo "Removed temporary directory: $TEMP_OUTPUT_TXT_DIR"
        else
            echo "Temporary directory not found: $TEMP_OUTPUT_TXT_DIR. Nothing to clean."
        fi
        echo "Cleanup complete for '$POOL_NAME'/'$DATABASE_NAME'."

    done # End of serverless databases loop
else
    echo "Skipping serverless pool processing (SERVERLESS_SERVER not configured)"
fi # End of serverless pool processing

echo -e "\n========================================"
echo "--- Process Complete for All Configurations ---"
echo "========================================"
echo "Processed $TOTAL_CONFIGS pool/database configurations total."
echo "All SQL scripts executed for all configured pools and databases."
echo "Object definitions parsed and saved to '$BASE_PARSED_SQL_DIR' (pool/database/schema-first organization)."
echo "Generated individual database files for each pool/database combination."
echo "Generated .sc_extract version file with extraction metadata."
echo "Final directory structure: pool_name/database_name/schema_name/object_type/object_name.sql"
echo "Database creation files: pool_name/databases/database_name.sql"
echo "Version file: .sc_extract (contains version and extraction info)"