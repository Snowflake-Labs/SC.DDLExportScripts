# Synapse Export Scripts

This repository provides scripts to help export your Azure Synapse SQL objects so they can be migrated to [Snowflake](https://www.snowflake.com/) using [SnowConvert](https://docs.snowflake.com/en/migrations/snowconvert-docs/general/about).

## Version
0.2.0
Release 2025-01-24 (Updated with Selective Pool Extraction and Debug Logging)

### Prerequisites

To start, please download this folder or clone this repository into your computer.

This solution provides 2 alternatives to extract the data:

- **Windows Script**: `Create_ddls.ps1` - PowerShell script with Azure CLI + sqlcmd
- **Linux/macOS Script**: `Create_ddls.sh` - Bash script with Azure CLI + sqlcmd

Both scripts now support **multiple Azure Synapse pools** (dedicated and serverless) in a single execution.

## Key Features

- **Multi-Pool Support**: Process multiple Synapse pools in one run
- **Mixed Pool Types**: Support both dedicated and serverless pools simultaneously
- **Selective Pool Extraction**: Enable/disable specific pool types by setting server variables to empty
- **Multi-Database Support**: Extract from multiple databases within serverless pools
- **Pool/Database Organization**: Generated files organized by pool → database → schema → object type → object name
- **Database Creation Files**: Individual CREATE DATABASE files generated per pool
- **Version Tracking**: Automatic generation of .sc_extract file with version information
- **USE Statement Generation**: Each SQL file includes appropriate USE statements
- **Bash Compatibility**: Uses parallel arrays for compatibility with older bash versions
- **Enhanced Logging**: Detailed progress tracking and error handling
- **Safe Directory Naming**: Handles pools and databases with special characters in names
- **Robust Configuration Validation**: Automatic validation and clear error messages for invalid configurations
- **Automatic Debug Logging**: Saves files without proper labels to logs directory for troubleshooting

## Directory Structure

The scripts generate SQL files organized by pool, with database creation files and object definitions:

```
parsed_sql_definitions/
├── .sc_extract                    # Version tracking file
├── pool_name_1/
│   ├── databases/
│   │   ├── database_name_1.sql
│   │   └── database_name_2.sql
│   ├── database_name_1/
│   │   ├── schema_name/
│   │   │   ├── tables/
│   │   │   ├── views/
│   │   │   ├── procedures/
│   │   │   └── indexes/
│   │   └── another_schema/
│   └── database_name_2/
│       └── schema_name/
├── pool_name_2/
│   ├── databases/
│   └── database_name_3/
```

### File Organization:
- **.sc_extract**: Version tracking file containing script version information
- **databases/**: Contains individual CREATE DATABASE statements for each database
- **database_name/**: Contains all database objects organized by schema and object type
- Each SQL file includes appropriate USE statements for proper database context

## Logs Directory

The scripts automatically create a `logs/` directory for debugging and analysis purposes:

```
logs/
├── pool_name_1/
│   ├── database_name_1/
│   │   ├── Get_tables_pool1_database1.txt
│   │   └── Get_views_pool1_database1.txt
│   └── database_name_2/
│       └── Get_procedures_pool1_database2.txt
└── pool_name_2/
    └── database_name_3/
        └── Get_schemas_pool2_database3.txt
```

### When Files Are Logged:
- **Missing Labels**: Files that don't contain expected SQL output delimiters (`@@START_SCHEMA@@`, etc.)
- **No Data Returned**: Files containing only "0 rows affected" or similar messages
- **SQL Errors**: Files with error messages instead of DDL content
- **Unexpected Output**: Any .txt file that doesn't match the expected format for parsing

### Log File Naming:
Files are saved with descriptive names including context: `original_filename_poolname_databasename.txt`

This logging feature helps with:
- **Debugging SQL queries** that return no results
- **Identifying connection or permission issues**
- **Analyzing unexpected database output**
- **Troubleshooting pool-specific problems**

## Running the Scripts

### Prerequisites

Both scripts require:

- **Azure CLI**: [Installation instructions](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- **sqlcmd**: [Installation instructions](https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility?view=sql-server-ver17&tabs=go%2Cwindows%2Cwindows-support&pivots=cs1-bash)
- **Azure Authentication**: Configure your Synapse credentials

### Authentication Setup

#### Option 1: Azure AD Authentication (Recommended)
1. Run `az login` - opens browser for Azure account login
2. Select your desired subscription in the terminal
3. Keep the default `AUTH_FLAGS="-G -I"` in the script

#### Option 2: SQL Server Authentication
1. Uncomment and modify the SQL authentication line in the script
2. Replace the placeholder values with your actual username and password
3. Note: Storing passwords in scripts is not recommended for production environments

### Configuration

Open `Create_ddls.ps1` (Windows) or `Create_ddls.sh` (Linux/macOS) and configure:

#### 1. Server Endpoints (Selective Pool Extraction)
Configure the server endpoints in the script to control which pool types to extract:

**Dedicated Pools:**
- `DEDICATED_SERVER = "your-synapse-workspace.sql.azuresynapse.net"`
- **To disable dedicated pool extraction**: Set `DEDICATED_SERVER = ""`

**Serverless Pools:**
- `SERVERLESS_SERVER = "your-synapse-workspace-ondemand.sql.azuresynapse.net"`
- **To disable serverless pool extraction**: Set `SERVERLESS_SERVER = ""`

Replace "your-synapse-workspace" with your actual Synapse workspace name.

**Flexible Extraction Options:**
- **Both pool types**: Configure both server variables
- **Dedicated only**: Set only DEDICATED_SERVER, leave SERVERLESS_SERVER empty
- **Serverless only**: Set only SERVERLESS_SERVER, leave DEDICATED_SERVER empty
- The script will automatically skip disabled pool types and provide clear feedback

#### 2. Pool and Database Configuration
Configure your pools and target databases using simplified variables in the script:

**Dedicated Pools:**
- Configure POOL_DEDICATED_NAMES with your dedicated pool names
- Each dedicated pool automatically uses its pool name as the database name

**Serverless Pool:**
- Set POOL_SERVELESS_NAME to your serverless pool name (typically "Built-in")
- Configure POOL_SERVELESS_DATABASE_NAMES with the databases you want to extract from

**Configuration Rules:**
- For dedicated pools: Pool name equals database name (automatic)
- For serverless pools: One pool name with multiple database names
- Configure only the pools and databases you want to extract from

### Pool Types and Database Behavior

- **dedicated**: 
  - One pool = One database (same name as pool)
  - Database name should typically match pool name
  - Cannot create additional databases within a dedicated pool
- **serverless**: 
  - One pool can contain multiple databases
  - You can extract from any database within the serverless pool
  - Create separate entries for each database you want to extract from

### Execution

After configuration, run the appropriate script for your platform:
- **Linux/macOS**: Execute the bash script
- **Windows**: Execute the PowerShell script

### What Gets Extracted

#### For All Extractions
- **Version File**: .sc_extract file with script version information
- **Database Creation Files**: Individual CREATE DATABASE statements in databases/ directory
- **Debug Logs**: Files with parsing issues automatically saved to logs/ directory

#### Dedicated Pools
- Tables, Views, Stored Procedures, Functions
- Schemas, External Tables, Indexes

#### Serverless Pools  
- External Tables, External Views
- External Data Sources, External File Formats
- Schemas

## Example Configuration

### Mixed Environment Setup
A typical configuration might include:
- Multiple dedicated pools (sales, marketing, etc.)
- Serverless pool with multiple databases (master, analytics, staging)

### Configuration Examples

#### 1. Extract from Both Pool Types (Default)
```powershell
# Enable both dedicated and serverless pools
$DEDICATED_SERVER = "myworkspace.sql.azuresynapse.net"
$SERVERLESS_SERVER = "myworkspace-ondemand.sql.azuresynapse.net"
$POOL_DEDICATED_NAMES = @("sales", "marketing")
$POOL_SERVELESS_NAME = "Built-in"
$POOL_SERVELESS_DATABASE_NAMES = @("master", "analytics")
```

#### 2. Extract Only from Dedicated Pools
```powershell
# Enable only dedicated pools
$DEDICATED_SERVER = "myworkspace.sql.azuresynapse.net"
$SERVERLESS_SERVER = ""  # Empty = disabled
$POOL_DEDICATED_NAMES = @("sales", "marketing")
# Serverless configuration is ignored when SERVERLESS_SERVER is empty
```

#### 3. Extract Only from Serverless Pool
```powershell
# Enable only serverless pools
$DEDICATED_SERVER = ""  # Empty = disabled
$SERVERLESS_SERVER = "myworkspace-ondemand.sql.azuresynapse.net"
$POOL_SERVELESS_NAME = "Built-in"
$POOL_SERVELESS_DATABASE_NAMES = @("master", "analytics", "staging")
# Dedicated configuration is ignored when DEDICATED_SERVER is empty
```

### Configuration Process
1. **Choose extraction scope**: Set server variables to enable/disable pool types
2. **Configure dedicated pools**: List your dedicated pools in POOL_DEDICATED_NAMES (if enabled)
3. **Configure serverless pool**: Set pool name and target databases (if enabled)
4. **Automatic validation**: Script validates configuration and provides clear error messages
5. Each dedicated pool automatically uses its pool name as the database name

### Result Structure
The extraction creates a hierarchical structure:
- **Pool Level**: Top-level directories for each pool
- **Database Creation**: Individual CREATE DATABASE files in databases/ subdirectory
- **Database Objects**: Organized by database → schema → object type
- **Object Files**: Individual SQL files with appropriate USE statements

### Key Benefits
- **Organized Output**: Clear separation between database creation and object definitions
- **Pool Isolation**: Each pool's objects are kept separate
- **Database Context**: All files include proper USE statements
- **Version Tracking**: Automatic version file generation for extraction metadata
- **Flexible Execution**: Run database creation separately from object creation

## Troubleshooting

### Common Issues

1. **"declare: -A: invalid option"** (Bash)
   - Your bash version doesn't support associative arrays
   - The scripts use simplified variable structure for compatibility

2. **Authentication Failures**
   - Ensure `az login` is completed successfully
   - Check that your account has access to the Synapse workspace
   - Verify server names are correct

3. **Empty Results**
   - Check that the pool names are spelled correctly in POOL_DEDICATED_NAMES or POOL_SERVELESS_NAME
   - Verify database names are correct in POOL_SERVELESS_DATABASE_NAMES
   - Ensure the SQL scripts in the `Scripts/` directory exist
   - **Check the `logs/` directory** for files that couldn't be parsed - these often contain error messages or empty results

4. **Permission Errors**
   - Your account needs read permissions on the Synapse databases
   - For dedicated pools, you need access to the specific pool
   - For serverless pools, you need access to the master database
   - **Review log files** in `logs/pool_name/database_name/` for specific error messages

### Validation

The scripts include built-in validation:
- **Configuration validation**: Ensures at least one pool type is enabled
- **Server endpoint validation**: Checks that enabled pool types have valid server configurations
- **Pool and database validation**: Validates pool names and database configurations
- **Clear error messages**: Provides specific guidance for configuration issues
- **Automatic skipping**: Safely skips disabled pool types with informative messages
- **Detailed logging**: Enhanced progress tracking and error handling
- **Debug file logging**: Automatically saves problematic files to logs directory with descriptive names

### Configuration Messages

The script provides clear feedback about which pool types are enabled:
- **"Dedicated pools: (ENABLED)"** - Dedicated pools will be processed
- **"Dedicated pools: (DISABLED - DEDICATED_SERVER not configured)"** - Dedicated pools will be skipped
- **"Serverless pool: (ENABLED)"** - Serverless pools will be processed  
- **"Serverless pools: (DISABLED - SERVERLESS_SERVER not configured)"** - Serverless pools will be skipped

## Reporting Issues and Feedback

If you encounter any bugs with the tool please file an issue in the
[Issues](https://github.com/Snowflake-Labs/SC.DDLExportScripts/issues) section of our GitHub repo.

## License

These export scripts are licensed under the [MIT license](https://github.com/Snowflake-Labs/SC.DDLExportScripts/blob/main/Redshift/License.txt).
