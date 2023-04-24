# BigQuery DDL Export Scripts

This repository provides some simple scripts to help exporting your BigQuery code so it can be migrated to Snowflake using SnowConvert.

## Version

Version 1.0 Release 2021-12-02

## Usage

The following are the steps to execute the DDL Code Generation. They can be executed in Linux/Unix.

Remove Windows. We might add a side note on how to execute them on Windows

## How does this work?

The script `create_ddls.sh` will connect to your database and create a collection of SQL files.

## Prerequisits

1. Cloud SDK needs to be installed. If you have not installed it, you can follow [these](https://cloud.google.com/sdk/docs/install#linux) instructions.
2. The user must have Admin or Owner priviledges.
3. The user must be granted with a role with the `bigquery.datasets.get` permission. If there is no roles with it, you could create a custom role just for this.


## Usage

The following are the steps to execute the DDL Code Generation. They can be executed in Linux/Unix environments.

1. Modify the `create_ddls.sh` that is located in the `bin` folder

1.1 The region setting will be at the top of this file.

1.2 You must log in going to a link in your browser when you run `./google-cloud-sdk/bin/gcloud init`, and then select the cloud project to use.

2. Finally, run `create_ddls.sh` to extract the DDLs from BigQuery

After a successful run, remove region information from the top line of `create_ddls.sh`.

Compress the entire `Output` folder.
