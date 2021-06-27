# Usage Guide
Contents:

[Options](#options)

[Examples](#examples)


## Description
sc-tera-export is a simple tool to help you to export Teradata code so it can be upgraded to SnowFlake using the SnowConvert Tool.

The sc-tera-export can be used to generate extraction scripts that can be run to generate data definition language (DDL) a for database objects in Teradata.

Those output scripts can then be used as an input for the [SnowConvert Tool](https://www.mobilize.net/products/database-migrations/snowconvert)


## Options
For option parameters, pass in '-h': 

    usage: sc-tera-export [-h] -S  -U  -P

    Mobilize.NET Teradata Code Export ToolsVersion 1.0.0a1

    optional arguments:
    -h, --help        show this help message and exit
    -S , --server     Server address. For example: 127.0.0.1
    -U , --user       Login ID for server. Usually it will be the DBC user
    -P , --password   The password for the given user.


## About the generated exrtaction scripts

STEPS TO EXECUTE DDL CODE GENERATION

> These scripts **should be executed** in bash shell on a linux environment with access to bteq/tpt utilities.


### Step 1
Review the ***create_ddls.sh*** in the bin folder.

Using a text editor modify the following parameters:

- `connection_string`
- `include_databases`
- `exclude_databases`
- `include_objects` 

It is recommended to use the user `DBC` in the connection string but a user with `sysadmin` privileges should also work. Please run on a production-like environment with up to date statistics.

By default the script is setup to exclude system related databases and include all others.

You can modify these to get the desired scope, including the operator that is used.  

Statements need to exclude spaces in the parameter values and values should be all **UPPERCASE**. 

> Do **not** remove the parentheses around the entire statement which are needed for compound logic.  
> Do **not** use `LIKE ANY` clause for both as it can cause unexpected issues.  
Example values:  
>  `“(UPPER(T1.DATABASENAME) NOT IN (‘ALL’, ‘TESTDB’))”`   
> `“(UPPER(T1.DATABASENAME) NOT IN (‘ALL’, ‘TESTDB’)) AND UPPER(T1.DATABASENAME) NOT LIKE (‘TD_%’))"` 

### Step 2
After modification, the `create_ddls.sh` file can be run from the command line to execute the extract from within the `bin` directory.  

The following files and folders will be created in the output folder:

#### DDL Files 
These files will contain the definitions of the objects specified by the file name.

*	`DDL_Databases.sql`
*	`DDL_Tables.sql`
*	`DDL_Join_Indexes.sql`
*	`DDL_Views.sql`
*	`function/**/*.sql` (a folder for each database with a .sql file for each function)
*   `macro/**/*.sql` (a folder for each database with a .sql file for each macro)
*	`procedure/**/*.sql` (a folder for each database with a .sql file for each procedure)
*	`insert_statements.sql` (these are 2 dummy records created for each Teradata Table - **NOT CUSTOMER DATA**)

#### Report Files

These files provide information around key system statistics and objects that can have a specific impact on conversion and migration activities.


*	`Object_Type_List.txt`
*	`Object_Type_Summary.txt`
*	`Table_List.txt`
*	`Special_Columns_List.txt`
*	`All_Stats.txt`
*	`Table_Stats.txt`
*	`View_Dependency_Detail.txt`
*	`View_Dependency_Report.txt`
*	`Object_Join_Indexes.txt`

#### Usage Report Files 

These files provide information relevant to the sizing and usage of the Teradata system.   

These will not be created unless you uncomment the section for “Creating Usage Reports”

*	90_Day_CPU_Stats.txt

*	90_Day_Node_Stats.txt

*	90_Day_Workload_Stats.txt

#### Data Profiling Files 

These collect information about certain column types in which information about the data is required to understand certain aspects of the migration.

*	`Data_Profile_Numbers.txt`

#### Invalid Objects Log 

This file returns results showing any test failures for views that are not valid.

*	`invalid_objects.log`

#### TPT Script Files 

These files contain auto-generated scripts which can later be used in the data migration process.   

*	`tpt_export_single_script.tpt`
*	`tpt_export_multiple_scripts.tpt`
*	`tables_not_in_tpt_scripts.txt`

### Step 3

After a successful run, just delete the `bin` and `scripts` folder.

Compress the entire `output` folder and send it over for convertion. 

This will be the input for the [SnowConvert Tool](https://www.mobilize.net/products/database-migrations/snowconvert).  
Please **do not modify** or **remove** any files so that we can review logs as needed.