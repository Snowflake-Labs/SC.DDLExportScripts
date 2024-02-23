# Oracle DDL Export Scripts

This repository offers a collection of straightforward scripts designed to facilitate the export of your Oracle code, making it easier to migrate to [Snowflake](https://www.snowflake.com/). These scripts are specifically crafted to simplify the process of extracting your Oracle code artifacts, such as stored procedures, functions, and views, ensuring a smooth transition to [Snowflake](https://www.snowflake.com/) using [SnowConvert](https://docs.snowconvert.com/snowconvert/for-oracle/introduction).

## Version

Release 2024-02-23

## Prerequisites

### Sql\*Plus
  If you want to use SQL\*Plus, you need to have installed SQL\*Plus in your PC. 
  To verify that SQL\*Plus is installed and available for use, you can run a command to check its installation status. Open a command prompt or terminal and enter the following command:

```bash
sqlplus -v
```

If SQL\*Plus is installed and properly configured, you will see the version information displayed on the screen. This confirms that SQL\*Plus is installed and ready to be used for executing SQL commands and scripts.

### Conection string
  
You will need the conection string to your database. You can use a connection string for either a local database or a remotely hosted one. 

For example, if your database is hosted on AWS, you will need to use the connection format provided in this link: [AWS conection string](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ConnectToOracleInstance.SQLPlus.html). Therefore, a valid example connection string would be as follows:

  `TEST_USER@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=url.amazonaws.com)(PORT=1521))(CONNECT_DATA=(SID=orcl)))` 

The link contains detailed instructions on how to connect to an Oracle instance on AWS using SQL\*Plus or SQLcl. It provides the necessary format for specifying the connection details, such as the hostname, port, and SID. By following the instructions in the link, you will be able to establish a successful connection to your Oracle database hosted on AWS.

If you are using another hosting provider, please refer to their documentation to create the valid connection string.

It is recommended to use a user  with **sysadmin** privileges to logon.


## Usage

To obtain the necessary files for executing the DLL code generation, follow these detailed steps:

1. Open a web browser and navigate to the following URL: [releases](https://github.com/Snowflake-Labs/SC.DDLExportScripts/releases).

2. On the GitHub page, locate the "Release" section. This section usually contains a list of available releases or versions.

3. Look for the appropriate release or version that suits your needs. In this case, you should look for the release related to Oracle.

4. Once you have identified the correct release, search for the corresponding .zip file. This file usually contains all the necessary resources for the Oracle version of the DLL code generation script.

5. Click on the .zip file to start the download. The file will be saved to your default download location.

6. After the download is complete, navigate to the downloaded .zip file using File Explorer or a similar file management tool.

7. Extract the contents of the .zip file by right-clicking on it and selecting the "Extract All" or similar option. Choose a destination folder where you want to extract the files.

You are now ready to proceed with executing the DLL code generation using the files found in the "bin" and "script" folders.

In the "bin" folder, you will find the bash scripts for Unix/Linux environments or the batch scripts for Windows. These scripts are designed to facilitate the DLL code generation process, ensuring compatibility across different operating systems:

`bin` folder:

* create_ddls.bat: Use this file to run the extraction script for **Windows**. It requires Sql\*plus to run.
* create_ddls.sh: Use this file to run the extraction script for **Unix/Linux**. It requires Sqlcl to run.
* create_ddls_plus.sh: Use this file to run the extraction script for **Unix/Linux**. It requires Sql\*Plus to run.

In the "script" folder, you will find the .sql files specifically tailored for SQL*Plus or SQLcl. These files contain the necessary SQL statements to generate the DLL code.

If you are using a script that requires Sql\*plus, the scripts will use `create_ddls_plus.sql`. On the other hand, if the scripts use Sqlcl, they will use `create_ddls.sql`.

Regardless of whether you are working in a Linux/Unix or Windows environment, you have the appropriate scripts and files available to successfully execute the DLL code generation process.

## **For Linux/Unix:**

There are two options available to execute the extraction script based on your environment and the tools you have installed: SQL\*Plus and sqlcl.

* SQL\*Plus: If you have Oracle installed on your machine, you can use SQL\*Plus, which is a command-line tool for Oracle Database. It provides a powerful and interactive interface to execute SQL statements and scripts. Learn more about[SQL\*Plus here.](https://docs.oracle.com/en/database/oracle/oracle-database/21/sqpug/SQL-Plus-quick-start.html#GUID-BF1995BD-EF9B-4EA2-9B32-7BFACDEB79DA)

* sqlcl: If you don't have Oracle installed locally or prefer a modern command-line interface, you can use sqlcl (SQL Developer Command Line). Sqlcl is a free, lightweight tool provided by Oracle that offers a feature-rich SQL and PL/SQL scripting environment. It provides similar functionality to SQL\*Plus but with additional enhancements. Learn more about [Sqlcl here.](https://www.oracle.com/es/database/sqldeveloper/technologies/sqlcl/)

### Using SQLcl

1. Download the SQLcl software from: https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/download/
2. Extract the files in any directory that you choose.
3. Modify `create_ddls.sh` – Using a text editor modify the following parameters, for more details about the parameters see the [Notes area](#notes):

* `ORACLE_SID`
* `CONNECT_STRING`
* `SCRIPT_PATH`
* `SQLCL_PATH`
* `OUTPUT_PATH`
  
4. After modifying, the `create_ddls.sh` file can be run from the command line to execute the extract. 
   In order to run the script you can open a terminal in the folder where the  `create_ddls.sh` file is located and execute the command:
   ```bash
   source create_ddls.sh
   ```
   or
   ``` bash
   sh create_ddls_sqlcl.sh
   ``` 
   The following files will be created in the directory `/<OUTPUT_PATH>/object_extracts/DDL`. You can see a full list of expected files in the section [DDL files](#ddl-files).

### Using SQL\*Plus

1. Modify `create_ddls_plus.sh` – Using a text editor modify the following parameters, for more details about the parameters see the [Notes area](#notes):

* `ORACLE_SID`
* `CONNECT_STRING`
* `SCRIPT_PATH`
* `OUTPUT_PATH`

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
   The following files will be created in the directory `/<OUTPUT_PATH>/object_extracts/DDL`. You can see a full list of expected files in the section [DDL files](#ddl-files).

### Notes

* The `ORACLE_SID` is the System Identifier for the Oracle Instance.

* The `SCRIPT_PATH` is the path where the `create_ddls.sql` file is located within this repository.

* The `OUTPUT_PATH` is the directory where the script results will be generated. This directory contains the files generated with the script results. By default, the `OUTPUT_PATH` variable is set to `SCRIPT_PATH`. This path cannot have **space characters** in the string.

* The `SQLCL_PATH` is the path where the `sql` file is located within the folder that you downloaded and extracted previously from the sqlcl download link. Usually the path is `<extracted_files>/bin/`.

* The `CONNECT_STRING` is used to specify the necessary details for connecting to the database, including the server or IP address, port number, service name or SID, and login credentials. Please review the [Conection string](#conection-string) section for more details.

* It is recommended to use a user  with **sysadmin** privileges in the connection string and to run on a production-like environment with recently up to date statistics.

* By default the script is setup to exclude system related Oracle schemas and include all others.  You can modify the optional parameters above to get the desired scope, including the operator that is used. 

* This `create_ddls.sh` script was tested with sqlcl Version: 23.1.0.089.0929 for Mac OS.

* This `create_ddls_plus.sh` script was tested with sqlplus Version: 19.8.0.0.0 for Mac OS.


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
* `DDL_QUEUE_TABLES.sql`
* `DDL_OLAP_CUBES.sql`
* `DDL_MATERIALIZED_VIEWS.sql`
* `DDL_QUEUES.sql`
* `DDL_ANALYTIC_VIEWS.sql`
* `DDL_OPERATORS.sql`


## **For Windows:**

> **Should be executed on a windows with SQL\*Plus access to the Oracle environment.**

1 - Modify `create_ddls.bat` – Using a text editor modify the following parameters:

* `ORACLE_SID`
* `CONNECT_STRING`
* `SCRIPT_PATH`
* `OUTPUT_PATH`

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

### Notes

* The `ORACLE_SID` is the System Identifier for the Oracle Instance.

* The `SCRIPT_PATH` is the path where the `create_ddls.sql` file is located within this repository.

* The `OUTPUT_PATH` is the directory where the script results will be generated. This directory contains the files generated with the script results. By default, the `OUTPUT_PATH` variable is set to `SCRIPT_PATH`. This path cannot have **space characters** in the string.

* The `CONNECT_STRING` is used to specify the necessary details for connecting to the database, including the server or IP address, port number, service name or SID, and login credentials. Please review the [Conection string](#conection-string) section for more details.


* This script was tested with Sql\*Plus Version: 19.19.0.0.0 for Windows x64.

## Known errors and FAQs

### SQL\*Plus is not found
If you do not have SQL\*Plus installed, you will encounter the following error when attempting to execute the script:

```bash
sh create_ddls_plus.sh
create_ddls_plus.sh:27: command not found: sqlplus
``` 

This error indicates that the `sqlplus` command is not recognized or available in your system. SQL\*Plus is a command-line tool provided by Oracle for interacting with Oracle databases. To resolve this issue, you will need to install SQL\*Plus and ensure that it is properly configured and accessible from the command line.

### User with limit access

If you execute the script using a database user that does not have sufficient privileges to view and query database objects, no output files will be generated. If you encounter any errors during the script execution and wish to see the error messages, you can navigate to the `create_ddls.sql` file if you are using sqlcl or `create_ddls_plus.sql` file if you use SQL\*Plus and comment out the line `SET TERMOUT OFF`. By doing so, you will enable the display of logs and error messages in the terminal/console.

By commenting out the `SET TERMOUT OFF` line, you allow the script to print the logs and error messages to the terminal, providing valuable information for troubleshooting and identifying any issues that may have occurred during the execution.

Remember to revert the change by uncommenting the `SET TERMOUT OFF` line once you have completed the troubleshooting process to resume the normal behavior of the script.

### Insufficient JVM memory

1. If you encounter "insufficient memory" errors while executing the script, you can uncomment the following line in the `create_ddls.sh` or `create_ddls_plus.sh` file to allocate 4 GB of RAM: `export JAVA_TOOL_OPTIONS=-Xmx4G`. You can modify this parameter by changing the number on the line to allocate a different amount of memory.

2. If you encounter a memory heap error while working with the script, it may be helpful to reduce the values of the LONGCHUNKSIZE variable. This variable determines the size of memory chunks allocated for handling long data in SQL statements. By modifying the LONGCHUNKSIZE value, you can potentially address the memory issue.
If you are using SQLcl, you can make the necessary changes in the `create_ddls.sql` file. Locate the LONGCHUNKSIZE variable declaration within the file and adjust its value according to your needs. Save the file and rerun the script again.
If you are using SQLPlus, navigate to the `create_ddls_plus.sql` file. In this file, find the declaration of the LONGCHUNKSIZE variable and modify it as required. Save the file and execute it again.
By experimenting with different LONGCHUNKSIZE values, you can optimize memory allocation and potentially overcome memory heap errors. It's recommended to test and adjust the value carefully, considering the specific requirements and limitations of your environment.

### Unnecessary blank tab spaces or missing code

If you encounter an issue with unnecessary blank tab spaces or truncated code, you may need to increase the size of the LONGCHUNKSIZE variable found in the create_ddls.sql or create_ddls_plus.sql file, depending on the technology you are using.

Excessive blank tab spaces or truncated code can cause syntax errors or unexpected behavior in your scripts. Adjusting the LONGCHUNKSIZE variable allows for larger memory allocations when handling long data in SQL statements.

To address this issue, locate the LONGCHUNKSIZE variable declaration in the respective file (`create_ddls.sql` for SQLcl or `create_ddls_plus.sql` for SQL\*Plus). Modify the value of LONGCHUNKSIZE to a larger value that suits your requirements. Save the file and rerun your SQL utility.

By increasing the LONGCHUNKSIZE, you provide more memory for handling long data, which can help resolve problems related to unnecessary tab spaces or truncated code. Remember to consider the limitations of your environment when adjusting this variable. If you enter a large number, you may encounter insufficient memory errors. The recommendation is to increase this number in increments of thousands to meet the required specifications.


## Reporting issues and feedback

If you encounter any bugs with the tool please file an issue in the
[Issues](https://github.com/Snowflake-Labs/SC.DDLExportScripts/issues) section of our GitHub repo.

## License

These export scripts are licensed under the [MIT license](https://github.com/Snowflake-Labs/SC.DDLExportScripts/blob/main/Oracle/License.txt).