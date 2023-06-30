# SQL Server Export Scripts

This repository provides some simple scripts to help exporting your SQLServer code so it can be migrated to [Snowflake](https://www.snowflake.com/) using [SnowConvert](https://docs.snowconvert.com/snowconvert/for-transactsql/introduction).

## Version

Version 2.8
Release 2022-09-01

## Usage

The `extract-sql-server-ddl.ps1` script attempts to connect to an instance of SQL Server using either Windows or SQL authentication and, for each database that survives inclusion/exclusion filters, retrieves certain object definitions as individual DDL files to a local directory. 

**SQL Server tested versions**: `SQL Server 2019`, `Azure SQLDatabase`

The script uses the following parameters.  The script will prompt the user for any parameter not specified on the command line.

* **ServerName**: Specifies the SQL Server database server to use
* **InstanceName**: Specifies the SQL Server database instance to use (default is the default instance)
* **PortNumber**: Specifies the port to use (default is 1433)
* **UserName**: Specifies the user name to use with SQL Authentication (default is the logged-in user)
* **Password**: Specifies the password to use for **UserName** (if SQL authentication preferred)
* **ScriptDirectory**: Specifies the root directory in which the extracted files are to be stored (default is .\MyScriptsDirectory)
* **IncludeDatabases**: Specifies databases that match the listed pattern(s) be included in the extraction (default is all)
* **ExcludeDatabases**: Specifies databases that match the listed pattern(s) be excluded from the extraction (default is none)
* **IncludeSchemas**: Specifies schemas (in any database) that match the listed pattern(s) be included in the extraction (default is all)
* **ExcludeSchemas**: Specifies schemas (in any database) that match the listed pattern(s) be excluded from the extraction (default is none)
* **IncludeSystemDatabases**: Specifies whether to include databases, schemas, and tables tagged as SQL Server system objects (default is false)
* **ExistingDirectoryAction**: Specifies whether to delete or keep the existing **ScriptDirectory** (default is to prompt interactively)
* **NoSysAdminAction**: Specifies whether to stop or continue should the authenticated **UserName** not have the sysadmin role on **ServerName**\\**InstanceName** (default is to prompt interactively)

## Troubleshooting

### What to if I need to run the scripts on a machine with no Internet Access ?

The extraction scripts will try to install a PowerShell module for SQLServer. If the machine does not have access to internet this operation might fail.

One option can be to download this module and install it manually.

You can follow these steps:

1. Run powershell
2. Create a folder for example c:\temp
3. Run `Invoke-WebRequest -Uri powershellgallery.com/api/v2/package/sqlserver -Out D:\temp\sqlserver.zip`
4. Now we need to extract the module into a path that Powershell can use to load the modules. For that purpose we can run 
```
PS C:\> echo $env:PSModulePath.Split(";")
C:\Users\username\Documents\WindowsPowerShell\Modules
C:\Program Files (x86)\WindowsPowerShell\Modules
C:\Program Files\WindowsPowerShell\Modules
```
As you can see the output will print a list of folder where powershell lists the modules. 
You can select one of the folder like this:
```
PS C:\> echo $env:PSModulePath.Split(";")[0]
C:\Users\username\Documents\WindowsPowerShell\Modules
```
Create a target folder:
```
PS C:\> mkdir ($env:PSModulePath.Split(";")[0] + "\SqlServer")
```

And extract the module like:
```
PS C:\> Expand-Archive -Path C:\temp\sqlserver.zip -DestinationPath ($env:PSModulePath.Split(";")[0] + "\SqlServer")
```

5. Install it like:
```
PS C:\> Install-Module -Name SqlServer -Scope CurrentUser

Untrusted repository
You are installing the modules from an untrusted repository. If you trust this repository, change its
InstallationPolicy value by running the Set-PSRepository cmdlet. Are you sure you want to install the modules from
'PSGallery'?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "N"): A
```

## Additional Help

For more information on using the script, execute the following:
```ps
PS> Get-Help -full .\extract-sql-server-ddl.ps1
```

## Reporting issues and feedback

If you encounter any bugs with the tool please file an issue in the
[Issues](https://github.com/Snowflake-Labs/SC.DDLExportScripts/issues) section of our GitHub repo.

## License

These scripts are licensed under the [MIT license](https://github.com/Snowflake-Labs/SC.DDLExportScripts/blob/main/SQLServer/License.txt).
