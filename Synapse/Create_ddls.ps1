<#
.SYNOPSIS
    Automates fetching SQL object definitions from Azure Synapse and organizing them into pool-specific,
    then schema-specific, then type-specific subdirectories.

.DESCRIPTION
    This script executes SQL files against multiple Azure Synapse SQL pools (Dedicated or Serverless),
    parses the output based on custom delimiters, extracts schema and object names,
    and saves each object's DDL into a structured directory hierarchy organized by pool.

.EXAMPLE
    .\Create_ddls.ps1

    Before running:
    1. Fill in the 'User Configuration' variables.
    2. Ensure your SQL scripts are in the specified 'SQL_SCRIPTS_SOURCE_DIR'.
    3. Ensure your SQL scripts output uses the exact 'Internal Delimiters' defined below.
    4. Make sure 'sqlcmd.exe' is installed and accessible in your PowerShell environment's PATH.
#>
$VERSION="0.0.96"

# --- User Configuration ---
$SQL_SCRIPTS_SOURCE_DIR = ".\Scripts"

# Azure Synapse Connection Details
# For dedicated pools
$DEDICATED_SERVER = ".database.windows.net"

# For serverless pools
$SERVERLESS_SERVER = "-ondemand.sql.azuresynapse.net"

# POOL CONFIGURATION: Define each pool and its type
# Using parallel arrays for consistency with bash version
$POOL_NAMES = @(
    "Built-in"
)

$POOL_TYPES = @(
    "serverless"
)

# Note: POOL_NAMES and POOL_TYPES arrays must have the same number of elements
# and correspond to each other by index

# Authentication Method:
$AuthFlags = "-G -I"

# --- Advanced Configuration (Modify only if necessary) ---
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Base directory for parsed .sql definition files
# The structure will be: BASE_PARSED_SQL_DIR/pool_name/schema_name/object_type/object_name.sql
$BASE_PARSED_SQL_DIR = Join-Path -Path $ScriptDir -ChildPath "parsed_sql_definitions"

# Internal Delimiters (These must exactly match what your SQL scripts output)
$START_SCHEMA_DELIM = "@@START_SCHEMA@@"
$END_SCHEMA_DELIM = "@@END_SCHEMA@@"
$START_NAME_DELIM = "@@START_NAME@@"
$END_NAME_DELIM = "@@END_NAME@@"
$START_OBJ_DELIM = "@@START_OBJECT_DEFINITION@@"
$END_OBJ_DELIM = "@@END_OBJECT_DEFINITION@@"

# --- Setup Base Directories ---
Write-Host "--- Setting up base directories ---"
New-Item -ItemType Directory -Force -Path (Join-Path -Path $ScriptDir -ChildPath $SQL_SCRIPTS_SOURCE_DIR) | Out-Null
New-Item -ItemType Directory -Force -Path $BASE_PARSED_SQL_DIR | Out-Null
Write-Host "Base directories checked/created."

# Validate configuration
if ($POOL_NAMES.Count -ne $POOL_TYPES.Count) {
    Write-Error "POOL_NAMES and POOL_TYPES arrays must have the same number of elements"
    Write-Error "POOL_NAMES has $($POOL_NAMES.Count) elements, POOL_TYPES has $($POOL_TYPES.Count) elements"
    exit 1
}

Write-Host "`n--- Pool Configuration Summary ---"
Write-Host "Total pools configured: $($POOL_NAMES.Count)"
for ($i = 0; $i -lt $POOL_NAMES.Count; $i++) {
    Write-Host "Pool: '$($POOL_NAMES[$i])' -> Type: '$($POOL_TYPES[$i])'"
}

# --- Main Processing Loop for Each Database/Pool ---
for ($i = 0; $i -lt $POOL_NAMES.Count; $i++) {
    $POOL_NAME = $POOL_NAMES[$i]
    $POOL_TYPE = $POOL_TYPES[$i]
    $POOL_NUMBER = $i + 1
    
    Write-Host "`n========================================"
    Write-Host "Processing Pool $POOL_NUMBER`: '$POOL_NAME' (Type: '$POOL_TYPE')"
    Write-Host "========================================"
    
    # Validate pool name and type
    if ([string]::IsNullOrEmpty($POOL_NAME)) {
        Write-Error "Empty pool name detected at index $i. Skipping."
        continue
    }
    
    if ([string]::IsNullOrEmpty($POOL_TYPE)) {
        Write-Error "No pool type defined for pool '$POOL_NAME' at index $i. Skipping."
        continue
    }
    
    # Determine Server and Database based on Pool Type
    if ($POOL_TYPE -eq "dedicated") {
        $SERVER = $DEDICATED_SERVER
        $ACTUAL_DATABASE = $POOL_NAME
        Write-Host "DEDICATED pool configuration: Server=$SERVER, Database=$ACTUAL_DATABASE"
    } elseif ($POOL_TYPE -eq "serverless") {
        $SERVER = $SERVERLESS_SERVER
        $ACTUAL_DATABASE = "master"
        Write-Host "SERVERLESS pool configuration: Server=$SERVER, Database=$ACTUAL_DATABASE"
    } else {
        Write-Error "Invalid pool type '$POOL_TYPE' for pool '$POOL_NAME'. Must be 'dedicated' or 'serverless'."
        continue
    }
    
    # Create safe directory name (replace problematic characters)
    $SAFE_POOL_NAME = $POOL_NAME -replace '[^a-zA-Z0-9_-]', '_'
    
    # Pool-specific directories
    $TEMP_OUTPUT_TXT_DIR = Join-Path -Path $ScriptDir -ChildPath "temp_sqlcmd_output_$SAFE_POOL_NAME"
    $FINAL_PARSED_SQL_DIR = Join-Path -Path $BASE_PARSED_SQL_DIR -ChildPath $POOL_NAME
    
    Write-Host "Temp directory: $TEMP_OUTPUT_TXT_DIR"
    Write-Host "Final directory: $FINAL_PARSED_SQL_DIR"
    
    # Setup pool-specific directories
    Write-Host "--- Setting up directories for '$POOL_NAME' ---"
    New-Item -ItemType Directory -Force -Path $TEMP_OUTPUT_TXT_DIR | Out-Null
    New-Item -ItemType Directory -Force -Path $FINAL_PARSED_SQL_DIR | Out-Null
    Write-Host "Pool-specific directories checked/created."

    # --- Step 1: Execute SQL Scripts and Generate Raw Output ---
    Write-Host "`n--- Executing SQL Scripts for '$POOL_NAME' ---"

    $SQL_FILES_TO_RUN = @()
    $absolute_sql_scripts_dir = Join-Path -Path $ScriptDir -ChildPath $SQL_SCRIPTS_SOURCE_DIR

    if ($POOL_TYPE -eq "dedicated") {
        Write-Host "Targeting a DEDICATED SQL Pool."
        $SQL_FILES_TO_RUN += (Join-Path -Path $absolute_sql_scripts_dir -ChildPath "Get_tables.sql")
        $SQL_FILES_TO_RUN += (Join-Path -Path $absolute_sql_scripts_dir -ChildPath "Get_procedures.sql")
        $SQL_FILES_TO_RUN += (Join-Path -Path $absolute_sql_scripts_dir -ChildPath "Get_views.sql")
        $SQL_FILES_TO_RUN += (Join-Path -Path $absolute_sql_scripts_dir -ChildPath "Get_functions.sql")
        $SQL_FILES_TO_RUN += (Join-Path -Path $absolute_sql_scripts_dir -ChildPath "Get_schemas.sql")
        $SQL_FILES_TO_RUN += (Join-Path -Path $absolute_sql_scripts_dir -ChildPath "Get_external_tables.sql")
        $SQL_FILES_TO_RUN += (Join-Path -Path $absolute_sql_scripts_dir -ChildPath "Get_indexes.sql")
    } elseif ($POOL_TYPE -eq "serverless") {
        Write-Host "Targeting a SERVERLESS SQL Pool."
        $SQL_FILES_TO_RUN += (Join-Path -Path $absolute_sql_scripts_dir -ChildPath "Get_external_tables_serveless.sql")
        $SQL_FILES_TO_RUN += (Join-Path -Path $absolute_sql_scripts_dir -ChildPath "Get_external_views.sql")
        $SQL_FILES_TO_RUN += (Join-Path -Path $absolute_sql_scripts_dir -ChildPath "Get_external_data_sources.sql")
        $SQL_FILES_TO_RUN += (Join-Path -Path $absolute_sql_scripts_dir -ChildPath "Get_external_file_formats.sql")
        $SQL_FILES_TO_RUN += (Join-Path -Path $absolute_sql_scripts_dir -ChildPath "Get_schemas.sql")
    }

    Write-Host "SQL scripts to execute: $($SQL_FILES_TO_RUN.Count)"

    # Iterate over the determined SQL files
    foreach ($sql_file in $SQL_FILES_TO_RUN) {
        if (Test-Path $sql_file) {
            $base_name = [System.IO.Path]::GetFileNameWithoutExtension($sql_file)
            
            $output_txt_file_abs = Join-Path -Path $TEMP_OUTPUT_TXT_DIR -ChildPath "$base_name.txt"
            $error_log_file_abs = Join-Path -Path $TEMP_OUTPUT_TXT_DIR -ChildPath "$base_name.err"

            Write-Host "Processing $sql_file -> Saving temporary output to $output_txt_file_abs"

            $cmd = "sqlcmd"
            $args = @(
                "-S", $SERVER,
                "-d", $ACTUAL_DATABASE,
                $AuthFlags,
                "-h", "-1",
                "-y", "0",
                "-i", $sql_file
            )

            try {
                New-Item -ItemType Directory -Force -Path $TEMP_OUTPUT_TXT_DIR | Out-Null

                $process = Start-Process -FilePath $cmd -ArgumentList $args -RedirectStandardOutput $output_txt_file_abs -RedirectStandardError $error_log_file_abs -NoNewWindow -Wait -PassThru

                $process.WaitForExit()

                if ($process.ExitCode -eq 0) {
                    Write-Host "  [OK] Script '$sql_file' executed and saved temporarily."
                    Remove-Item $error_log_file_abs -ErrorAction SilentlyContinue
                } else {
                    $sqlcmd_error = ""
                    if (Test-Path $error_log_file_abs) {
                        $sqlcmd_error = Get-Content -Path $error_log_file_abs -Raw
                        Remove-Item $error_log_file_abs -ErrorAction SilentlyContinue
                    }
                    Write-Error "  [ERROR] Problem executing script '$sql_file'. Exit Code: $($process.ExitCode). SQLCMD Error: $($sqlcmd_error). Check '$output_txt_file_abs' for details (it might be empty or incomplete)."
                }
            } catch {
                Write-Error "  [ERROR] PowerShell failed to execute sqlcmd for '$sql_file': $($_.Exception.Message)"
            }
        } else {
            Write-Warning "  SQL script '$sql_file' not found. Skipping."
        }
    }

    Write-Host "All SQL scripts executed for '$POOL_NAME'."
    
    if (Test-Path $TEMP_OUTPUT_TXT_DIR) {
        $full_temp_output_path = (Convert-Path $TEMP_OUTPUT_TXT_DIR)
        Write-Host "Attempting to list files from absolute path: $full_temp_output_path"
        
        $all_temp_files = Get-ChildItem -Path $full_temp_output_path -ErrorAction SilentlyContinue
        $temp_txt_files = $all_temp_files | Where-Object { -not $_.PSIsContainer -and $_.Extension -eq ".txt" }

        Write-Host "Found $($all_temp_files.Count) items in $full_temp_output_path (including subfolders/errors)."
        Write-Host "Found $($temp_txt_files.Count) .txt files for parsing."
    } else {
        Write-Warning "Temporary output directory '$TEMP_OUTPUT_TXT_DIR' does not exist. Cannot list contents."
    }

    # --- Step 2: Parse and Separate Object Definitions ---
    Write-Host "`n--- Parsing and Separating Definitions for '$POOL_NAME' ---"

    $txt_files = $temp_txt_files

    # Add a check if $txt_files is empty before foreach loop
    if ($txt_files.Count -eq 0) {
        Write-Warning "No .txt files found to parse in '$TEMP_OUTPUT_TXT_DIR'. Skipping parsing step for '$POOL_NAME'."
        continue
    }

    foreach ($txt_file_path in $txt_files) {
        Write-Host "Starting parsing for file: $($txt_file_path.FullName)"
        
        $txt_file_content = Get-Content -Path $txt_file_path -Raw
        
        # Skip files that don't contain object definitions
        if ($txt_file_content -notlike "*$START_SCHEMA_DELIM*") {
            Write-Host "Skipping '$($txt_file_path.Name)': No object definitions found (possibly '0 rows affected')."
            continue
        }

        Write-Host "Processing input file for parsing: $($txt_file_path.Name)"

        # Determine Object Type Subdirectory
        $txt_base_name = $txt_file_path.BaseName

        $object_type_subdir = "unknown"
        switch -Wildcard ($txt_base_name) {
            "*tables*" { $object_type_subdir = "tables" }
            "*external_tables*" { $object_type_subdir = "tables" }
            "*procedures*" { $object_type_subdir = "procedures" }
            "*views*" { $object_type_subdir = "views" }
            "*external_views*" { $object_type_subdir = "views" }
            "*functions*" { $object_type_subdir = "functions" }
            "*schemas*" { $object_type_subdir = "schemas" }
            "*indexes*" { $object_type_subdir = "indexes" }
            "*data_sources*" { $object_type_subdir = "data_sources" }
            "*file_formats*" { $object_type_subdir = "file_formats" }
            default {
                Write-Warning "Object type not recognized for '$($txt_file_path.Name)'. Using 'unknown' object type sub-directory."
            }
        }

        # --- FIX for parsing all content and correctly extracting/cleaning DDL ---
        # Regex to find all object blocks, including schema/name/object start/end tags.
        # The (?s) flag makes '.' match newlines, so it spans across lines.
        # The (?<=...) is a positive lookbehind to ensure the match starts AFTER the previous END_OBJ_DELIM,
        # or at the beginning of the string if it's the first object.
        # This also ensures we capture the START_SCHEMA/NAME/OBJECT_DEFINITION tags within the block.
        $full_object_pattern = "(?s)((?<=^|$( [regex]::Escape($END_OBJ_DELIM) )\s*\n*)$([regex]::Escape($START_SCHEMA_DELIM)).*?$([regex]::Escape($END_SCHEMA_DELIM)).*?$([regex]::Escape($START_NAME_DELIM)).*?$([regex]::Escape($END_NAME_DELIM)).*?$([regex]::Escape($START_OBJ_DELIM)).*?$([regex]::Escape($END_OBJ_DELIM)))"
        
        $all_matching_blocks = [regex]::Matches($txt_file_content, $full_object_pattern)

        
        foreach ($match in $all_matching_blocks) {
            $current_block_content = $match.Value.Trim("`r`n ") # Get the full matched block content

            # Re-verify and extract schema/name from this specific block
            $current_schema = ""
            $current_object_name_from_tag = ""

            if ($current_block_content -match "$([regex]::Escape($START_SCHEMA_DELIM))(.*?)$([regex]::Escape($END_SCHEMA_DELIM))") {
                $current_schema = $Matches[1]
            }
            if ($current_block_content -match "$([regex]::Escape($START_NAME_DELIM))(.*?)$([regex]::Escape($END_NAME_DELIM))") {
                $current_object_name_from_tag = $Matches[1]
            }

            # --- DDL CLEANUP: Robustly remove all tags ---
            $cleaned_ddl = $current_block_content -replace "$([regex]::Escape($START_SCHEMA_DELIM)).*?$([regex]::Escape($END_SCHEMA_DELIM))", ""
            $cleaned_ddl = $cleaned_ddl -replace "$([regex]::Escape($START_NAME_DELIM)).*?$([regex]::Escape($END_NAME_DELIM))", ""
            $cleaned_ddl = $cleaned_ddl -replace "$([regex]::Escape($START_OBJ_DELIM))", ""
            $cleaned_ddl = $cleaned_ddl -replace "$([regex]::Escape($END_OBJ_DELIM))", ""

            # Remove sqlcmd output noise if it managed to get in
            $cleaned_ddl = $cleaned_ddl -replace "`r?`n`r?`n?`(`d+ rows affected`)"
            $cleaned_ddl = $cleaned_ddl -replace "`r?`n`r?`n?`(`-+`)"
            
            $cleaned_ddl = $cleaned_ddl.Trim("`r`n ") # Final trim

            if (-not ([string]::IsNullOrWhiteSpace($cleaned_ddl)) -and -not ([string]::IsNullOrWhiteSpace($current_object_name_from_tag))) {
                # MODIFIED PATH TO BE POOL/SCHEMA-FIRST
                $SCHEMA_DIR = Join-Path -Path $FINAL_PARSED_SQL_DIR -ChildPath $current_schema
                $OBJECT_TYPE_DIR = Join-Path -Path $SCHEMA_DIR -ChildPath $object_type_subdir
                New-Item -ItemType Directory -Force -Path $OBJECT_TYPE_DIR | Out-Null

                $output_file_path = Join-Path -Path $OBJECT_TYPE_DIR -ChildPath "$current_object_name_from_tag.sql"

                Write-Host "  Saving definition to: $output_file_path"
                
                # Create the SQL file with USE statement, GO command, and the cleaned DDL
                $sql_content = @"
USE [$POOL_NAME];
GO

$cleaned_ddl
"@
                $sql_content | Set-Content -Path $output_file_path -Encoding UTF8
            } else {
                Write-Warning "  [WARNING] Cleaned DDL content or object name is empty for a block in $($txt_file_path.Name). File not created. Schema: '$current_schema', Name: '$current_object_name_from_tag', DDL length: $($cleaned_ddl.Length)."
            }
        }
    }

    Write-Host "Object definitions parsed and saved for '$POOL_NAME' to '$FINAL_PARSED_SQL_DIR'."

    # --- Pool-specific Cleanup ---
    Write-Host "`n--- Cleaning up temporary files for '$POOL_NAME' ---"
    if (Test-Path $TEMP_OUTPUT_TXT_DIR) {
        Remove-Item -Path $TEMP_OUTPUT_TXT_DIR -Recurse -Force | Out-Null
        Write-Host "Removed temporary directory: $TEMP_OUTPUT_TXT_DIR"
    } else {
        Write-Host "Temporary directory not found: $TEMP_OUTPUT_TXT_DIR. Nothing to clean."
    }
    Write-Host "Cleanup complete for '$POOL_NAME'."

} # End of main database loop

Write-Host "`n========================================"
Write-Host "--- Process Complete for All Pools ---"
Write-Host "========================================"
Write-Host "Processed $($POOL_NAMES.Count) pools total."
Write-Host "All SQL scripts executed for all configured pools."
Write-Host "Object definitions parsed and saved to '$BASE_PARSED_SQL_DIR' (pool/schema-first organization)."
Write-Host "Final directory structure: pool_name/schema_name/object_type/object_name.sql"