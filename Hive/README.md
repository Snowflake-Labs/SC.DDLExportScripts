# Hive DDL Export Script

This repository provides scripts to help exporting Hive DDL so it can be migrated to [Snowflake](https://www.snowflake.com/). Hive versions 4.0 and above, as well as versions below 4.0, are supported.

## Version
0.0.94

## Usage

Extracts all table and view DDL in the specified database, wildcard match, or all databases on the system (default). Beeline is used by default to create a JDBC connection to Hive. No data is extracted. There are no third-party binary packages installed or used.

This script can be executed in Linux or Unix from the command line. 

>**Important:** Extraction can take time. Databases in scope of migration should have DDL extracted only. If databases contain many objects or there are many databases, the process should be broken up into sets of databases using a wildcard or individual database extraction.

### 1. Environment Configuration

Open `exp_ddl.sh` in a text editor and navigate to the "ENVIRONMENT CONFIGURATION" section starting on or around line 17.

1. Update `HOST` to match the host name of the server where Hive is running and will be used make a JDBC connection. 

    Default: `localhost`

2. Update `PORT` to match the port number of the server where Hive is running and will be used to make a JDBC connection. 

    Default: `10000`

3. Update `databasefilter` to explicitly name a single database or use a wildcard to match database names for a list of databases to extract DDL from. **The wildcard for Hive < 4.0 is `*` whereas the wildcard for >= 4.0 is `%`.** 

    Default: `*` (all databases, supporting Hive < 4.0)

4. (Optional) Update `root` to a customer folder name where the output is stored. 

    Default: `ddl_extract` in the folder where this script is executed

### 2. Hive Extraction Command Options

By default, beeline CLI is used to create a JDBC connection. Alternatively the Hive CLI can be used. Open `exp_ddl.sh` in a text editor and navigate to the "HIVE EXTRACTION COMMAND OPTIONS" section starting on or around line 49.
1. Select use of `beeline` or `hive` by commenting with a `#` the undesired command and uncommenting the desired command. 

    Default: `beeline`

### 3. Confirm extract script version

Run `./exp_ddls.sh --version` from the command line and verify the version matches the release version at the top of this readme.

### 4. Start DDL extraction

Run `./exp_ddl.sh` from the command line to execute the extract. The DDL files will be created in the current directory under `ddl_extract` subdirectory unless a different location was specified in the "Environment Configuration" section.

### 5. Share output

After extracting DDL for all in-scope databases, send the extracted DDL SQL files and objects CSV files to your Snowflake representative for assessment and next steps. If you are not working with a Snowflake representative, skip this step.

## Reporting issues and feedback

If you encounter any bugs with the script, first reach out to the Snowflake representative you are working with. If you are not working with a Snowflake representative, file an issue in the [Issues](https://github.com/Snowflake-Labs/SC.DDLExportScripts/issues) section of the GitHub repository.

## License

