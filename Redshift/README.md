# Redshift Export Scripts

This repository provides some simple scripts to help exporting your Redshift Code so it can be migrated to [Snowflake](https://www.snowflake.com/) using [SnowConvert](https://docs.snowconvert.com/sc).

## Version

Release 2024-02-28

### Prerequisites

To start, please download this folder or clone this repository into your computer.

This solution provides 3 alternatives to extract the data:

- Windows Script: A script written with PowerShell + AWS Cli
- Bash (Linux/macOS) Script: A script written with Bash + AWS Cli
- Manual: SQL Queries to execute on your preferred SQL Editor

Depending on the type of execution, the prerequisites are different, however these are shared across all types:

- Database user must have access to the following tables:
  - pg_namespace
  - pg_class
  - pg_attribute
  - pg_attrdef
  - pg_constraint
  - pg_class
  - pg_description
  - pg_proc
  - pg_proc_info
  - pg_language
  - information_schema.columns

## Running the Script (Powershell or Bash)

### Prerequisites

This script uses Powershell (Windows) or Bash (Linux/macOS), and AWS Cli (both platforms) to connect and communicate with AWS services. In order for this to work you first need to:

- Install AWS Cli. Instructions on how to install [can be found here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- In the AWS Portal, create a new IAM access with:

  - A new policy, with the following JSON values:
    ```
    "Action": [
      "redshift-data:ExecuteStatement",
      "redshift-data:GetStatementResult",
      "redshift-data:DescribeStatement",
      "redshift-data:BatchExecuteStatement",
      "secretsmanager:GetSecretValue"
    ],
    "Resource": [
      "arn:aws:redshift:{Region}:{Account}:dbname:{ClusterName}/{DatabaseName}",
    ]
    ```
  - A new User, make sure to save the ACCESS KEY and the SECRET ACCESS KEY. And enable the console login for it.
  - [Optional] Create a new user group and add the policy created to it as a new permission. Then add the user created to the user group.
    You can also add the permission directly to the user.
  - Create a Secret in the AWS Secrets Manager:

    _The keys must be named as mentioned._

    ```
    {
      username: <database-username>
      password: <database-username-password>
      engine: redshift
      host: <database-host>
      port: <database-port>
      dbClusterIdentifier: <redshift-cluster-identifier>
    }
    ```

- Configure your AWS credentials into your computer. There are several ways to do this, the default and most recommended is creating a credentials file as shown [here](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html).
- Or run `aws configure` to set up your credentials.

### Usage

To use the script, follow these steps:

- Navigate to the bin folder, and open the `create_ddls.ps1` or `create_ddls.sh`, depending on your environment, in a text editor.
- In here, modify these variables:

| Variable       | Description                                                                                                                                                                                                             | Must be modified |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| OUTPUT_PATH    | Output folder where the results will be saved to.                                                                                                                                                                       | Y                |
| RS_CLUSTER     | Your Redshift Cluster identifier.                                                                                                                                                                                       | Y                |
| RS_DATABASE    | The Redshift Database that you're interested in extracting.                                                                                                                                                             | Y                |
| RS_SECRET_ARN  | The Secret ARN with your credentials.                                                                                                                                                                                   | Y                |
| SCHEMA_FILTER  | SQL statement to filter the schemas you're interested in. By default the script ignores the `information_schema`, `pg_catalog` and `pg_internal` schemas.                                                               | N                |
| MAX_ITERATIONS | AWS handles requests asynchronously, therefore we need to perform constant checks on the query for completion. This value sets the max iterations allowed before finishing the script. Every iteration waits 5 seconds. | N                |

- After modifying these variables, execute the scripts and your DDL Code should be extracted into the path you specified.

- Run `create_ddls.sh --version` to check the current version of the extraction scripts.

## Execute the query (SQL Editor)

- Access to an SQL Editor with access to Redshift, such as SQL Workbench/J or the AWS Redshift Query Editor v1. v2 doesn't work properly since it only exports 100 rows at a time.

After completing these steps, you're now ready to execute the script.

### Usage

- Open the queries located in `Redshift/scripts` in your preferred SQL Editor and replace the `{schema_filter}` line with the desired filter for your needs. If you need all schemas to be pulled, you could either input `lower(schemaname) like '%'` or remove the entire `WHERE`.
- Execute the `.sql` queries. Make sure that there is no limit set on the amount of rows it can extract. After executing the queries, export each query result to either `.txt` or `.csv` and rename them to:

| Script            | Result Filename   |
| ----------------- | ----------------- |
| function_ddl.sql  | DDL_Function.sql  |
| procedure_ddl.sql | DDL_Procedure.sql |
| table_ddl.sql     | DDL_Table.sql     |
| view_ddl.sql      | DDL_View.sql      |

## Notes

- These queries to extract the code were based on the queries on [this repository](https://github.com/awslabs/amazon-redshift-utils/tree/master/src/AdminViews) and they were modified slightly or not at all.
- Extracting the information from Redshift is performed asynchronously. This means that when a statement is sent to the database, the code will continue executing. For this there is a Timeout of 5 minutes to wait for a query to finish executing and it will check every 5 seconds if it's finished by default, but it can be modified with the MAX_ITERATIONS variable.

## Reporting issues and feedback

If you encounter any bugs with the tool please file an issue in the
[Issues](https://github.com/Snowflake-Labs/SC.DDLExportScripts/issues) section of our GitHub repo.

## Known issues

This code extracts code by executing queries to the database meaning that there is a maximum of ~64.000 characters in a column. The SQL has been tweaked to split the Procedure code into several sections allowing a maximum of 500.000 characters. In case your procedures are longer, the code will be truncated. To solve this issue, you can modify the query to allow for more characters. To do so, follow these steps:

1. Open `Redshift/bin/scripts/DDL_Procedure.sql`.
2. Look for `-- Extend 1` and add the following line: `, substr(prosrc,500001,20000) as s_26`. For extra lines, add `20000` to the first parameter and add 1 to the column identifier, like this: `, substr(prosrc,520001,20000) as s_27`
3. Look for `-- Extend 2` and add the following line: `, reverse(s_26) as r_26`. For extra lines, add 1 to both the column in the `reverse` function, as well as the identifier, like this: `, reverse(s_27) as r_27`.
4. Look for `-- Extend 3` and add the following line: `, len(s_26) as l_26`. For extra lines, add 1 to both the column in the `len` function, as well as the identifier, like this: `, reverse(l_27) as l_27`.
5. Look for `-- Extend 4` and add the following line:

```sql
UNION ALL
select
  schemaname, proc_name, proc_oid, 4026 /* 1 */ as seq
  , position(' ' in r_26 /* 2 */) as last_space
  , position(' ' in r_25 /* 3 */) as prior_last_space
  , substr(s_25 /* 4 */,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
  , prior_end_str || substr(s_26 /* 5 */,1,20001 - last_space)::varchar(64000) as ddl
from body_source2 where l_26 /* 6 */ > 0
```

For extra lines, you will need to modify the sections (`/* n */`) from the previous query in the above code and add after the previous query. The value to change are as follows:

- `/* 1 */`: new sequence number for query. Add one to the seq from previous query.
- `/* 2 */`: new r_column (from `Step 3`).
- `/* 3 */`: previous r_column.
- `/* 4 */`: previous s_column.
- `/* 5 */`: new s_column (from `Step 2`).
- `/* 6 */`: new l_column (from `Step 4`).

## License

These export scripts are licensed under the [MIT license](https://github.com/Snowflake-Labs/SC.DDLExportScripts/blob/main/Redshift/License.txt).
