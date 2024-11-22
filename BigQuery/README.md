# BigQuery DDL Export Scripts

This repository offers a collection of straightforward scripts designed to facilitate the export of your BigQuery code, making it easier to migrate to [Snowflake](https://www.snowflake.com/). These scripts are specifically crafted to simplify the process of extracting your BigQuery code artifacts, such as stored procedures, functions, and views, ensuring a smooth transition to [Snowflake](https://www.snowflake.com/) using [SnowConvert](https://docs.snowconvert.com/snowconvert/for-google-bigquery/introduction).

## Version

Release 2024-11-19

## Usage

The following are the steps to execute the DDL Code Generation. They can be executed in Linux/Unix.

Remove Windows. We might add a side note on how to execute them on Windows

## How does this work?

The script `create_ddls.sh` will connect to your database and create a collection of SQL files.

## Prerequisits

1. Cloud SDK needs to be installed. If you have not installed it, you can follow [these](https://cloud.google.com/sdk/docs/install#linux) instructions.
2. The user must have Admin or Owner privileges, otherwise no information will be retrieved.
3. The user must be granted with a role with the `bigquery.datasets.get` permission. If there is no roles with it, you could create a custom role just for this.


## Usage

The following are the steps to execute the DDL Code Generation. They can be executed in Linux/Unix environments.

1. Modify the `create_ddls.sh` that is located in the `bin` folder
    - The region setting will be at the top of this file.
    - You must log in by going to a link in your browser when you run `./google-cloud-sdk/bin/gcloud init`, and then select the cloud project to use.

2. Before executing the script ensure `create_ddls.sh` is at the same folder level with `./google-cloud-sdk/`
    - Finally, run `create_ddls.sh` to extract the DDLs from BigQuery
    - After a successful run, remove region information from the top line of `create_ddls.sh`.

### Arguments

```--version```

Check the current version of the extraction scripts.

```--help```

Display the help screen.

```-s "schema1, schema2 [, ...]```

The parameter to limit to an in-list of schemas using the following structure schema1 [, ...].


### DDL Files
These files will contain the definitions of the objects specified by the file name.

* `DDL_Schema.sql`
* `DDL_Tables.sql`
* `DDL_External_Tables.sql`
* `DDL_Views.sql`
* `DDL_Functions.sql`
* `DDL_Procedures.sql`
* `DDL_Reservations.sql`
* `DDL_Capacity_commitments.sql`
* `DDL_Assignments.sql`