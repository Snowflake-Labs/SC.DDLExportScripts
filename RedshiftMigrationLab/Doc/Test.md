# Testing the solution Step by Step

## Folder structure
### Code folder
        On this folder will resides all the scripting done related to migration and the output.csv file from redshift that contains the dll of the tables.
### output
        On this folder will resides all the table dlls from redshift divided into *.sqls files, one for each table. Also a schemas.sql that needs to be executed into snowflake before doing the migration, this file will not be copied into otput_snowflake.
### output_snowflake 

        In here will resides all the *.sqls of the tables migrated into snowflake sql compliance. A bash file used to call snowsql to execute each script into snowflake.

## Installing R into linux:

        Execute sudo apt-get -y update && sudo apt install -y r-base for installation.

        All the R based extra packages will be installed and applied if needed automatically as the code contains code for this purpose.

## Solution scripts used

### Under code folder resides:

* Assembly_exec_sqls.r
    * Used to create a execute_queries.bash that have the bash syntax to execute a script using snowsql for easy testing.

* COM-ES-Scripts-sql2sf.py
    * Python scripts that does the actual DDL migration, it migrates all the *.sqls located on a file into an output folder. It takes two parameters:
        * input_folder which consist the folder of all the *.sqls that needs to be migrated.
        * output_folder where all the *.sqls will be saved already migrated(snowflake compliance)
* execute_bash.bash
    * This script contains a set of bash commands for cleaning up the output and output_snowflake folder and to execute the scripts needed in order to test the result scripts into snowflake, just for easy testing purposes.
* extract_redshift_tables_from_CSV.r
    * This R script reads output.csv that contains all the DDL related to each table extracted from redshift and proccess it into each sql script file containing the DLL on individual files for later processing. Cleans up the data related to the conversion of adventureworks that does not apply.
* output.csv
    * This CSV consis of table_name,ddl line related |
    This output is obtained from querying redshift database and exporting the output as .CSV file.

```sql
select tablename,ddl from v_generate_tbl_ddl 
where schemaname like 'adventureworks2012%'
order by tablename,seq;
```
        Note: The script might change depending of the schemas migrated from the AWS converting tool.

## How Adventureworks was migrated into Redshift

### Configuring environments
1. Install and configure AWS schema convertion tool as per: https://docs.aws.amazon.com/SchemaConversionTool/latest/userguide/CHAP_Installing.html

2. Create an SQL Server user with privileges on AdventureWorks database.

3. Turn on authentication method using SQL Server auth on SQL Server.(reboot the server after this changes)

4. Copy the endpoint cluster without the database name and port:
examplecluster.ciemrrerwurt.us-east-2.redshift.amazonaws.com
5. Go to cluster dashboard:
    1. Select cluster.
    2. Go to properties.
    3. Network and Security Settings:
        1. Click on edit publicy accesible
        2. Check enable.
6. Install the jdcb drivers for SQL Server and redshift:
    1. https://docs.aws.amazon.com/redshift/latest/mgmt/jdbc20-download-driver.html
    2. https://docs.microsoft.com/en-us/sql/connect/jdbc/microsoft-jdbc-driver-for-sql-server?view=sql-server-ver15
    3. When requested on the tool make references of this files after extracting them.

### Migrating Adventureworks into Redshift.
7. Open AWS conversion schema tool
8. Click on File
9. Click on new project.
10. Log in to SQL Server under the AWS conversion tool.
11. Go to Settings > project settings
12. Uncheck Use AWS Glue.
13. Click on connect to Redshift target.
14. Specify the information required, use as the server name the link obtained on step 4.
15. Check the elements on SQL Server on the left that will be converted, on this lab only the tables for adventureworks schemas were checked.
16. Double click on adventureworks and select convert schemas.
17. On the right panel the conversion scripts will be deployed, right click on schemas on the right and select apply to database.


### Obtaining the output.csv file

18. Go to query editor on Redshift and query the view that contains all dll, and use above query to obtain the ddl of the migrated tables loaded into redshift:
```sql
select tablename,ddl from v_generate_tbl_ddl 
where schemaname like 'adventureworks2012%'
order by tablename,seq;
```
19. Click on export > As CSV.


## Generating the dll snowflake scripts.

1. Check that output.csv file is available on Code folder.
2. Check that all the folder structure is in place.
3. On code folder execute execute_bash.bash
4. Go to output_snowflake
5. execute

```
bash *.bash
```
        This will trigger snowsql and begin the execution of the migrated table scripts to load them into snowflake.

## Checking for issues on snowflake after loading the tables.

1. Go to snowflake worksheets
2. With the help of the below query identify if there were migration issues(scripts that failed its execution)

```sql
select query_text,error_message
from table(information_schema.query_history())
where execution_status = 'FAILED_WITH_ERROR'
ORDER BY end_time;
```
