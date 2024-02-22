# Teradata Export Scripts

This repository provides some simple scripts to help exporting your Teradata code so it can be migrated to [Snowflake](https://www.snowflake.com/) using [SnowConvert](https://docs.snowconvert.com/snowconvert/for-teradata/introduction)

## Version

Release 2023-02-01

## Usage

The following are the steps to execute the DDL Code Generation. They should be executed in bash shell on a linux environment with access to bteq/tpt utilities.

1 - Modify `create_ddls.sh` in the bin folder – Using a text editor modify the following parameters:

* `connection_string`
* `include_databases`
* `exclude_databases`
* `include_objects`

It is recommended to use the user 'DBC' in the connection string but a user with sysadmin privileges should also work. Please run on a production-like environment with up to date statistics.

By default the script is setup to exclude system related databases and include all others. You can modify these to get the desired scope, including the operator that is used. Statements need to exclude spaces in the parameter values and values should be all **UPPERCASE**. 
By default, all the comments in source code are preserved. If comments needed to be removed, contact Snowflake team.
Executing the create_ddl.sh permanently changes create_ddl.btq file. A copy of "create_ddl.btq" can be used if needed. 

> Do not remove the parentheses around the entire statement which are needed for compound logic. 
> Do not use **LIKE ANY** clause for both as it can cause unexpected issues. 

Example values:

```sql
(UPPER(T1.DATABASENAME) NOT IN ('ALL', 'TESTDB'));

(UPPER(T1.DATABASENAME) NOT IN ('ALL', 'TESTDB')) AND UPPER(T1.DATABASENAME) NOT LIKE ('TD_%'))
```

2 - After modifying, the `create_ddls.sh` file can be run from the command line to execute the extract from within the bin directory. The following files will be created in the output folder:

## object_extracts

This folder consist of several subfolders for each extracted object type. Which are the following:

* `function`
* `joinindex`
* `macro`
* `procedure`
* `schema`
* `table`
* `trigger`
* `unknown`
* `view`

Each of them contains folders for the extracted databases, and within them are the extracted sql files.
For example, the output file structure of object_extracts should be similar to the following structure:

* function
    * database_1
        * function_1.sql
    * database_2
        * function_2.sql
* Table
    * database_1
        * USER.sql
        * USER_DETAILS.sql



## Reporting issues and feedback

If you encounter any bugs with the tool please file an issue in the
[Issues](https://github.com/Snowflake-Labs/SC.DDLExportScripts/issues) section of our GitHub repo.

## License

These scripts are licensed under the [MIT license](https://github.com/Snowflake-Labs/SC.DDLExportScripts/blob/main/Teradata/License.txt).
