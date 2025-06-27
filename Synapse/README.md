# Synapse Export Scripts

This repository provides scripts to help export your Azure Synapse SQL objects so they can be migrated to [Snowflake](https://www.snowflake.com/) using [SnowConvert](https://docs.snowconvert.com/sc).

## Version
0.0.96

### Prerequisites

To start, please download this folder or clone this repository into your computer.

This solution provides 2 alternatives to extract the data:

- **Windows Script**: `Create_ddls.ps1` - PowerShell script with Azure CLI + sqlcmd
- **Linux/macOS Script**: `Create_ddls.sh` - Bash script with Azure CLI + sqlcmd

Both scripts now support **multiple Azure Synapse pools** (dedicated and serverless) in a single execution.

## Key Features

- **Multi-Pool Support**: Process multiple Synapse pools in one run
- **Mixed Pool Types**: Support both dedicated and serverless pools simultaneously
- **Pool-First Organization**: Generated files organized by pool → schema → object type → object name
- **USE Statement Generation**: Each SQL file includes appropriate `USE [pool_name];` statements
- **Bash Compatibility**: Uses parallel arrays for compatibility with older bash versions
- **Enhanced Logging**: Detailed progress tracking and error handling
- **Safe Directory Naming**: Handles pools with special characters in names

## Directory Structure

The scripts generate SQL files in the following structure:
```
parsed_sql_definitions/
├── pool_name_1/
│   ├── schema_name/
│   │   ├── tables/
│   │   │   ├── table1.sql
│   │   │   └── table2.sql
│   │   ├── views/
│   │   │   └── view1.sql
│   │   ├── procedures/
│   │   │   └── proc1.sql
│   │   └── indexes/
│   │       └── index1.sql
│   └── another_schema/
│       └── ...
├── pool_name_2/
│   └── ...
```

Each generated SQL file includes:
```sql
USE [pool_name];
GO

-- Original object DDL here
CREATE TABLE [schema].[table_name] (
    ...
);
```

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
1. Uncomment and modify the SQL authentication line in the script:
   ```bash
   # Bash
   AUTH_FLAGS="-U your_username -P your_password -I"
   ```
   ```powershell
   # PowerShell
   $AuthFlags = "-U your_username -P your_password -I"
   ```

### Configuration

Open `Create_ddls.ps1` (Windows) or `Create_ddls.sh` (Linux/macOS) and configure:

#### 1. Server Endpoints
```bash
# Bash
DEDICATED_SERVER="your-synapse-workspace.database.windows.net"
SERVERLESS_SERVER="your-synapse-workspace-ondemand.sql.azuresynapse.net"
```

```powershell
# PowerShell
$DEDICATED_SERVER = "your-synapse-workspace.database.windows.net"
$SERVERLESS_SERVER = "your-synapse-workspace-ondemand.sql.azuresynapse.net"
```

#### 2. Pool Configuration
Configure your pools using parallel arrays:

```bash
# Bash
POOL_NAMES=(
    "dedicated_pool_1"
    "dedicated_pool_2"
    "Built-in"
)

POOL_TYPES=(
    "dedicated"
    "dedicated"
    "serverless"
)
```

```powershell
# PowerShell
$POOL_NAMES = @(
    "dedicated_pool_1",
    "dedicated_pool_2",
    "Built-in"
)

$POOL_TYPES = @(
    "dedicated",
    "dedicated",
    "serverless"
)
```

**Important**: Both arrays must have the same number of elements and correspond by index.

### Pool Types

- **dedicated**: Uses the pool name as the database and connects to the dedicated server
- **serverless**: Uses "master" as the database and connects to the serverless server

### Execution

After configuration, run the appropriate script:

```bash
# Linux/macOS
./Create_ddls.sh

# Windows PowerShell
.\Create_ddls.ps1
```

### What Gets Extracted

#### Dedicated Pools
- Tables
- Views
- Stored Procedures
- Functions
- Schemas
- External Tables
- Indexes

#### Serverless Pools
- External Tables
- External Views
- External Data Sources
- External File Formats
- Schemas

## Example Configuration

Here's a complete example for a mixed environment:

```bash
# Bash Example
POOL_NAMES=(
    "sales_dwh"           # Dedicated pool for sales data
    "marketing_dwh"       # Dedicated pool for marketing
    "Built-in"           # Serverless pool
    "data_lake"          # Another serverless pool
)

POOL_TYPES=(
    "dedicated"
    "dedicated"
    "serverless"
    "serverless"
)
```

This configuration will:
1. Extract all objects from `sales_dwh` dedicated pool
2. Extract all objects from `marketing_dwh` dedicated pool  
3. Extract serverless objects from `Built-in` pool
4. Extract serverless objects from `data_lake` pool

## Troubleshooting

### Common Issues

1. **"declare: -A: invalid option"** (Bash)
   - Your bash version doesn't support associative arrays
   - The scripts now use parallel arrays for compatibility

2. **Authentication Failures**
   - Ensure `az login` is completed successfully
   - Check that your account has access to the Synapse workspace
   - Verify server names are correct

3. **Empty Results**
   - Check that the pool names are spelled correctly
   - Verify the pool type (dedicated vs serverless) is correct
   - Ensure the SQL scripts in the `Scripts/` directory exist

4. **Permission Errors**
   - Your account needs read permissions on the Synapse databases
   - For dedicated pools, you need access to the specific pool
   - For serverless pools, you need access to the master database

### Validation

The scripts include built-in validation:
- Checks that arrays have matching lengths
- Validates pool names and types
- Provides detailed logging for troubleshooting

## Reporting Issues and Feedback

If you encounter any bugs with the tool please file an issue in the
[Issues](https://github.com/Snowflake-Labs/SC.DDLExportScripts/issues) section of our GitHub repo.

## License

These export scripts are licensed under the [MIT license](https://github.com/Snowflake-Labs/SC.DDLExportScripts/blob/main/Redshift/License.txt).
