# Oracle Exporter

We’re excited to introduce Oracle Exporter, a simple tool to help exporting your Oracle Code
so it can be migrated to Snowflake.

## Version

Release 2021-05-10

## Usage

The following are the steps to execute the DDL Code Generation. They can be executed in Linux/Unix and Windows enviroments.

**For Linux/Unix:**

1 - Modify `createddls.sh` – Using a text editor modify the following parameters:

* ORACLE_SID
* CONNECT_STRING
* SCRIPT_PATH

Optionally modify these parameters (see comments in the file for explanation of parameters):

* INCLUDE_OPERATOR
* INCLUDE_CONDITION
* EXCLUDE_OPERATOR
* EXCLUDE_CONDITION

It is recommended to use a user  with sysadmin privileges in the connection string and to run on a production-like environment with recently up to date statistics.

By default the script is setup to exclude system related Oracle schemas and include all others.  You can modify the optional parameters above to get the desired scope, including the operator that is used.   Do not remove the parentheses around the entire statement which are needed for compound logic.  The NOT statement is already included in the code for the exclusion operator/condition.


2 - After modifying, the `create_ddls.sh` file can be run from the command line to execute the extract.  The following files will be created in the directory `/object_extracts/DDL`:

DDL Files - These files will contain the definitions of the objects specified by the file name.

*	DDL_DBlink.sql
*	DDL_Functions.sql
*	DDL_Indexes.sql
*	DDL_Macros.sql
*	DDL_Packages.sql
*	DDL_Procedures.sql
*	DDL_Sequences.sql
*	DDL_Synonyms.sql
*	DDL_Tables.sql
*	DDL_Triggers.sql
*	DDL_Types.sql
*	DDL_Views.sql


**For Windows:**

**Should be executed on a windows server with sqlplus access to the Oracle environment.**

1 - Modify `create_ddls.bat` – Using a text editor modify the following parameters:

* ORACLE_SID
* CONNECT_STRING
* SCRIPT_PATH

Optionally modify these parameters (see comments in the file for explanation of parameters):

* INCLUDE_OPERATOR
* INCLUDE_CONDITION
* EXCLUDE_OPERATOR
* EXCLUDE_CONDITION

It is recommended to use a user  with sysadmin privileges in the connection string and to run on a production-like environment with recently up to date statistics.

By default the script is setup to exclude system related Oracle schemas and include all others.  You can modify the optional parameters above to get the desired scope, including the operator that is used.   Do not remove the parentheses around the entire statement which are needed for compound logic.  The NOT statement is already included in the code for the exclusion operator/condition.


2 - After modifying, the `create_ddls.bat` file can be run from the command line to execute the extract.  The following files will be created in the directory `/object_extracts/DDL`:

DDL Files - These files will contain the definitions of the objects specified by the file name.

*	DDL_DBlink.sql
*	DDL_Functions.sql
*	DDL_Indexes.sql
*	DDL_Macros.sql
*	DDL_Packages.sql
*	DDL_Procedures.sql
*	DDL_Sequences.sql
*	DDL_Synonyms.sql
*	DDL_Tables.sql
*	DDL_Triggers.sql
*	DDL_Types.sql
*	DDL_Views.sql

## Reporting issues and feedback

If you encounter any bugs with the tool please file an issue in the
[Issues](https://github.com/MobilizeNet/SnowConvertDDLExportScripts/issues) section of our GitHub repo.

## License

Oracle Exporter is licensed under the [MIT license](https://github.com/MobilizeNet/SnowConvertDDLExportScripts/blob/main/Oracle/LICENSE.txt).


