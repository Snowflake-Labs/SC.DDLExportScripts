# Teradata Exporter

We’re excited to introduce Teradata Exporter, a simple tool to help exporting your Teradata Code
so it can be migrated to Snowflake.

## Version

Release 2020-01-28

## Usage

The following are the steps to execute the DDL Code Generation. They should be executed in bash shell on a linux environment with access to bteq/tpt utilities.

1 - Modify `create_ddls.sh` in the bin folder – Using a text editor modify the following parameters:

* connection_string
* include_databases
* exclude_databases
* include_objects

It is recommended to use the user 'DBC' in the connection string but a user with sysadmin privileges should also work. Please run on a production-like environment with up to date statistics.

By default the script is setup to exclude system related databases and include all others. You can modify these to get the desired scope, including the operator that is used. Statements need to exclude spaces in the parameter values and values should be all UPPERCASE. Do not remove the parentheses around the entire statement which are needed for compound logic. Do not use LIKE ANY clause for both as it can cause unexpected issues. Example values:

```sql
(UPPER(T1.DATABASENAME) NOT IN ('ALL', 'TESTDB'));

(UPPER(T1.DATABASENAME) NOT IN ('ALL', 'TESTDB')) AND UPPER(T1.DATABASENAME) NOT LIKE ('TD_%'))
```

2 - After modifying, the `create_ddls.sh` file can be run from the command line to execute the extract from within the bin directory. The following files will be created in the output folder:

DDL Files - These files will contain the definitions of the objects specified by the file name.

* DDL_Databases.sql
* DDL_Tables.sql
* DDL_Join_Indexes.sql
* DDL_Functions.sql
* DDL_Views.sql
* DDL_Macros.sql
* DDL_Procedures.sql
* Insert_statements.sql (these are 2 dummy records created for each Teradata Table - NOT CUSTOMER DATA)

Report Files - These files provide information around key system statistics and objects that can have a specific impact on conversion and migration activities.

* Object_Type_List.txt
* Object_Type_Summary.txt
* Table_List.txt
* Special_Columns_List.txt
* All_Stats.txt
* Table_Stats.txt
* View_Dependency_Detail.txt
* View_Dependency_Report.txt
* Object_Join_Indexes.txt

Usage Report Files - These files provide information relevant to the sizing and usage of the Teradata system. These will not be created unless you uncomment the section for Creating Usage Reports

* 90_Day_CPU_Stats.txt
* 90_Day_Node_Stats.txt
* 90_Day_Workload_Stats.txt

Data Profiling Files - These collect information about certain column types in which information about the data is required to understand certain aspects of the migration.

* Data_Profile_Numbers.txt

Invalid Objects Log - This file returns results showing any test failures for views that are not valid.

* invalid_objects.log

TPT Script Files - These files contain auto-generated scripts which can later be used in the data migration process.

* tpt_export_single_script.tpt
* tpt_export_multiple_scripts.tpt
* tables_not_in_tpt_scripts.txt

3 - After a successful run, remove logon information from the top line of each of the files in the scripts folder as well as the `create_ddls.sh` file. Compress the entire Teradata Source Extract and return to Snowflake. Please do not modify or remove any files so that we can review logs as needed.

## Reporting issues and feedback

If you encounter any bugs with the tool please file an issue in the
[Issues](https://github.com/MobilizeNet/SnowConvertDDLExportScripts/issues) section of our GitHub repo.

## License

Teradata Exporter is licensed under the [MIT license](https://github.com/MobilizeNet/SnowConvertDDLExportScripts/blob/main/Teradata/LICENSE.txt).
