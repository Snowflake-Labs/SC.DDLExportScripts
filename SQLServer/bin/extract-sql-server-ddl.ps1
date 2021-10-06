# extract-sql-server-ddl.ps1
#
# Revision history
# 2021-08-05 Derrick Cole
# - parameterized variables
# - added reset switch
# - reordered/cleaned up logic
# - more robust try/catch error handling
# - corrected databaseObjectType references
# - converted "where name" to Where-Object for compatability
# - added filter to exclude system schemae/objects and in-memory temp tables
#
# 2021-08-06 Derrick Cole
# - added database include and exclude capability
# - added database- and table-level info capture (in addition to the DDL)
#
# 2021-08-09 Derrick Cole
# - ran script through PSScriptAnalyzer and tweaked based on default ruleset (install; Invoke-ScriptAnalyzer -Path <file>)
# - added check for PS 4.0+
# - added external* database object types
# - added database and table summary info
#
# 2021-09-02 Derrick Cole
# - incorporated Azure support from separate script
# - cleaned up parameters and logic
#
# 2021-09-03 Derrick Cole
# - version 1.0
# - added SqlServer module presence/install block
# - corrected database inclusion/exclusion filtering
# - consolidated server connection into single block
# - added a server summary dump
# - added version and rundate info
# - minor cleanup
#
# 2021-09-07 Derrick Cole
# - version 1.1
# - adjusted database inclusion/exclusion filtering
# - added support for masked password prompting
# - added SQL Server authentication option (Windows authentication by default)
# - added support for Get-Help
# - more cleanup
#

<#
    .SYNOPSIS
    Extract database object definitions from a SQL Server instance

    .DESCRIPTION
    The extract-sql-server-ddl.ps1 script attempts to connect to an instance of SQL Server using either Windows or SQL authentication and, for each database that survives inclusion/exclusion filters, retrieves certain object definitions as individual DDL files to a local directory.

    .PARAMETER ServerName
    Specifies the SQL Server instance to use

    .PARAMETER Port
    Specifies the port to use (default is 1433)

    .PARAMETER SqlAuthentication
    Bypass "normal" Windows Authentication when attempting to connect (default is false)

    .PARAMETER UserId
    Specifies the user name to use when attempting to connect (used in conjunction with -SqlAuthentication)

    .PARAMETER Password
    Specifies the password associated with the UserId to use when attempting to connect (used in conjunction with -SqlAuthentication)

    .PARAMETER IncludeSystemObjects
    Specify whether to include databases, schemas, and tables tagged as SQL Server system objects (default is false)

    .PARAMETER IncludeDatabases
    Specifies databases that match the listed pattern(s) be included in the extraction (default is all)

    .PARAMETER ExcludeDatabases
    Specifies databases that match the listed pattern(s) be excluded from the extraction (default is none)

    .PARAMETER ScriptDirectory
    Specifies the root directory in which the extracted files are to be stored (default is C:\MyScriptsDirectory)

    .INPUTS
    None.  You cannot pipe objects to extract-sql-server-ddl.ps1.

    .OUTPUTS
    System.String.

    .EXAMPLE
    PS> .\extract-sql-server-ddl.ps1

    .EXAMPLE
    PS> .\extract-sql-server-ddl.ps1 -ServerName foo.mydomain.com -Port 1500

    .EXAMPLE
    PS> .\extract-sql-server-ddl.ps1 -SqlAuthentication -ServerName foo.database.windows.net
#>

[CmdletBinding(PositionalBinding=$false)]
param(
    [string]$ServerName,
    [string]$Port = '1433',
    [switch]$SqlAuthentication = $false,
    [string]$UserId = '',
    [string]$Password = '',
    [switch]$IncludeSystemObjects = $false,
    [string[]]$IncludeDatabases = '*',
    [string[]]$ExcludeDatabases = '',
    [string]$ScriptDirectory = 'C:\MyScriptsDirectory'
)

function Get-Directory {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$directoryName,
        [switch]$removeExisting = $false
    )

    if ((Test-Path -Path $directoryName) -and $removeExisting) {
        try { Remove-Item -Path $directoryName -Recurse }
        catch {
            Write-Warning "Error removing directory '$($directoryName)': $_"
            Exit 1
        }
        Write-Output "Removed directory '$($directoryName)..."
    }
    if (!(Test-Path -Path $directoryName)) {
        try { New-Item -ItemType Directory -Force -Path $directoryName | Out-Null }
        catch {
            Write-Warning "Error creating directory '$($directoryName)': $_"
            Exit 1
        }
        Write-Output "Created directory '$($directoryName)'..."
    }
}

function Get-Param {
    param(
        [string]$parameterName,
        [string]$parameterPrompt,
        [switch]$isPassword = $false
    )
    if ($parameterName.Length -eq 0) {
        switch($isPassword) {
            $false { $parameterName = Read-Host -Prompt $parameterPrompt }
            $true {
                $secureString = Read-Host -Prompt $parameterPrompt -AsSecureString
                $parameterName = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))
            }
        }
    }
    return $parameterName
}

function Get-ServerSummary($server) {
    return [PSCustomObject]@{
            'Script Version' = $version
            'Run Date' = $rundate
            'Server' = $ServerName
            'Version' = $server.Version
            'ProductLevel' = $server.ProductLevel
            'UpdateLevel' = $server.UpdateLevel
            'HostPlatform' = $server.HostPlatform
            'HostDistribution' = $server.HostDistribution
        }
}

function Get-DatabaseSummary($database) {
    return [PSCustomObject]@{
            'Script Version' = $version
            'Run Date' = $rundate
            'Server' = $ServerName
            'Database' = $database.Name
            'Size_MB' = $database.Size
            'DataSpaceUsage_KB' = $database.DataSpaceUsage
            'IndexSpaceUsage_KB' = $database.IndexSpaceUsage
            'SpaceAvailable_KB' = $database.SpaceAvailable
        }
}

function Get-TableSummary($table) {
    return [PSCustomObject]@{
            'Script Version' = $version
            'Run Date' = $rundate
            'Server' = $ServerName
            'Database' = $database.Name
            'Schema' = $table.Schema
            'Table' = $table.Name
            'DataSpaceUsed_KB' = $table.DataSpaceUsed
            'IndexSpaceUsed_KB' = $table.IndexSpaceUsed
            'RowCount' = $table.RowCount
        }
}

# initialize
set-psdebug -strict
$ErrorActionPreference = 'stop'
$version = 'v1.1'
$rundate = Get-Date -Format 'yyyymmdd'

# check powershell version
$minPSVersionMajor = 4
if ($PSVersionTable.PSVersion.Major -lt $minPSVersionMajor) {
    Write-Warning "PowerShell version $($minPSVersionMajor).0 or later required"
    Exit 1
}
Write-Output "Confirmed PowerShell version $($minPSVersionMajor).0 or later installed..."

# check module presence
$requiredModule = 'SqlServer'
if (!(Get-Module -ListAvailable -Name $requiredModule)) {
    $install = Read-Host -Prompt "$($requiredModule) module is required but not installed.  Would you like to install? (y/n)"
    if ($install.ToLower() -eq 'y') {
        try { Install-Module -Name $requiredModule -AllowClobber }
        catch {
            Write-Warning "Error installing $($requiredModule) module: $_"
            Exit 1
        }
        Write-Output "Installed $($requiredModule) module..."
    } else {
        Write-Warning "Cannot continue without $($requiredModule) module.  Aborting..."
        Exit 1
    }
} else { Write-Output "Confirmed $($requiredModule) module installed..." }

# import module
try { Import-Module $requiredModule }
catch {
    Write-Warning "Error importing $($requiredModule) module: $_"
    Exit 1
}
Write-Output "Imported $($requiredModule) module..."

# load SMO assemblies
if ($null -eq [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')) {
    Write-Warning 'Error loading SMO assemblies: LoadWithPartialName() returned null'
    Exit 1
}
Write-Output 'Loaded SMO assemblies...'
$databaseObjectTypes =
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::DatabaseRole -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::ExtendedStoredProcedure -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::ExternalDataSource -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::ExternalFileFormat -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::ExternalLibrary -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::Sequence -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::Synonym -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::Schema -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::StoredProcedure -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::Table -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::UserDefinedAggregate -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::UserDefinedDataType -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::UserDefinedFunction -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::UserDefinedTableTypes -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::UserDefinedType -bor
    [long][Microsoft.SqlServer.Management.Smo.DatabaseObjectTypes]::View

# get script directory
Get-Directory -directoryName $ScriptDirectory

# get connection string
$ServerName = Get-Param -parameterName $ServerName -parameterPrompt 'Please enter a server name'
$Port = Get-Param -parameterName $Port -parameterPrompt 'Please enter a port number'
$connectionString = @{
    'Server' = "tcp:$($ServerName),$($Port)"
    'Integrated Security' = 'True'
    'Persist Security Info' = 'False'
    'MultipleActiveResultSets' = 'False'
    'Encrypt' = 'False'
    'TrustServerCertificate' = 'False'
}
if ($SqlAuthentication) {
    $UserId = Get-Param -parameterName $UserId -parameterPrompt 'Please enter a user id'
    $Password = Get-Param -parameterName $Password -parameterPrompt 'Please enter a password' -isPassword
    $connectionString['Integrated Security'] = 'False'
    $connectionString['User ID'] = $UserId
    $connectionString['Password'] = $Password
}
$connectionString = ($connectionString.GetEnumerator() | Foreach-Object { "$($_.Key)=$($_.Value)" }) -join ';'

# get server
try {
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
    $serverConnection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection $sqlConnection
    $server = New-Object Microsoft.SqlServer.Management.Smo.Server $serverConnection
    if ($null -eq $server.Version) { throw 'Failed to connect to server' }
}
catch {
    Write-Warning "Error connecting to server '$($ServerName)' on port $($Port): $_"
    Exit 1
}
Write-Output "Connected to server '$($ServerName)' on port $($Port)..."

# get databases
$databases = New-Object System.Collections.ArrayList
if ($server.Databases.Count -gt 0) {
    foreach ($includeDatabase in $IncludeDatabases) {
        $includes = $server.Databases | Where-Object { (!$_.IsSystemObject -or $IncludeSystemObjects) -and ($_.Name -like $includeDatabase) }
        $includes | ForEach-Object {
            if (!($databases -contains $_.Name)) {
                $databases.Add($_) | Out-Null
                Write-Output "Added database '$($_.Name)' per include rule '$($includeDatabase)'..."
            }
        }
    }
}
if ($databases.Count -gt 0) {
    foreach ($excludeDatabase in $ExcludeDatabases) {
        $excludes = $databases | Where-Object { $_.Name -like $excludeDatabase }
        $excludes | ForEach-Object {
            $databases.Remove($_) | Out-Null
            Write-Output "Removed database '$($_.Name)' per exclude rule '$($excludeDatabase)'..."
        }
    }
}

# anything to do?
if ($databases.Count -eq 0) {
    Write-Output "No database(s) to process on server $($ServerName)..."
} else {
    Write-Output "Processing $($databases.Count) database(s) on server '$($ServerName)'..."

    # get server directory
    $ServerDirectory = "$($ScriptDirectory)\$($ServerName)"
    Get-Directory -directoryName $ServerDirectory -removeExisting

    # save server summary
    $ServerSummaryFile = "$($ServerDirectory)\server_summary.csv"
    Get-ServerSummary $server | Export-Csv -Path $ServerSummaryFile -NoTypeInformation
    Write-Output "Stored server summary information to '$($ServerSummaryFile)'..."

    # get scripter
    $scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter $serverConnection
    $scripter.Options.ToFileOnly = $true
    $scripter.Options.DRIAll = $true
    $scripter.Options.Indexes = $true
    $scripter.Options.Triggers = $true
    $scripter.Options.ScriptBatchTerminator = $true
    $scripter.Options.IncludeIfNotExists = $true

    $totalDatabaseTables = 0

    # process each database
    $databases | ForEach-Object {
        $database = $_

        # get the database directory
        $DatabaseDirectory = "$($ServerDirectory)\$($database.Name)";
        Get-Directory -directoryName $DatabaseDirectory -removeExisting

        # get the database objects
        $databaseObjects = New-Object System.Data.Datatable
        try {
            $databaseObjects = $database.EnumObjects($databaseObjectTypes) |
                Where-Object { !($_.DatabaseObjectTypes -eq 'Schema' -and ($_.Name -eq 'sys' -or $_.Name -eq 'INFORMATION_SCHEMA')) } |
                Where-Object { !($_.Schema -eq 'sys' -or $_.Schema -eq 'INFORMATION_SCHEMA') } |
                Where-Object { !($_.Name[0] -eq '#') }
        }
        catch {
            Write-Warning "Error retrieving objects for database '$($database.Name)': $_"
            return
        }

        if ($databaseObjects.Count -eq 0) {
            Write-Warning "No (matching) object(s) found for database '$($database.Name)'"
        } else {
            Write-Output "Retrieving objects from database '$($database.Name)'..."

            $databaseObjects | ForEach-Object {
                $databaseObject = $_

                # get the object directory
                $ObjectDirectory = "$($DatabaseDirectory)\$($databaseObject.DatabaseObjectTypes)"
                Get-Directory -directoryName $ObjectDirectory

                # collect the object DDL
                $scripter.Options.Filename = "$($ObjectDirectory)\$($databaseObject.Name -replace '[\\\/\:\.]','-').sql"
                $urnCollection = New-Object Microsoft.SqlServer.Management.Smo.UrnCollection
                $urnCollection.add($databaseObject.urn)
                $scripter.script($urnCollection)
            }

            Write-Output "Retrieved $($databaseObjects.Count) object(s) ($($database.Tables.Count) table(s)) from database '$($database.Name)'..."
            $totalDatabaseTables += $database.Tables.Count
        }
    }
    Write-Output "Processed $($databases.Count) database(s) ($($totalDatabaseTables) table(s)) on server '$($ServerName)'..."

    # save database summaries
    $DatabaseSummaryFile = "$($ServerDirectory)\database_summary.csv"
    $databases | ForEach-Object { Get-DatabaseSummary $_ } | Export-Csv -Path $DatabaseSummaryFile -NoTypeInformation
    Write-Output "Stored database summary information to '$($DatabaseSummaryFile)'..."

    # save table summaries
    if ($totalDatabaseTables -eq 0) {
        Write-Warning "No tables retrieved from $($ServerName).  Skipped table summary..."
    } else {
        $TableSummaryFile = "$($ServerDirectory)\table_summary.csv"
        $databases | ForEach-Object { $_.Tables | ForEach-Object { Get-TableSummary $_ } } | Export-Csv -Path $TableSummaryFile -NoTypeInformation
        Write-Output "Stored table summary information to '$($TableSummaryFile)'..."
    }
}

Write-Output 'Script Complete'

Exit 0
