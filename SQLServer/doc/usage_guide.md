# Usage Guide
Contents:

[Options](#options)

[Examples](#examples)


## Description
sc-sqlexport-export is a simple tool to help you to export SQLServer code so it can be upgraded to SnowFlake using the SnowConvert Tool.

The sc-sqlexport-export can be used to generate extraction scripts that can be run to generate data definition language (DDL) for database objects in SQLServer.

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
pip install snowconvert-sqlserver-export
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



5. When the extraction process is finished. Compress the results and send them over:

On Mac or linux con run:
```
zip -r output.zip ./output
```

On windows you can use the Windows File Explorer or from the command line run:

```
compact /c /s "output" /I /Q
```