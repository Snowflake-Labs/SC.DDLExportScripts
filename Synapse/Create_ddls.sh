#!/bin/bash
VERSION="0.0.96"

# Scripts source
SQL_SCRIPTS_SOURCE_DIR="./Scripts"

# --- User Configuration ---

# Azure Synapse Connection Details
# For dedicated pools
DEDICATED_SERVER=".database.windows.net"

# For serverless pools  
SERVERLESS_SERVER="-ondemand.sql.azuresynapse.net"

# POOL CONFIGURATION: Define each pool and its type
# Using parallel arrays for compatibility with older bash versions
POOL_NAMES=(
    "Built-in"
)

POOL_TYPES=(
    "serverless"
)

# Note: POOL_NAMES and POOL_TYPES arrays must have the same number of elements
# and correspond to each other by index

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
echo "Base directories checked/created."

# Validate configuration
if [ ${#POOL_NAMES[@]} -ne ${#POOL_TYPES[@]} ]; then
    echo "ERROR: POOL_NAMES and POOL_TYPES arrays must have the same number of elements"
    echo "POOL_NAMES has ${#POOL_NAMES[@]} elements, POOL_TYPES has ${#POOL_TYPES[@]} elements"
    exit 1
fi

echo -e "\n--- Pool Configuration Summary ---"
echo "Total pools configured: ${#POOL_NAMES[@]}"
for i in "${!POOL_NAMES[@]}"; do
    echo "Pool: '${POOL_NAMES[i]}' -> Type: '${POOL_TYPES[i]}'"
done

# --- Main Processing Loop for Each Database/Pool ---
for i in "${!POOL_NAMES[@]}"; do
    POOL_NAME="${POOL_NAMES[i]}"
    POOL_TYPE="${POOL_TYPES[i]}"
    POOL_NUMBER=$((i + 1))
    
    echo -e "\n========================================"
    echo "Processing Pool $POOL_NUMBER: '$POOL_NAME' (Type: '$POOL_TYPE')"
    echo "========================================"
    
    # Validate pool name and type
    if [[ -z "$POOL_NAME" ]]; then
        echo "ERROR: Empty pool name detected at index $i. Skipping."
        continue
    fi
    
    if [[ -z "$POOL_TYPE" ]]; then
        echo "ERROR: No pool type defined for pool '$POOL_NAME' at index $i. Skipping."
        continue
    fi
    
    # Determine Server and Database based on Pool Type
    if [ "$POOL_TYPE" == "dedicated" ]; then
        SERVER="$DEDICATED_SERVER"
        ACTUAL_DATABASE="$POOL_NAME"
        echo "DEDICATED pool configuration: Server=$SERVER, Database=$ACTUAL_DATABASE"
    elif [ "$POOL_TYPE" == "serverless" ]; then
        SERVER="$SERVERLESS_SERVER"
        ACTUAL_DATABASE="master"
        echo "SERVERLESS pool configuration: Server=$SERVER, Database=$ACTUAL_DATABASE"
    else
        echo "ERROR: Invalid pool type '$POOL_TYPE' for pool '$POOL_NAME'. Must be 'dedicated' or 'serverless'."
        continue
    fi
    
    # Create safe directory name (replace problematic characters)
    SAFE_POOL_NAME=$(echo "$POOL_NAME" | sed 's/[^a-zA-Z0-9_-]/_/g')
    
    # Pool-specific directories
    TEMP_OUTPUT_TXT_DIR="./temp_sqlcmd_output_${SAFE_POOL_NAME}"
    FINAL_PARSED_SQL_DIR="$BASE_PARSED_SQL_DIR/$POOL_NAME"
    
    echo "Temp directory: $TEMP_OUTPUT_TXT_DIR"
    echo "Final directory: $FINAL_PARSED_SQL_DIR"
    
    # Setup pool-specific directories
    echo "--- Setting up directories for '$POOL_NAME' ---"
    mkdir -p "$TEMP_OUTPUT_TXT_DIR"
    mkdir -p "$FINAL_PARSED_SQL_DIR"
    echo "Pool-specific directories checked/created."

    ### Step 1: Execute SQL Scripts and Generate Raw Output

    echo -e "\n--- Executing SQL Scripts for '$POOL_NAME' ---"

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

    echo "All SQL scripts executed for '$POOL_NAME'."

    ### Step 2: Parse and Separate Object Definitions

    echo -e "\n--- Parsing and Separating Definitions for '$POOL_NAME' ---"

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
            
            # Skip files that don't contain object definitions (e.g., only "0 rows affected")
            if ! grep -q "$START_SCHEMA_DELIM" "$txt_file"; then
                echo "Skipping '$txt_file': No object definitions found (possibly '0 rows affected')."
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
                            echo "USE [$POOL_NAME];" > "$output_file_path"
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
                            echo "USE [$POOL_NAME];" > "$output_file_path"
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
                    echo "USE [$POOL_NAME];" > "$output_file_path"
                    echo "GO" >> "$output_file_path"
                    echo "" >> "$output_file_path"
                    echo "$current_definition_temp" >> "$output_file_path"
                fi
            fi
        else
            echo "No .txt files found in $TEMP_OUTPUT_TXT_DIR"
        fi
    done

    echo "Object definitions parsed and saved for '$POOL_NAME' to '$FINAL_PARSED_SQL_DIR'."

    # --- Pool-specific Cleanup ---
    echo -e "\n--- Cleaning up temporary files for '$POOL_NAME' ---"
    if [ -d "$TEMP_OUTPUT_TXT_DIR" ]; then
        rm -rf "$TEMP_OUTPUT_TXT_DIR"
        echo "Removed temporary directory: $TEMP_OUTPUT_TXT_DIR"
    else
        echo "Temporary directory not found: $TEMP_OUTPUT_TXT_DIR. Nothing to clean."
    fi
    echo "Cleanup complete for '$POOL_NAME'."

done # End of main database loop

echo -e "\n========================================"
echo "--- Process Complete for All Pools ---"
echo "========================================"
echo "Processed ${#POOL_NAMES[@]} pools total."
echo "All SQL scripts executed for all configured pools."
echo "Object definitions parsed and saved to '$BASE_PARSED_SQL_DIR' (pool/schema-first organization)."
echo "Final directory structure: pool_name/schema_name/object_type/object_name.sql"