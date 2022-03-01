#

# version 2.1 Derrick Cole, Snowflake Computing

#
# see co-located Revision-History.txt for additional information
#

<#
    .SYNOPSIS
    Extracts object DDL from a SQL Server instance.

    .DESCRIPTION
    Connects to an instance of SQL Server and, for each database/schema that survives inclusion/exclusion filters, retrieves object Data Definition Language (DDL) to files in a specified directory.

    .PARAMETER ServerName
    The server to connect to.  Default is to connect to the server executing the script (i.e., localhost).
    
    .PARAMETER InstanceName
    The named instance to use on **ServerName**.  Default is to use the default instance on **ServerName** (i.e., MSSQLSERVER).

    .PARAMETER PortNumber
    The port number to use on **ServerName**.  Overrides **InstanceName** if **InstanceName** is also specified.  Default is to not use a port number.

    .PARAMETER UserName
    The user name to use with SQL Authentication.  Default is to use the currently-logged-in user with Windows Authentication.

    .PARAMETER Password
    The password associated with **UserName** to use with SQL Authentication.  Default is to use the currently-logged-in user with Windows Authentication.

    .PARAMETER ScriptDirectory
    The top-level directory under which server-, instance-, database-, and object-related files are stored.  Default is '.\ScriptDirectory'.

    .PARAMETER IncludeDatabases
    Which database(s) to include via a comma-delimited list of patterns (using PowerShell -match syntax).  Default is to include all (other than SQL Server system databases; see **IncludeSystemDatabases**).

    .PARAMETER ExcludeDatabases
    Which database(s) to exclude via a comma-delimited list of patterns (using PowerShell -match syntax).  Default is to exclude none.

    .PARAMETER IncludeSchemas
    Which schema(s) to include via a comma-delimited list of patterns (using PowerShell -match syntax).  Default is to include all.

    .PARAMETER ExcludeSchemas
    Which schema(s) to exclude via a comma-delimited list of patterns (using PowerShell -match syntax).  Default is to exclude none.

    .PARAMETER IncludeSystemDatabases
    Specify whether to include SQL Server system databases when applying **IncludeDatabases** and **ExcludeDatabases** filters.  Default is to exclude SQL Server system databases.

    .PARAMETER ExistingDirectoryAction
    Specify whether to automatically 'delete' or 'keep' existing directories in **ScriptDirectory**.  Default is to interactively prompt whether to 'delete' or 'keep' each existing directory encountered.

    .PARAMETER NoSysAdminAction
    Specify whether to automatically 'stop' or 'continue' execution should the authenticated user not be a member of the 'sysadmin' group on **InstanceName** or if role membership cannot be determined.  Default is to interactively prompt whether to 'stop' or 'continue' execution.

    .INPUTS
    None.  You cannot pipe objects to this script.

    .OUTPUTS
    System.String.

    .NOTES
    It is HIGHLY RECOMMENDED that the user connecting to the instance have the sysadmin server role.  The script checks for this and warns if not the case, as errors or an incomplete extract may result.
    The database object types retrieved by this script are relative to SQL Server 2019.  Prior versions of SQL Server may produce a benign "can not find an overload for EnumObjects" error during extraction.  This can be ignored.
    The current version of this script does not support named pipe connections.

    .LINK
    For more information on the Microsoft SqlServer SMO assemblies used by this script, please visit: https://docs.microsoft.com/en-us/sql/relational-databases/server-management-objects-smo/installing-smo

    .LINK
    For more information on PowerShell match syntax, please visit: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_regular_expressions



[CmdletBinding(PositionalBinding=$false)]
param(

    [string]$ServerName,
    [string]$InstanceName,
    [string]$PortNumber,
    [string]$UserName,
    [string]$Password,
    [string]$ScriptDirectory,
    [string[]]$IncludeDatabases,
    [string[]]$ExcludeDatabases,
    [string[]]$IncludeSchemas,
    [string[]]$ExcludeSchemas,
    [switch]$IncludeSystemDatabases,

    [ValidateSet('delete', 'keep')][string]$ExistingDirectoryAction,
    [ValidateSet('continue', 'stop')][string]$NoSysAdminAction
)

# initialize
set-psdebug -strict
$ErrorActionPreference = 'stop'
$version = 'v2.0'

$hostName = $env:COMPUTERNAME
$startTime = Get-Date
Write-Host "[ $($MyInvocation.MyCommand.Name) version $($version) on $($hostName), start time $($startTime) ]"


function Get-Response {
    param(
        [string]$prompt,
        [string]$defaultDisplayed,
        [string]$defaultActual
    )
    $value = Read-Host -Prompt "$($prompt) [$($defaultDisplayed)]"
    if ($value.Trim().Length -gt 0) { $value } else { $defaultActual }
}

function Get-Choice {
    param(
        [string]$prompt,
        [string]$firstChoice,
        [string]$secondChoice,
        [string]$defaultChoice
    )
    do {
        $value = Get-Response -prompt $prompt -defaultDisplayed $defaultChoice -defaultActual $defaultChoice
    } while (!($value.Trim().ToUpper() -eq $firstChoice.Trim().ToUpper() -or $value.Trim().ToUpper() -eq $secondChoice.Trim().ToUpper()))
    return $value.Trim().ToUpper()
}

function Get-Value {
    param(
        [string]$prompt
    )
    do {
        $value = Read-Host -Prompt $prompt
    } while ($value.Trim().Length -eq 0)
    return $value
}

function Get-Password {
    param(
        [string]$prompt
    )
    $secureString = Read-Host -Prompt $prompt -AsSecureString
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString))
}

function Confirm-NoSysAdminAction {
    param(
        [string]$warning
    )
    Write-Warning $warning
    if ('' -eq $NoSysAdminAction) {
        if ('S' -eq (Get-Choice -prompt "[C]ontinue with extraction or [S]top?" -firstChoice 'C' -secondChoice 'S' -defaultChoice 'S')) { Exit 1 }
    } else {
        Write-Host "[C]ontinue with extraction or [S]top? $($NoSysAdminAction)"
        if ('STOP' -eq $NoSysAdminAction.ToUpper()) { Exit 1 }
    }
}

function Confirm-ExistingDirectoryAction {
    param(
        [string]$directory
    )
    Write-Warning "Directory $($directory) exists."
    if ('' -eq $ExistingDirectoryAction) {
        if ('K' -eq (Get-Choice -prompt "[K]eep existing directory or [D]elete?" -firstChoice 'K' -secondChoice 'D' -defaultChoice 'D')) {
            return 'KEEP'
        } else {
            return 'DELETE'
        }
    } else {
        Write-Host "[K]eep existing directory or [D]elete? $($ExistingDirectoryAction)"
        return $ExistingDirectoryAction.ToUpper()
    }
}

function Confirm-DirectoryExists {
    param(
        [string]$directory
    )
    if (Test-Path -Path $directory -PathType Container) {
        if ('DELETE' -eq (Confirm-ExistingDirectoryAction -directory $directory)) {
            try {
                Remove-Item -Path $directory -Recurse
                Write-Host "Deleted directory '$($directory)'"
            }
            catch {
                Write-Warning "Error deleting directory '$($directory)': $_"

                Exit 1
            }
        }
    }

    if (!(Test-Path -Path $directory -PathType Container)) {
        try {
            $null = New-Item -Path $directory -ItemType Directory -Force
            Write-Host "Created directory '$($directory)'"
        }
        catch {
            Write-Warning "Error creating directory '$($directory)': $_"

            Exit 1
        }
    }
}


# check powershell version
$minimumPowerShellVersionNumber = 5
switch($PSVersionTable.PSVersion.Major -ge $minimumPowerShellVersionNumber) {
    $true { Write-Host "PowerShell $($PSVersionTable.PSVersion) installed." }
    $false {
        Write-Warning "PowerShell $($minimumPowerShellVersionNumber).0 or later required."
        Exit 1
    }
}

# load required assemblies
$requiredModule = "SqlServer"
$requiredAssemblies = @(
    "Smo",
    "ConnectionInfo",
    "SqlClrProvider",
    "Management.Sdk.Sfc",
    "SqlEnum",
    "Dmf.Common"
)
try {
    foreach ($requiredAssembly in $requiredAssemblies) {
        if ($null -eq [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.$($requiredModule).$($requiredAssembly)")) { throw }
    }
    Write-Host "Required assemblies loaded."
}
catch {
    Write-Warning "Required assemblies not loaded."
    Write-Host @"
As PowerShell Administrator, please execute the following on $($hostname):

"@
    if ($null -eq (Get-Module -ListAvailable -Name $requiredModule)) {
        Write-Host @"
    # answer 'Y' in response to any prompts received
    Install-Module -Name $($requiredModule) -AllowClobber

"@
    }
    Write-Host @"
    # ensure the required $($requiredModule) assemblies are published to the Global Assembly Cache
    `$requiredAssemblies = @("$($requiredAssemblies -Join '", "')")
    `$modulePath = [System.IO.Path]::GetDirectoryName((Get-Module -ListAvailable -Name $($requiredModule)).Path)
    [System.Reflection.Assembly]::LoadWithPartialName("System.EnterpriseServices") | Out-Null
    `$publish = New-Object System.EnterpriseServices.Internal.Publish
    Foreach (`$requiredAssembly in `$requiredAssemblies) { `$publish.GacInstall("`$(`$modulePath)\Microsoft.$($requiredModule).`$(`$requiredAssembly).dll") }

Once the above action(s) are executed successfully on $($hostname) as PowerShell Administrator, please open a new PowerShell session on $($hostname) and re-execute the extraction script.
"@
    Write-Warning "If circumstances prevent taking any of the above action(s) on devices like $($hostname), the extraction script must be executed on a device running SQL Server."
    Exit 1
}

# confirm parameter values if overrides not specified on the command line
if (!($PSBoundParameters.ContainsKey('ServerName'))) {
    $ServerName = Get-Response -prompt 'Enter the server name to connect to' -defaultDisplayed $hostname -defaultActual $hostname
}
if (!($PSBoundParameters.ContainsKey('InstanceName') -and $PSBoundParameters.ContainsKey('PortNumber'))) {
    $choice = Get-Choice -prompt "Use [N]ame or [P]ort number to specify instance on $($ServerName)?" -firstChoice 'N' -secondChoice 'P' -defaultChoice 'N'
    if ($choice -eq 'P') {
        $PortNumber = Get-Value -prompt 'Enter the instance port number'
        $InstanceName = ''
    } else {
        $InstanceName = Get-Response -prompt 'Enter the instance name' -defaultDisplayed 'default instance' -defaultActual ''
    }
} elseif ($PSBoundParameters.ContainsKey('PortNumber')) {
    $InstanceName = ''
}
if (!($PSBoundParameters.ContainsKey('UserName') -and $PSBoundParameters.ContainsKey('Password'))) {
    $choice = Get-Choice -prompt "Use [W]indows or [S]QL Server authentication to connect to $($ServerName)?" -firstChoice 'W' -secondChoice 'S' -defaultChoice 'W'
    if ($choice -eq 'S') {
        $UserName = Get-Value -prompt "Enter the user name to connect to $($ServerName)"
        $Password = Get-Password -prompt "Enter the password for $($UserName)"
    }
} elseif ($PSBoundParameters.ContainsKey('UserName') -and !($PSBoundParameters.ContainsKey('Password'))) {
    $Password = Get-Password -prompt "Enter the password for $($UserName)"
} elseif ($PSBoundParameters.ContainsKey('Password') -and !($PSBoundParameters.ContainsKey('UserName'))) {
    $UserName = Get-Value -prompt "Enter the user name to connect to $($ServerName)"
}
if (!($PSBoundParameters.ContainsKey('ScriptDirectory'))) {
    $ScriptDirectory = "$($pwd)\ScriptDirectory"
    $ScriptDirectory = Get-Response -prompt 'Enter the script output directory' -defaultDisplayed $ScriptDirectory -defaultActual $ScriptDirectory
}
if (!($PSBoundParameters.ContainsKey('IncludeDatabases'))) {
    $IncludeDatabases = Get-Response -prompt "Enter comma-delimited set of databases to include" -defaultDisplayed 'All' -defaultActual '.*'
}
if (!($PSBoundParameters.ContainsKey('ExcludeDatabases'))) {
    $ExcludeDatabases = Get-Response -prompt "Enter comma-delimited set of databases to exclude" -defaultDisplayed 'None' -defaultActual ' '
}
if (!($PSBoundParameters.ContainsKey('IncludeSchemas'))) {
    $IncludeSchemas = Get-Response -prompt "Enter comma-delimited set of schemas to include" -defaultDisplayed 'All' -defaultActual '.*'
}
if (!($PSBoundParameters.ContainsKey('ExcludeSchemas'))) {
    $ExcludeSchemas = Get-Response -prompt "Enter comma-delimited set of schemas to exclude" -defaultDisplayed 'None' -defaultActual ' '
}
if (!($PSBoundParameters.ContainsKey('IncludeSystemDatabases'))) {
    $choice = Get-Choice -prompt "Include SQL Server system databases? [Y]es/[N]o" -firstChoice 'Y' -secondChoice 'N' -defaultChoice 'N'
    $IncludeSystemDatabases = switch($choice) {
        'Y' { $true }
        default { $false }
    }
}

# initiate a (TCP) connection to (specified/unspecified) port else to (default/named) instance on (local/remote) server using (Windows/SQL) authentication
try {
    $connectionString = @{
        "Data Source" = "$(if ('' -ne $PortNumber) { 'tcp:' } else { '' })$(if ($ServerName -eq $hostname) { '(local)' } else { $ServerName })$(if ('' -ne $PortNumber) { ",$($PortNumber)" } elseif ($InstanceName.length -gt 0) { "\$($InstanceName)" } else { '' })"
        "Integrated Security" = "True"
        "Persist Security Info" = "False"
        "MultipleActiveResultSets" = "False"
        "Encrypt" = "False"
        "TrustServerCertificate" = "False"
        "Connection Timeout" = "30"
    }
    if ($UserName) {
        $connectionString["Integrated Security"] = "False"
        $connectionString["User ID"] = $UserName
        $connectionString["Password"] = $Password
    }
    $connectionString = ($connectionString.GetEnumerator() | Foreach-Object { "$($_.Key)=$($_.Value)" }) -Join ";"


    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
    $serverConnection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection $sqlConnection
    $server = New-Object Microsoft.SqlServer.Management.Smo.Server $serverConnection
    switch($null -ne $server.Version) {

        $true {
            try {
                $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
                $sqlCommand.Connection = $sqlConnection
                $sqlCommand.CommandTimeout = 0

                # get actual server name and instance name
                try {
                    $sqlCommand.CommandText = @'
declare
	@e varchar(128) = cast(serverproperty('edition') as varchar(128));
begin
	select
		case when lower(@e) like '%azure%' then serverproperty('servername') else serverproperty('machinename') end servername,
		case when lower(@e) like '%azure%' then replace(@e, ' ', '_') else isnull(serverproperty('instancename'), 'MSSQLSERVER') end instancename;
end
'@
                    $result = $sqlCommand.ExecuteReader()
                    if ($result.Read()) {
                        $ServerName = $result.GetValue(0)
                        $InstanceName = $result.GetValue(1)
                    } else {
                        throw "'$($sqlCommand.CommandText)' returned no data, retaining supplied server/instance names."
                    }
                }
                catch {
                    Write-Warning $_
                }
                finally {
                    $result.Close()
                }
                $ServerInstance = "$($ServerName)\$($InstanceName)"
                Write-Host "Connected to instance '$($ServerInstance)' (SQL Server version $($server.Version))."

                # check connected user for sysadmin role
                $sysadmin = 'sysadmin'
                try {
                    $sqlCommand.CommandText = "select SUSER_NAME(), IS_SRVROLEMEMBER('$($sysadmin)')"
                    $result = $sqlCommand.ExecuteReader()
                    if ($result.Read()) {
                        $suser_name = if ('' -ne $result.GetValue(0)) { " '$($result.GetValue(0))'" } else { '' }
                        switch(1 -eq $result.GetValue(1)) {
                            $true { Write-Host "User$($suser_name) has '$($sysadmin)' role on instance '$($ServerInstance)'." }
                            $false { Confirm-NoSysAdminAction -warning "User$($suser_name) does not have '$($sysadmin)' role on instance '$($ServerInstance)'.  Extraction may be incomplete and/or errors may occur." }
                        }
                    } else {
                        throw
                    }
                }
                catch {
                    Confirm-NoSysAdminAction -warning "Unable to obtain role memberships for user from instance '$($ServerInstance)'.  Extraction may be incomplete and/or errors may occur."
                }
                finally {
                    $result.Close()
                }
            }
            catch {
                throw $_
            }
            finally {
                $sqlCommand.Connection.Close()
            }
        }
        $false { throw "Not connected to '$($ServerName)'" }

    }
}
catch {
    Write-Warning $_
    Exit 1
}


# initialize scripter
try {
    $scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter $serverConnection
    $scripter.Options.ToFileOnly = $true
    $scripter.Options.AppendToFile = $true
    $scripter.Options.DRIAll = $true
    $scripter.Options.Indexes = $true
    $scripter.Options.Triggers = $true
    $scripter.Options.ScriptBatchTerminator = $true
    $scripter.Options.ExtendedProperties = $true
    Write-Host "Scripter object initialized."
}
catch {
    Write-Warning "Error initializing scripter object: $_"
    Exit 1
}

# set up initial directories

Confirm-DirectoryExists -directory $ScriptDirectory
Confirm-DirectoryExists -directory ($instanceDirectory = "$($ScriptDirectory)\$($ServerInstance)")


# save server summary
[PSCustomObject]@{
    "Script Version" = $version
    "Run Date" = $startTime
    "Server" = $serverName
    "Instance" = $instanceName
    "Version" = $server.Version
    "Product Level" = $server.ProductLevel
    "Update Level" = $server.UpdateLevel
    "Host Platform" = $server.HostPlatform
    "Host Distribution" = $server.HostDistribution
} | Export-Csv -Path "$($ScriptDirectory)\server_summary.csv" -NoTypeInformation -Append

# get databases
if ($server.Databases.Count -gt 0) {
    $databases = $server.Databases | Where-Object { ($_.Name -match ($IncludeDatabases -Join "|")) -and (!$_.IsSystemObject -or $IncludeSystemDatabases) -and ($_.Name -notmatch ($ExcludeDatabases -Join "|")) }
    if ($databases.Count -eq 0) {
        Write-Warning "Existing databases on '$($ServerInstance)' did not survive specified inclusion/exclusion criteria."
        Exit 1
    }
} else {
    Write-Warning "No databases found on '$($ServerInstance)'."
    Exit 1
}


function Get-ServerObjectDdl {
    param(
        [object[]]$objects,
        [string]$type
    )

    try {
        if ($objects.Count -eq 0) { throw "No objects of type '$($type)' found in instance '$($ServerInstance)'" }

        # start with fresh extraction of this database object type
        $urnCollection = New-Object Microsoft.SqlServer.Management.Smo.UrnCollection
        $scripterFile = "$($instanceDirectory)\DDL_$($type).sql"
        Remove-Item -Path $scripterFile -ErrorAction Ignore
        $scripter.Options.Filename = $scripterFile

        $objectsProcessed = 0
        $objectsErrored = 0
        foreach ($object in $objects) {
            try {
                # save object summary
                [PSCustomObject]@{
                    "Script Version" = $version
                    "Run Date" = $startTime
                    "Server" = $serverName
                    "Instance" = $instanceName
                    "Database" = $null
                    "Schema" = $null
                    "Name" = $object.Name
                    "Type" = $type
                    "Encrypted" = $false
                    "DDL File" = $scripterFile
                } | Export-Csv -Path "$($ScriptDirectory)\object_inventory.csv" -NoTypeInformation -Append

                $urnCollection.add($object.urn)
                $objectsProcessed += 1
            }
            catch {
                $objectsErrored += 1
                Write-Warning $_
            }
        }
        if ($objectsProcessed -gt 0) {
            $scripter.script($urnCollection)
        }
        Write-Host "Retrieved $($objectsProcessed) of $($objects.Count) object(s) of type '$($type)' ($($objectsErrored) errors) from instance '$($ServerInstance)'"
        $global:totalObjectsProcessed += $objectsProcessed
        $global:totalObjectsErrored += $objectsErrored
        $global:totalObjectsToProcess += $objects.Count
    }
    catch {
        Write-Warning $_
    }
}


function Get-DatabaseObjectDdl {
    param(
        [object[]]$objects,
        [string]$type,
        [switch]$isTableType = $false
    )

    try {
        $objectsToProcess = $objects |
            Where-Object { !($_.Name[0] -eq "#") } |
            Where-Object { !($_.DatabaseObjectTypes -eq "Schema" -and ($_.Name -eq "sys" -or $_.Name -eq "INFORMATION_SCHEMA")) } |
            Where-Object { !($_.Schema -eq "sys" -or $_.Schema -eq "INFORMATION_SCHEMA") } |
            Where-Object { $_.Schema -match ($IncludeSchemas -Join "|") -and $_.Schema -notmatch ($ExcludeSchemas -Join "|") }
        if ($objectsToProcess.Count -eq 0) { throw "No objects of type '$($type)' found in database '$($database.Name)'" }

        # start with fresh extraction of this database object type
        $urnCollection = New-Object Microsoft.SqlServer.Management.Smo.UrnCollection
        $scripterFile = "$($databaseDirectory)\DDL_$($type).sql"
        Remove-Item -Path $scripterFile -ErrorAction Ignore
        $scripter.Options.Filename = $scripterFile

        $objectsProcessed = 0
        $objectsEncrypted = 0
        $objectsErrored = 0
        foreach ($object in $objectsToProcess) {
            try {
                $encrypted = $object.IsEncrypted -or $false
                $ddlFile = if ($encrypted) { $null } else { $scripterFile }

                # save object summary
                [PSCustomObject]@{
                    "Script Version" = $version
                    "Run Date" = $startTime
                    "Server" = $serverName
                    "Instance" = $instanceName
                    "Database" = $database.Name
                    "Schema" = $object.Schema
                    "Name" = $object.Name
                    "Type" = $type
                    "Encrypted" = $encrypted
                    "DDL File" = $ddlFile
                } | Export-Csv -Path "$($ScriptDirectory)\object_inventory.csv" -NoTypeInformation -Append

                switch($encrypted) {
                    $true {
                        $objectsEncrypted += 1
                        Write-Warning "object '$($database.Name).$($object.Schema).$($object.Name)' encrypted, not retrieved"
                    }
                    $false {
                        if ($isTableType) {

                            # save table summary
                            [PSCustomObject]@{
                                "Script Version" = $version
                                "Run Date" = $startTime
                                "Server" = $serverName
                                "Instance" = $instanceName
                                "Database" = $database.Name
                                "Schema" = $object.Schema
                                "Name" = $object.Name
                                "Data Space Used (KB)" = $object.DataSpaceUsed
                                "Index Space Used (KB)" = $object.IndexSpaceUsed
                                "Row Count" = $object.RowCount
                            } | Export-Csv -Path "$($ScriptDirectory)\table_summary.csv" -NoTypeInformation -Append
                        }

                        $urnCollection.add($object.urn)
                        $objectsProcessed += 1
                    }
                }
            }
            catch {
                $objectsErrored += 1
                Write-Warning $_
            }
        }
        if ($objectsProcessed -gt 0) {
            $scripter.script($urnCollection)
        }
        Write-Host "Retrieved $($objectsProcessed) of $($objectsToProcess.Count) object(s) of type '$($type)' ($($objectsEncrypted) encrypted, $($objectsErrored) errors) from database '$($database.Name)'"
        $global:totalObjectsProcessed += $objectsProcessed
        $global:totalObjectsEncrypted += $objectsEncrypted
        $global:totalObjectsErrored += $objectsErrored
        $global:totalObjectsToProcess += $objectsToProcess.Count
        if ($isTableType) {
            $global:totalTablesProcessed += $objectsProcessed
            $global:totalTablesToProcess += $objectsToProcess.Count
        }
    }
    catch {
        Write-Warning $_
    }
}


# set total counters

$global:totalObjectsProcessed = 0
$global:totalObjectsEncrypted = 0
$global:totalObjectsErrored = 0
$global:totalObjectsToProcess = 0
$global:totalTablesProcessed = 0
$global:totalTablesToProcess = 0


# get server\instance-level objects
Get-ServerObjectDdl -objects $server.LinkedServers -type LinkedServer

# get database-level objects
$databasesProcessed = 0

foreach ($database in $databases) {
    try {

        # set up this database directory

        Confirm-DirectoryExists -directory ($databaseDirectory = "$($instanceDirectory)\$($database.Name)")


        # save this database summary
        [PSCustomObject]@{
            "Script Version" = $version
            "Run Date" = $startTime
            "Server" = $serverName
            "Instance" = $instanceName
            "Database" = $database.Name
            "Size (MB)" = $database.Size
            "Data Space Usage (KB)" = $database.DataSpaceUsage
            "Index Space Usage (KB)" = $database.IndexSpaceUsage
            "Space Available (KB)" = $database.SpaceAvailable
        } | Export-Csv -Path "$($ScriptDirectory)\database_summary.csv" -NoTypeInformation -Append
        Write-Host "Retrieved summary information for database '$($database.Name)'"

        # get object types
        Get-DatabaseObjectDdl -objects $database.Roles -type DatabaseRole
        Get-DatabaseObjectDdl -objects $database.ExtendedStoredProcedures -type ExtendedStoredProcedure
        Get-DatabaseObjectDdl -objects $database.ExternalDataSources -type ExternalDataSource
        Get-DatabaseObjectDdl -objects $database.ExternalFileFormats -type ExternalFileFormat
        Get-DatabaseObjectDdl -objects $database.ExternalLibraries -type ExternalLibrary
        Get-DatabaseObjectDdl -objects $database.Sequences -type Sequence
        Get-DatabaseObjectDdl -objects $database.Synonyms -type Synonym
        Get-DatabaseObjectDdl -objects $database.Schemas -type Schema
        Get-DatabaseObjectDdl -objects $database.StoredProcedures -type StoredProcedure
        Get-DatabaseObjectDdl -objects $database.Tables -type Table -isTableType
        Get-DatabaseObjectDdl -objects $database.UserDefinedAggregates -type UserDefinedAggregate
        Get-DatabaseObjectDdl -objects $database.UserDefinedDataTypes -type UserDefinedDataType
        Get-DatabaseObjectDdl -objects $database.UserDefinedFunctions -type UserDefinedFunction
        Get-DatabaseObjectDdl -objects $database.UserDefinedTableTypes -type UserDefinedTableType
        Get-DatabaseObjectDdl -objects $database.UserDefinedTypes -type UserDefinedType
        Get-DatabaseObjectDdl -objects $database.Views -type View

        $databasesProcessed += 1
    }
    catch {
        Write-Warning $_
    }
}

$endTime = Get-Date
Write-Host "[ $($MyInvocation.MyCommand.Name) processed $($databasesProcessed) out of $($databases.Count) databases on instance '$($ServerInstance)' in $(New-TimeSpan -Start $startTime -End $endTime) ]"
Write-Host "[ $($global:totalObjectsProcessed) of $($global:totalObjectsToProcess) total database objects retrieved ($($global:totalObjectsEncrypted) encrypted, $($global:totalObjectsErrored) errors) ]"
Write-Host "[ $($global:totalTablesProcessed) of $($global:totalTablesToProcess) total tables retrieved ]"


exit 0

