﻿# Oracle DDL Export Scripts

This repository provides some simple scripts to help exporting your Oracle code
so it can be migrated to [Snowflake](https://www.snowflake.com/) using [SnowConvert](https://docs.snowconvert.com/snowconvert/for-oracle/introduction)

## Version

Release 2021-06-05

## Prerequisites

* If you want to use Sql*Plus, you need to have installed Oracle in you PC. 
  To verify that SQL*Plus is installed and available for use, you can run a command to check its installation status. Open a command prompt or terminal and enter the following command:

```bash
sqlplus -v
```

If SQL*Plus is installed and properly configured, you will see the version information displayed on the screen. This confirms that SQL*Plus is installed and ready to be used for executing SQL commands and scripts.

* You will need the conection string to your database. If your database is hosted on AWS, you will need to use the connection format provided in this link: [AWS conection string](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ConnectToOracleInstance.SQLPlus.html). An example of the connection string could be: 
  `TEST_USER@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=url.amazonaws.com)(PORT=1521))(CONNECT_DATA=(SID=orcl)))` 

The link contains detailed instructions on how to connect to an Oracle instance on AWS using SQL*Plus or SQLcl. It provides the necessary format for specifying the connection details, such as the hostname, port, and SID. By following the instructions in the link, you will be able to establish a successful connection to your Oracle database hosted on AWS.
* It is recommended to use a user  with **sysadmin** privileges.


## Usage

The following are the steps to execute the DDL Code Generation. They can be executed in Linux/Unix and Windows enviroments.

## **For Linux/Unix:**

There are two options available to execute the extraction script based on your environment and the tools you have installed: Sql*Plus and sqlcl.

Sql*Plus: If you have Oracle installed on your machine, you can use Sql*Plus, which is a command-line tool for Oracle Database. It provides a powerful and interactive interface to execute SQL statements and scripts. 

sqlcl: If you don't have Oracle installed locally or prefer a modern command-line interface, you can use sqlcl (SQL Developer Command Line). Sqlcl is a free, lightweight tool provided by Oracle that offers a feature-rich SQL and PL/SQL scripting environment. It provides similar functionality to Sql*Plus but with additional enhancements. 

### Using SQLcl

1. Download the SQLcl software from: https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/download/
2. Extract the files in any directory that you choose.
3. Modify `create_ddls.sh` – Using a text editor modify the following parameters, for more details about the parameters see the [Notes area](#notes):

* `ORACLE_SID`
* `CONNECT_STRING`
* `SCRIPT_PATH`
* `SQLCL_PATH`
  
4. After modifying, the `create_ddls.sh` file can be run from the command line to execute the extract. 
   In order to run the script you can open a terminal in the  `create_ddls.sh` path  and execute the command:
   ```bash
   source create_ddls.sh
   ```
   or
   ``` bash
   sh create_ddls_sqlcl.sh
   ``` 
   The following files will be created in the directory `/<SCRIPT_PATH>/object_extracts/DDL`.

### Using Sql*Plus

1. Modify `create_ddls_plus.sh` – Using a text editor modify the following parameters, for more details about the parameters see the [Notes area](#notes):

* `ORACLE_SID`
* `CONNECT_STRING`
* `SCRIPT_PATH`

Optionally modify these parameters (see comments in the file for explanation of parameters):

* `INCLUDE_OPERATOR`
* `INCLUDE_CONDITION`
* `EXCLUDE_OPERATOR`
* `EXCLUDE_CONDITION`

2 - After modifying, the `create_ddls_plus.sh` file can be run from the command line to execute the extract. 
   In order to run the script you can use the command 
   ```bash
   source create_ddls.sh
   ```
   or
   ``` bash
   sh create_ddls.sh
   ``` 
   The following files will be created in the directory `/object_extracts/DDL`.

### Notes

* The `ORACLE_SID` is the System Identifier for the Oracle Instance.

* The `SCRIPT_PATH` is the path where the `create_ddls.sql` file is located within this repository.

* The `SQLCL_PATH` is the path where the `sql` file is located within the folder that you downloaded and extracted previously from the sqlcl download link. Usually the path is `<extracted_files>/bin/`.

* It is recommended to use a user  with **sysadmin** privileges in the connection string and to run on a production-like environment with recently up to date statistics.

* By default the script is setup to exclude system related Oracle schemas and include all others.  You can modify the optional parameters above to get the desired scope, including the operator that is used. 

> Do not remove the parentheses around the entire statement which are needed for compound logic.  The **NOT** statement is already included in the code for the exclusion operator/condition.

### DDL Files
These files will contain the definitions of the objects specified by the file name.

*	`DDL_DBlink.sql`
*	`DDL_Functions.sql`
*	`DDL_Indexes.sql`
*	`DDL_Packages.sql`
*	`DDL_Procedures.sql`
*	`DDL_Sequences.sql`
*	`DDL_Synonyms.sql`
*	`DDL_Tables.sql`
*	`DDL_Triggers.sql`
*	`DDL_Types.sql`
*	`DDL_Views.sql`
*   `DDL_QUEUE_TABLES.sql`
*   `DDL_OLAP_CUBES.sql`
*   `DDL_MATERIALIZED_VIEWS.sql`
*   `DDL_QUEUES.sql`
*   `DDL_ANALYTIC_VIEWS.sql`
*   `DDL_OPERATORS.sql`


## **For Windows:**

> **Should be executed on a windows server with Sql*Plus access to the Oracle environment.**

1 - Modify `create_ddls.bat` – Using a text editor modify the following parameters:

* `ORACLE_SID`
* `CONNECT_STRING`
* `SCRIPT_PATH`

Optionally modify these parameters (see comments in the file for explanation of parameters):

* `INCLUDE_OPERATOR`
* `INCLUDE_CONDITION`
* `EXCLUDE_OPERATOR`
* `EXCLUDE_CONDITION`

It is recommended to use a user  with **sysadmin** privileges in the connection string and to run on a production-like environment with recently up to date statistics.

By default the script is setup to exclude system related Oracle schemas and include all others.  You can modify the optional parameters above to get the desired scope, including the operator that is used.   

> Do not remove the parentheses around the entire statement which are needed for compound logic.  The **NOT** statement is already included in the code for the exclusion operator/condition.


2 - After modifying, the `create_ddls.bat` file can be run from the command line to execute the extract.  The following files will be created in the directory `/object_extracts/DDL`:

### DDL Files

These files will contain the definitions of the objects specified by the file name.

*	`DDL_DBlink.sql`
*	`DDL_Functions.sql`
*	`DDL_Indexes.sql`
*	`DDL_Packages.sql`
*	`DDL_Procedures.sql`
*	`DDL_Sequences.sql`
*	`DDL_Synonyms.sql`
*	`DDL_Tables.sql`
*	`DDL_Triggers.sql`
*	`DDL_Types.sql`
*	`DDL_Views.sql`
*   `DDL_QUEUE_TABLES.sql`
*   `DDL_OLAP_CUBES.sql`
*   `DDL_MATERIALIZED_VIEWS.sql`
*   `DDL_QUEUES.sql`
*   `DDL_ANALYTIC_VIEWS.sql`
*   `DDL_OPERATORS.sql`

You can then zip the `/object_extracts/DDL` so it these files can then be processed with [SnowConvert](https://docs.snowconvert.com/snowconvert/for-oracle/introduction).

## Know errors and FAQs

### Sql*Plus is not found
If you do not have SQL*Plus installed, you will encounter the following error when attempting to execute the script:

```bash
sh create_ddls_plus.sh
create_ddls_plus.sh:27: command not found: sqlplus
``` 

This error indicates that the `sqlplus` command is not recognized or available in your system. SQL*Plus is a command-line tool provided by Oracle for interacting with Oracle databases. To resolve this issue, you will need to install SQL*Plus and ensure that it is properly configured and accessible from the command line.

### User with limit access

If you execute the script using a database user that does not have sufficient privileges to view and query database objects, no output files will be generated. If you encounter any errors during the script execution and wish to see the error messages, you can navigate to the `create_ddls.sql` file if you are using sqlcl or `create_ddls_plus.sql` file if you use sql*Plus and comment out the line `SET TERMOUT OFF`. By doing so, you will enable the display of logs and error messages in the terminal/console.

By commenting out the `SET TERMOUT OFF` line, you allow the script to print the logs and error messages to the terminal, providing valuable information for troubleshooting and identifying any issues that may have occurred during the execution.

Remember to revert the change by uncommenting the `SET TERMOUT OFF` line once you have completed the troubleshooting process to resume the normal behavior of the script.

### Insufficient JVM memory

If you encounter "insufficient memory" errors while executing the script, you can uncomment the following line in the `create_ddls.sh` or `create_ddls_plus.sh` file to allocate 4 GB of RAM: `export JAVA_TOOL_OPTIONS=-Xmx4G`. You can modify this parameter by changing the number on the line to allocate a different amount of memory.

## Reporting issues and feedback

If you encounter any bugs with the tool please file an issue in the
[Issues](https://github.com/Snowflake-Labs/SC.DDLExportScripts/issues) section of our GitHub repo.

## License

These export scripts are licensed under the [MIT license](https://github.com/Snowflake-Labs/SC.DDLExportScripts/blob/main/Oracle/License.txt).