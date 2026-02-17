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

# Script version
$VERSION = "0.2.0"

# --- User Configuration ---
$SQL_SCRIPTS_SOURCE_DIR = ".\Scripts"

# Azure Synapse Connection Details
# SERVER CONFIGURATION: Leave empty to disable pool type extraction
# For dedicated pools - Leave empty ("") to skip dedicated pool extraction
$DEDICATED_SERVER = ""

# For serverless pools - Leave empty ("") to skip serverless pool extraction  
$SERVERLESS_SERVER = ""

# POOL CONFIGURATION: Simplified configuration using separate variables
# For dedicated pools: pool name = database name
# For serverless pools: one pool with multiple databases
# NOTE: These configurations only take effect if the corresponding SERVER variable is set above

# DEDICATED POOLS: List of dedicated pool names (database name will be the same)
# Only processed if DEDICATED_SERVER is not empty
$POOL_DEDICATED_NAMES = @(
    # Add more dedicated pools here as needed
)

# SERVERLESS CONFIGURATION: One serverless pool with multiple databases
# Only processed if SERVERLESS_SERVER is not empty
$POOL_SERVELESS_NAME = "Built-in"
$POOL_SERVELESS_DATABASE_NAMES = @(
    "master"
    # Add more databases here as needed
)

# Authentication Method:
# Option 1: Azure Active Directory authentication (default)
# This requires you to be logged into Azure CLI (az login) with an account
# that has permissions to the Synapse database.
$AuthFlags = "-G -I"

# OPTION 2: SQL Server Authentication (Username and Password)
# Uncomment and set your SQL username and password.
# IMPORTANT: Storing passwords directly in scripts is not recommended for production.
# Consider Azure Key Vault or other secure methods for production environments.
# $AuthFlags = "-U your_sql_username -P your_sql_password -I"  # REPLACE 'your_sql_username' and 'your_sql_password' with actual credentials.

# --- Advanced Configuration (Modify only if necessary) ---
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Base directory for parsed .sql definition files
# The structure will be: BASE_PARSED_SQL_DIR/pool_name/schema_name/object_type/object_name.sql
$BASE_PARSED_SQL_DIR = Join-Path -Path $ScriptDir -ChildPath "parsed_sql_definitions"

# Log directory for .txt files without proper labels/tags
# The structure will be: LOG_DIR/pool_name/database_name/original_filename.txt
$LOG_DIR = Join-Path -Path $ScriptDir -ChildPath "logs"

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
New-Item -ItemType Directory -Force -Path $LOG_DIR | Out-Null
Write-Host "Base directories and logs directory checked/created."

# Generate individual database files for each pool
Write-Host "--- Generating individual database files ---"

    # Process dedicated pools (pool name = database name)
if ($dedicated_enabled) {
    foreach ($POOL_NAME in $POOL_DEDICATED_NAMES) {
        $DATABASE_NAME = $POOL_NAME
        
        # Create databases directory for this pool
        $POOL_DATABASES_DIR = Join-Path -Path $BASE_PARSED_SQL_DIR -ChildPath $POOL_NAME | Join-Path -ChildPath "databases"
        New-Item -ItemType Directory -Force -Path $POOL_DATABASES_DIR | Out-Null
        
        # Create individual database file
        $DATABASE_FILE = Join-Path -Path $POOL_DATABASES_DIR -ChildPath "$DATABASE_NAME.sql"
        
        # Generate the database creation file
        $current_date = Get-Date -Format "MM/dd/yyyy"
        $database_content = @"
-- <sc_extraction_script> Extracted using script version $VERSION on $current_date <sc_extraction_script>
-- $DATABASE_NAME.sql
-- CREATE DATABASE statement for database: $DATABASE_NAME
-- Pool: $POOL_NAME (dedicated)

USE [master];
GO

CREATE DATABASE [$DATABASE_NAME];
GO
"@
        
        $database_content | Set-Content -Path $DATABASE_FILE -Encoding UTF8
        Write-Host "Generated database file: $DATABASE_FILE"
    }
} else {
    Write-Host "Skipping dedicated pool database file generation (DEDICATED_SERVER not configured)"
}

# Process serverless pool with multiple databases
if ($serverless_enabled) {
    # Create databases directory for serverless pool
    $POOL_DATABASES_DIR = Join-Path -Path $BASE_PARSED_SQL_DIR -ChildPath $POOL_SERVELESS_NAME | Join-Path -ChildPath "databases"
    New-Item -ItemType Directory -Force -Path $POOL_DATABASES_DIR | Out-Null
    
    foreach ($DATABASE_NAME in $POOL_SERVELESS_DATABASE_NAMES) {
        # Create individual database file
        $DATABASE_FILE = Join-Path -Path $POOL_DATABASES_DIR -ChildPath "$DATABASE_NAME.sql"
        
        # Generate the database creation file
        $current_date = Get-Date -Format "MM/dd/yyyy"
        $database_content = @"
-- <sc_extraction_script> Extracted using script version $VERSION on $current_date <sc_extraction_script>
-- $DATABASE_NAME.sql
-- CREATE DATABASE statement for database: $DATABASE_NAME
-- Pool: $POOL_SERVELESS_NAME (serverless)

USE [master];
GO

CREATE DATABASE [$DATABASE_NAME];
GO
"@
        
        $database_content | Set-Content -Path $DATABASE_FILE -Encoding UTF8
        Write-Host "Generated database file: $DATABASE_FILE"
    }
} else {
    Write-Host "Skipping serverless pool database file generation (SERVERLESS_SERVER not configured)"
}

Write-Host "All individual database files generated."

# Generate .sc_extract file with version information
Write-Host "--- Generating .sc_extract file ---"
$SC_EXTRACT_FILE = Join-Path -Path $BASE_PARSED_SQL_DIR -ChildPath ".sc_extract"

New-Item -ItemType File -Path $SC_EXTRACT_FILE -Force | Out-Null
Write-Host "Generated .sc_extract file at: $SC_EXTRACT_FILE"

# Validate configuration
$dedicated_enabled = (-not [string]::IsNullOrEmpty($DEDICATED_SERVER)) -and ($POOL_DEDICATED_NAMES.Count -gt 0)
$serverless_enabled = (-not [string]::IsNullOrEmpty($SERVERLESS_SERVER)) -and (-not [string]::IsNullOrEmpty($POOL_SERVELESS_NAME)) -and ($POOL_SERVELESS_DATABASE_NAMES.Count -gt 0)

if (-not $dedicated_enabled -and -not $serverless_enabled) {
    Write-Error "No pools configured. Please configure at least one pool type:"
    Write-Error "  - For dedicated pools: Set DEDICATED_SERVER and define POOL_DEDICATED_NAMES"
    Write-Error "  - For serverless pools: Set SERVERLESS_SERVER and define POOL_SERVELESS_NAME with POOL_SERVELESS_DATABASE_NAMES"
    exit 1
}

Write-Host "`n--- Pool Configuration Summary ---"
$dedicated_count = if ($dedicated_enabled) { $POOL_DEDICATED_NAMES.Count } else { 0 }
$serverless_count = if ($serverless_enabled) { $POOL_SERVELESS_DATABASE_NAMES.Count } else { 0 }
$TOTAL_CONFIGS = $dedicated_count + $serverless_count
Write-Host "Total pool/database configurations: $TOTAL_CONFIGS"

if ($dedicated_enabled) {
    Write-Host "Dedicated pools: (ENABLED)"
    foreach ($POOL_NAME in $POOL_DEDICATED_NAMES) {
        Write-Host "  Pool: '$POOL_NAME' -> Database: '$POOL_NAME' (dedicated)"
    }
} else {
    Write-Host "Dedicated pools: (DISABLED - DEDICATED_SERVER not configured)"
}

if ($serverless_enabled) {
    Write-Host "Serverless pool: '$POOL_SERVELESS_NAME' (ENABLED)"
    foreach ($DATABASE_NAME in $POOL_SERVELESS_DATABASE_NAMES) {
        Write-Host "  Database: '$DATABASE_NAME' (serverless)"
    }
} else {
    Write-Host "Serverless pools: (DISABLED - SERVERLESS_SERVER not configured)"
}

# --- Main Processing Loop for Each Database/Pool ---
$CONFIG_NUMBER = 0

# Process dedicated pools
if ($dedicated_enabled) {
    foreach ($POOL_NAME in $POOL_DEDICATED_NAMES) {
        $DATABASE_NAME = $POOL_NAME
        $POOL_TYPE = "dedicated"
        $CONFIG_NUMBER++
    
    Write-Host "`n========================================"
    Write-Host "Processing Configuration $CONFIG_NUMBER`: Pool '$POOL_NAME' -> Database '$DATABASE_NAME' (Type: '$POOL_TYPE')"
    Write-Host "========================================"
    
    # Determine Server based on Pool Type
    $SERVER = $DEDICATED_SERVER
    $ACTUAL_DATABASE = $DATABASE_NAME
    Write-Host "DEDICATED pool configuration: Server=$SERVER, Database=$ACTUAL_DATABASE"
    
    # Create safe directory names (replace problematic characters)
    $SAFE_POOL_NAME = $POOL_NAME -replace '[^a-zA-Z0-9_-]', '_'
    $SAFE_DATABASE_NAME = $DATABASE_NAME -replace '[^a-zA-Z0-9_-]', '_'
    
    # Pool and database-specific directories
    $TEMP_OUTPUT_TXT_DIR = Join-Path -Path $ScriptDir -ChildPath "temp_sqlcmd_output_${SAFE_POOL_NAME}_${SAFE_DATABASE_NAME}"
    $FINAL_PARSED_SQL_DIR = Join-Path -Path $BASE_PARSED_SQL_DIR -ChildPath $POOL_NAME | Join-Path -ChildPath $DATABASE_NAME
    
    Write-Host "Temp directory: $TEMP_OUTPUT_TXT_DIR"
    Write-Host "Final directory: $FINAL_PARSED_SQL_DIR"
    
    # Setup pool and database-specific directories
    Write-Host "--- Setting up directories for '$POOL_NAME'/'$DATABASE_NAME' ---"
    New-Item -ItemType Directory -Force -Path $TEMP_OUTPUT_TXT_DIR | Out-Null
    New-Item -ItemType Directory -Force -Path $FINAL_PARSED_SQL_DIR | Out-Null
    Write-Host "Pool/database-specific directories checked/created."

    # --- Step 1: Execute SQL Scripts and Generate Raw Output ---
    Write-Host "`n--- Executing SQL Scripts for '$POOL_NAME'/'$DATABASE_NAME' ---"

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

    # --- Step 2: Parse Raw Output and Save Individual Object Files ---
    Write-Host "`n--- Parsing SQL Output Files for '$POOL_NAME'/'$DATABASE_NAME' ---"

    $object_type_mapping = @{
        "Get_tables" = "tables"
        "Get_procedures" = "procedures"
        "Get_views" = "views"
        "Get_functions" = "functions"
        "Get_schemas" = "schemas"
        "Get_external_tables_serveless" = "external_tables"
        "Get_external_views" = "external_views"
        "Get_external_data_sources" = "external_data_sources"
        "Get_external_file_formats" = "external_file_formats"
        "Get_external_tables" = "external_tables"
        "Get_indexes" = "indexes"
    }

    $txt_files = Get-ChildItem -Path $TEMP_OUTPUT_TXT_DIR -Filter "*.txt"
    foreach ($txt_file_path in $txt_files) {
        $base_name_txt = [System.IO.Path]::GetFileNameWithoutExtension($txt_file_path.Name)
        $object_type_subdir = $object_type_mapping[$base_name_txt]

        if (-not $object_type_subdir) {
            Write-Warning "  [WARNING] No object type mapping found for '$base_name_txt'. Skipping $($txt_file_path.Name)."
            continue
        }

        Write-Host "Processing $($txt_file_path.Name) -> '$object_type_subdir'"

        $txt_file_content = Get-Content -Path $txt_file_path.FullName -Raw -Encoding UTF8

        if ([string]::IsNullOrWhiteSpace($txt_file_content)) {
            Write-Warning "  [WARNING] File '$($txt_file_path.Name)' is empty or contains only whitespace. Skipping."
            continue
        }

        # Create a regex to match full object blocks (schema + name + definition)
        $full_object_pattern = "$([regex]::Escape($START_SCHEMA_DELIM)).*?$([regex]::Escape($END_SCHEMA_DELIM)).*?$([regex]::Escape($START_NAME_DELIM)).*?$([regex]::Escape($END_NAME_DELIM)).*?$([regex]::Escape($START_OBJ_DELIM)).*?$([regex]::Escape($END_OBJ_DELIM))"
        
        $all_matching_blocks = [regex]::Matches($txt_file_content, $full_object_pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

        # Check if file has no proper labels/tags - save to logs directory
        if ($all_matching_blocks.Count -eq 0) {
            # Create log directory for this pool/database combination
            $pool_log_dir = Join-Path -Path $LOG_DIR -ChildPath $POOL_NAME | Join-Path -ChildPath $DATABASE_NAME
            New-Item -ItemType Directory -Force -Path $pool_log_dir | Out-Null
            
            # Save the original .txt file to log directory with descriptive name
            $log_file_name = "$($txt_file_path.BaseName)_${POOL_NAME}_${DATABASE_NAME}.txt"
            $log_file_path = Join-Path -Path $pool_log_dir -ChildPath $log_file_name
            Copy-Item -Path $txt_file_path.FullName -Destination $log_file_path -Force
            
            Write-Warning "  [WARNING] File '$($txt_file_path.Name)' contains no proper labels/tags. Saved to logs: $log_file_path"
            continue
        }
        
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
                $current_date = Get-Date -Format "MM/dd/yyyy"
                $sql_content = @"
-- <sc_extraction_script> Extracted using script version $VERSION on $current_date <sc_extraction_script>
USE [$DATABASE_NAME];
GO

$cleaned_ddl
"@
                $sql_content | Set-Content -Path $output_file_path -Encoding UTF8
            } else {
                Write-Warning "  [WARNING] Cleaned DDL content or object name is empty for a block in $($txt_file_path.Name). File not created. Schema: '$current_schema', Name: '$current_object_name_from_tag', DDL length: $($cleaned_ddl.Length)."
            }
        }
    }

    Write-Host "Object definitions parsed and saved for '$POOL_NAME'/'$DATABASE_NAME' to '$FINAL_PARSED_SQL_DIR'."

    # --- Pool/database-specific Cleanup ---
    Write-Host "`n--- Cleaning up temporary files for '$POOL_NAME'/'$DATABASE_NAME' ---"
    if (Test-Path $TEMP_OUTPUT_TXT_DIR) {
        Remove-Item -Path $TEMP_OUTPUT_TXT_DIR -Recurse -Force | Out-Null
        Write-Host "Removed temporary directory: $TEMP_OUTPUT_TXT_DIR"
    } else {
        Write-Host "Temporary directory not found: $TEMP_OUTPUT_TXT_DIR. Nothing to clean."
    }
    Write-Host "Cleanup complete for '$POOL_NAME'/'$DATABASE_NAME'."

    } # End of dedicated pools loop
} else {
    Write-Host "Skipping dedicated pool processing (DEDICATED_SERVER not configured)"
}

# Process serverless pool with multiple databases
if ($serverless_enabled) {
    foreach ($DATABASE_NAME in $POOL_SERVELESS_DATABASE_NAMES) {
        $POOL_NAME = $POOL_SERVELESS_NAME
        $POOL_TYPE = "serverless"
        $CONFIG_NUMBER++
        
        Write-Host "`n========================================"
        Write-Host "Processing Configuration $CONFIG_NUMBER`: Pool '$POOL_NAME' -> Database '$DATABASE_NAME' (Type: '$POOL_TYPE')"
        Write-Host "========================================"
        
        # Determine Server based on Pool Type
        $SERVER = $SERVERLESS_SERVER
        $ACTUAL_DATABASE = $DATABASE_NAME
        Write-Host "SERVERLESS pool configuration: Server=$SERVER, Database=$ACTUAL_DATABASE"
        
        # Create safe directory names (replace problematic characters)
        $SAFE_POOL_NAME = $POOL_NAME -replace '[^a-zA-Z0-9_-]', '_'
        $SAFE_DATABASE_NAME = $DATABASE_NAME -replace '[^a-zA-Z0-9_-]', '_'
        
        # Pool and database-specific directories
        $TEMP_OUTPUT_TXT_DIR = Join-Path -Path $ScriptDir -ChildPath "temp_sqlcmd_output_${SAFE_POOL_NAME}_${SAFE_DATABASE_NAME}"
        $FINAL_PARSED_SQL_DIR = Join-Path -Path $BASE_PARSED_SQL_DIR -ChildPath $POOL_NAME | Join-Path -ChildPath $DATABASE_NAME
        
        Write-Host "Temp directory: $TEMP_OUTPUT_TXT_DIR"
        Write-Host "Final directory: $FINAL_PARSED_SQL_DIR"
        
        # Setup pool and database-specific directories
        Write-Host "--- Setting up directories for '$POOL_NAME'/'$DATABASE_NAME' ---"
        New-Item -ItemType Directory -Force -Path $TEMP_OUTPUT_TXT_DIR | Out-Null
        New-Item -ItemType Directory -Force -Path $FINAL_PARSED_SQL_DIR | Out-Null
        Write-Host "Pool/database-specific directories checked/created."

        # --- Step 1: Execute SQL Scripts and Generate Raw Output ---
        Write-Host "`n--- Executing SQL Scripts for '$POOL_NAME'/'$DATABASE_NAME' ---"

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

        # --- Step 2: Parse Raw Output and Save Individual Object Files ---
        Write-Host "`n--- Parsing SQL Output Files for '$POOL_NAME'/'$DATABASE_NAME' ---"

        $object_type_mapping = @{
            "Get_tables" = "tables"
            "Get_procedures" = "procedures"
            "Get_views" = "views"
            "Get_functions" = "functions"
            "Get_schemas" = "schemas"
            "Get_external_tables_serveless" = "external_tables"
            "Get_external_views" = "external_views"
            "Get_external_data_sources" = "external_data_sources"
            "Get_external_file_formats" = "external_file_formats"
            "Get_external_tables" = "external_tables"
            "Get_indexes" = "indexes"
        }

        $txt_files = Get-ChildItem -Path $TEMP_OUTPUT_TXT_DIR -Filter "*.txt"
        foreach ($txt_file_path in $txt_files) {
            $base_name_txt = [System.IO.Path]::GetFileNameWithoutExtension($txt_file_path.Name)
            $object_type_subdir = $object_type_mapping[$base_name_txt]

            if (-not $object_type_subdir) {
                Write-Warning "  [WARNING] No object type mapping found for '$base_name_txt'. Skipping $($txt_file_path.Name)."
                continue
            }

            Write-Host "Processing $($txt_file_path.Name) -> '$object_type_subdir'"

            $txt_file_content = Get-Content -Path $txt_file_path.FullName -Raw -Encoding UTF8

            if ([string]::IsNullOrWhiteSpace($txt_file_content)) {
                Write-Warning "  [WARNING] File '$($txt_file_path.Name)' is empty or contains only whitespace. Skipping."
                continue
            }
            # Create a regex to match full object blocks (schema + name + definition)
            $full_object_pattern = "$([regex]::Escape($START_SCHEMA_DELIM)).*?$([regex]::Escape($END_SCHEMA_DELIM)).*?$([regex]::Escape($START_NAME_DELIM)).*?$([regex]::Escape($END_NAME_DELIM)).*?$([regex]::Escape($START_OBJ_DELIM)).*?$([regex]::Escape($END_OBJ_DELIM))"
            
            $all_matching_blocks = [regex]::Matches($txt_file_content, $full_object_pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

            # Check if file has no proper labels/tags - save to logs directory
            if ($all_matching_blocks.Count -eq 0) {
                # Create log directory for this pool/database combination
                $pool_log_dir = Join-Path -Path $LOG_DIR -ChildPath $POOL_NAME | Join-Path -ChildPath $DATABASE_NAME
                New-Item -ItemType Directory -Force -Path $pool_log_dir | Out-Null
                
                # Save the original .txt file to log directory with descriptive name
                $log_file_name = "$($txt_file_path.BaseName)_${POOL_NAME}_${DATABASE_NAME}.txt"
                $log_file_path = Join-Path -Path $pool_log_dir -ChildPath $log_file_name
                Copy-Item -Path $txt_file_path.FullName -Destination $log_file_path -Force
                
                Write-Warning "  [WARNING] File '$($txt_file_path.Name)' contains no proper labels/tags. Saved to logs: $log_file_path"
                continue
            }
            
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
                    $current_date = Get-Date -Format "MM/dd/yyyy"
                    $sql_content = @"
-- <sc_extraction_script> Extracted using script version $VERSION on $current_date <sc_extraction_script>
USE [$DATABASE_NAME];
GO

$cleaned_ddl
"@
                    $sql_content | Set-Content -Path $output_file_path -Encoding UTF8
                } else {
                    Write-Warning "  [WARNING] Cleaned DDL content or object name is empty for a block in $($txt_file_path.Name). File not created. Schema: '$current_schema', Name: '$current_object_name_from_tag', DDL length: $($cleaned_ddl.Length)."
                }
            }
        }

        Write-Host "Object definitions parsed and saved for '$POOL_NAME'/'$DATABASE_NAME' to '$FINAL_PARSED_SQL_DIR'."

        # --- Pool/database-specific Cleanup ---
        Write-Host "`n--- Cleaning up temporary files for '$POOL_NAME'/'$DATABASE_NAME' ---"
         if (Test-Path $TEMP_OUTPUT_TXT_DIR) {
             Remove-Item -Path $TEMP_OUTPUT_TXT_DIR -Recurse -Force | Out-Null
             Write-Host "Removed temporary directory: $TEMP_OUTPUT_TXT_DIR"
         } else {
             Write-Host "Temporary directory not found: $TEMP_OUTPUT_TXT_DIR. Nothing to clean."
         }
         Write-Host "Cleanup complete for '$POOL_NAME'/'$DATABASE_NAME'."

    } # End of serverless databases loop
} else {
    Write-Host "Skipping serverless pool processing (SERVERLESS_SERVER not configured)"
} # End of serverless pool processing

Write-Host "`n========================================"
Write-Host "--- Process Complete for All Configurations ---"
Write-Host "========================================"
Write-Host "Processed $($dedicated_count + $serverless_count) pool/database configurations total."
Write-Host "All SQL scripts executed for all configured pools and databases."
Write-Host "Object definitions parsed and saved to '$BASE_PARSED_SQL_DIR' (pool/database/schema-first organization)."
Write-Host "Generated individual database files for each pool/database combination."
Write-Host "Generated .sc_extract version file with extraction metadata."
Write-Host "Final directory structure: pool_name/database_name/schema_name/object_type/object_name.sql"
Write-Host "Database creation files: pool_name/databases/database_name.sql"
Write-Host "Version file: .sc_extract (contains version and extraction info)"