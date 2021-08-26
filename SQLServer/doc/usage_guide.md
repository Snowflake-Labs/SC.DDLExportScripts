# Usage Guide
Contents:

[Options](#options)

[Examples](#examples)


## Description

`sc-sqlserver-export` is a simple tool to help you to export SQLServer code so it can be upgraded to SnowFlake using the SnowConvert Tool.

The `sc-sqlserver-export` can be used to generate extraction scripts that can be run to generate data definition language (DDL) for database objects in SQLServer.

Those output scripts can then be used as an input for the [SnowConvert Tool](https://www.mobilize.net/products/database-migrations/snowconvert)


## Options
For option parameters, pass in '-h': 

    usage: sc-sqlserver-export [-h] -S  -U  -P

    Mobilize.NET SQLServer Code Export ToolsVersion X.X.X

    optional arguments:
    -h, --help        show this help message and exit
    -C , --connectionstring
                      Connection string for the server
    -S , --server     Server address. For example: 127.0.0.1 or my-db-server01
    -U , --user       User
    -P , --password   The password for the given user

## Examples    

You just need a machine with access to the SQLServer and a user and password with right to access that database.

Then you will follow these steps from the command line:


1. First install the tool:

```bash
pip3 install snowconvert-export-sqlserver --upgrade
```

2. Second create a folder for your extraction

```bash
mkdir SQLServerExport
cd SQLServerExport
```

3. Run the tool
```bash
sc-sqlserver-export -S mydbserver -U sa -P sapassword -D database
```
The script will create an output folder. A log will be created with the tool progress.

NOTE: if run on linux and if your password has a `!` you can get an error like `event not found`. 
The exclamation mark is part of history expansion in bash. In order to avoid that just pass your password with single quotes like: `'Password!'`

4. When the extraction process is finished. Compress the results and send them over:

On Mac or linux con run:
```
zip -r output.zip ./output
```

On windows you can use the Windows File Explorer or from the command line run:

```
compact /c /s "output" /I /Q
```

## Arrangement Tool

The SQLServer has many versions and each version of the database has different versions of the  SQL Server Management Studio (SSMS). 

We have notice that the export for each version may vary significantly. Also a lot of artifacts are added to the scripts, like checks to validate if the database or table is created prior to migration. Those pieces of code are not really neded for migration.

In order to *clean up* the code we provide a tool called `sc-sqlserver-arrange`. This tool is installed a part of the SQL Server Export tools. 

When you run the tool, it will try to parse the statements per file. It will extract creation statement, event some executed with dynamic exec. The result will create a folder per schema and per object type. For example a folder for `dbo` schema with a subfolder `funtion` for the functions in that schema, and a file with the function name for each function within that schema.

Run `sc-sqlserver-arrange -h` to display its usage information:

```
Version 1.0.2

Usage: SQLServer DDLS CleanUp Tool [options]

Options:
  -?|-h|--help   Show help information
  -v|--version   Show version information
  -i|--inputDir  Input Directory
  -o|--outDir    Output Directory
  --pretty       Apply pretty printing
  --multiple     If you have a folder that has several database, you can pass --multiple true. It will assume that under the input folder there is a folder for each database
```

In general after getting a SQL Export, just run the tool like:

```
sc-sqlserver-arrange -i folderwithextracts -o folderwitharrangedcode
```

Sometimes you might have a folder with an structure like this:
```
+ folder
    - exportDb1
    - exportDb2
    - exportDb3
```

In those cases it is recommended to run the tool with the `--multiple` flag, that will perform and arrangement per folder e.g. first `exportDb1`, then `exportDb2` and so on.

