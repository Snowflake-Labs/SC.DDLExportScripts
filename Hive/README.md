# Hive DDL Export Scripts

This repository provides some simple scripts to help exporting your Hive code
so it can be migrated to [Snowflake](https://www.snowflake.com/) using [SnowConvert](https://docs.snowconvert.com/snowconvert/apache-hive/introduction)

## Version 1.1

Release 2021-12-03

## Usage

The following are the steps to execute the DDL Code Generation. They can be executed in Linux/Unix.

1 - Modify `exp_ddl.sh` – Using a text editor modify the following parameters:

* `HOST`
* `PORT`

2 - After modifying, the `exp_ddl.sh` file can be run from the command line to execute the extract.  The following files will be created in the current directory under `ddl_extract`:

`./exp_ddl.sh`

## Reporting issues and feedback

If you encounter any bugs with the tool please file an issue in the
[Issues](https://github.com/Snowflake-Labs/SC.DDLExportScripts/issues) section of our GitHub repo.

## License

These export scripts are licensed under the [MIT license](https://github.com/Snowflake-Labs/SC.DDLExportScripts/blob/main/Hive/License.txt).