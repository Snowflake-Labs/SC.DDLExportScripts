param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    [Parameter(Mandatory = $true)]
    [string]$IqunloadPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Script version (aligned with Synapse versioning header usage)
$VERSION = "0.1.1"

$iqunloadBat = $IqunloadPath
$outputDir = $OutputPath

if (-not (Test-Path -LiteralPath $iqunloadBat)) { throw "iqunload.bat not found: $iqunloadBat" }

if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
# Derive a meaningful base filename from the connection string (prefer DBN; support common aliases)
function Get-ConnKeyMap {
    param([string]$conn)
    $map = @{}
    foreach ($seg in ($conn -split ';')) {
        if ([string]::IsNullOrWhiteSpace($seg)) { continue }
        $pair = $seg -split '=', 2
        if ($pair.Length -eq 2) {
            $k = $pair[0].Trim()
            $v = $pair[1].Trim().Trim('"','''')
            if ($k) { $map[$k.ToLowerInvariant()] = $v }
        }
    }
    return $map
}
$connMap = Get-ConnKeyMap -conn $ConnectionString
$dbName = $null
foreach ($k in @('dbn','database','db','dbname','initial catalog')) {
    if ($connMap.ContainsKey($k)) { $dbName = $connMap[$k]; break }
}
if (-not $dbName -and $connMap.ContainsKey('dbf')) {
    try {
        $dbName = [System.IO.Path]::GetFileNameWithoutExtension($connMap['dbf'])
    } catch {
        # ignore and keep searching/fallback
    }
}
if ([string]::IsNullOrWhiteSpace($dbName)) { $dbName = 'database' }
$safeDbName = ($dbName -replace '[<>:\"/\\|\\?\\*]', '_')
$outputFile = Join-Path $outputDir ($safeDbName + '.sql')

$conn = $ConnectionString
$iqunloadArgs = @('-c', $conn, '-n', '-r', $outputFile)
& $iqunloadBat @iqunloadArgs

# -----------------------------
# Split consolidated SQL by schema/type/name
# -----------------------------
$inputSql = if (Test-Path -LiteralPath $outputFile) { $outputFile } else { Join-Path $PSScriptRoot 'script.sql' }
if (-not (Test-Path -LiteralPath $inputSql)) { throw "Input SQL not found: $inputSql" }

$splitRoot = $outputDir
if (-not (Test-Path -LiteralPath $splitRoot)) { New-Item -ItemType Directory -Path $splitRoot -Force | Out-Null }
Write-Host ("Splitting SQL file: {0}" -f $inputSql)
Write-Host ("Output split root: {0}" -f $splitRoot)

function Get-SafeName {
    param([string]$name)
    if (-not $name) { return $name }
    return ($name -replace '[<>:\"/\\\|\?\*]', '_')
}

# Generate .sc_extraction metadata file
$scExtractionFile = Join-Path $splitRoot '.sc_extraction'
$extractedOn = (Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz')
$metaLines = @(
    "script_version=$VERSION"
    "extracted_on=$extractedOn"
    "source_engine=SybaseIQ"
    "database_name=$dbName"
)
Set-Content -LiteralPath $scExtractionFile -Value $metaLines -Encoding UTF8
Write-Host ("Generated metadata file: {0}" -f $scExtractionFile)
# Print version and database name
Write-Host ("Extraction summary: version {0}, database {1}" -f $VERSION, $dbName)

function Write-StatementToObjectFile {
    param(
        [string]$schema,
        [string]$typeDir,
        [string]$objectName,
        [string]$statement
    )
    $schemaSafe = Get-SafeName $schema
    $objectSafe = Get-SafeName $objectName
    $targetDir = Join-Path (Join-Path $splitRoot $schemaSafe) $typeDir
    if (-not (Test-Path -LiteralPath $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
    $targetFile = Join-Path $targetDir ($objectSafe + '.sql')
    if (-not (Test-Path -LiteralPath $targetFile)) { New-Item -ItemType File -Path $targetFile -Force | Out-Null }
    Add-Content -LiteralPath $targetFile -Value ($statement.Trim() + [Environment]::NewLine + 'go' + [Environment]::NewLine) -Encoding UTF8
}

$sqlText = Get-Content -LiteralPath $inputSql -Raw
# Split on lines that are exactly 'go' (case-insensitive), preserving statement text
$statements = $sqlText -split '(?im)^\s*go\s*$' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
Write-Host ("Statements detected: {0}" -f $statements.Count)

# Known created objects map for routing related statements (schema|type|name) -> $true
$known = @{}
function Add-Known {
    param([string]$schema,[string]$type,[string]$name)
    if ($schema -and $type -and $name) {
        $key = ($schema + '|' + $type + '|' + $name)
        $known[$key] = $true
    }
}
function Resolve-TypeForObject {
    param([string]$schema,[string]$name)
    foreach ($t in @('Tables','Views','Procedures','Functions','Sequences','Triggers')) {
        $key = ($schema + '|' + $t + '|' + $name)
        if ($known.ContainsKey($key)) { return $t }
    }
    return $null
}

# Pass 1: discover created objects
foreach ($s in $statements) {
    if ($s -match '(?is)^\s*CREATE\s+TABLE\s+"([^"]+)"\."([^"]+)"') { Add-Known $Matches[1] 'Tables' $Matches[2]; continue }
    if ($s -match '(?is)^\s*CREATE\s+VIEW\s+"([^"]+)"\."([^"]+)"') { Add-Known $Matches[1] 'Views' $Matches[2]; continue }
    if ($s -match '(?is)^\s*CREATE\s+PROCEDURE\s+"([^"]+)"\."([^"]+)"') { Add-Known $Matches[1] 'Procedures' $Matches[2]; continue }
    if ($s -match '(?is)^\s*CREATE\s+FUNCTION\s+"([^"]+)"\."([^"]+)"') { Add-Known $Matches[1] 'Functions' $Matches[2]; continue }
    if ($s -match '(?is)^\s*CREATE\s+SEQUENCE\s+"([^"]+)"\."([^"]+)"') { Add-Known $Matches[1] 'Sequences' $Matches[2]; continue }
    if ($s -match '(?is)^\s*CREATE\s+TRIGGER\s+"([^"]+)"\."([^"]+)"') { Add-Known $Matches[1] 'Triggers' $Matches[2]; continue }
    if ($s -match '(?is)^\s*CREATE\s+\w*\s*INDEX\s+"([^"]+)"\s+ON\s+"([^"]+)"\."([^"]+)"') {
        # Track index as object under Indexes using table's schema for folder
        Add-Known $Matches[2] 'Indexes' $Matches[1]
        continue
    }
}

# Pass 2: route statements to files
foreach ($s in $statements) {
    if ($s -match '(?is)^\s*CREATE\s+TABLE\s+"([^"]+)"\."([^"]+)"') { Write-StatementToObjectFile $Matches[1] 'Tables' $Matches[2] $s; continue }
    if ($s -match '(?is)^\s*COMMENT\s+ON\s+TABLE\s+"([^"]+)"\."([^"]+)"') {
        $type = Resolve-TypeForObject $Matches[1] $Matches[2]; if (-not $type) { $type = 'Tables' }
        Write-StatementToObjectFile $Matches[1] $type $Matches[2] $s; continue
    }
    if ($s -match '(?is)^\s*ALTER\s+TABLE\s+"([^"]+)"\."([^"]+)"') {
        $type = Resolve-TypeForObject $Matches[1] $Matches[2]; if (-not $type) { $type = 'Tables' }
        Write-StatementToObjectFile $Matches[1] $type $Matches[2] $s; continue
    }
    if ($s -match '(?is)^\s*GRANT\s+.+?\s+ON\s+"([^"]+)"\."([^"]+)"') {
        $schema = $Matches[1]; $name = $Matches[2]
        $type = Resolve-TypeForObject $schema $name
        if (-not $type) { $type = 'Grants' }
        Write-StatementToObjectFile $schema $type $name $s; continue
    }
    if ($s -match '(?is)^\s*CREATE\s+VIEW\s+"([^"]+)"\."([^"]+)"') { Write-StatementToObjectFile $Matches[1] 'Views' $Matches[2] $s; continue }
    if ($s -match '(?is)^\s*COMMENT\s+ON\s+VIEW\s+"([^"]+)"\."([^"]+)"') {
        Write-StatementToObjectFile $Matches[1] 'Views' $Matches[2] $s; continue
    }
    if ($s -match '(?is)^\s*CREATE\s+PROCEDURE\s+"([^"]+)"\."([^"]+)"') { Write-StatementToObjectFile $Matches[1] 'Procedures' $Matches[2] $s; continue }
    if ($s -match '(?is)^\s*COMMENT\s+ON\s+PROCEDURE\s+"([^"]+)"\."([^"]+)"') {
        Write-StatementToObjectFile $Matches[1] 'Procedures' $Matches[2] $s; continue
    }
    if ($s -match '(?is)^\s*CREATE\s+FUNCTION\s+"([^"]+)"\."([^"]+)"') { Write-StatementToObjectFile $Matches[1] 'Functions' $Matches[2] $s; continue }
    if ($s -match '(?is)^\s*CREATE\s+\w*\s*INDEX\s+"([^"]+)"\s+ON\s+"([^"]+)"\."([^"]+)"') {
        # Use table schema for folder and index name as object folder
        $indexName = $Matches[1]; $schema = $Matches[2]
        Write-StatementToObjectFile $schema 'Indexes' $indexName $s; continue
    }
    # Unclassified: drop into Schema/Misc/Misc.sql
    if ($s -match '(?is)"([^"]+)"\."([^"]+)"') {
        $schema = $Matches[1]
    } else {
        $schema = 'GLOBAL'
    }
    $miscDir = Join-Path (Join-Path $splitRoot (Get-SafeName $schema)) 'Misc'
    if (-not (Test-Path -LiteralPath $miscDir)) { New-Item -ItemType Directory -Path $miscDir -Force | Out-Null }
    $miscFile = Join-Path $miscDir 'Misc.sql'
    Add-Content -LiteralPath $miscFile -Value ($s.Trim() + [Environment]::NewLine + 'go' + [Environment]::NewLine) -Encoding UTF8
}

# Remove consolidated file after split
if (Test-Path -LiteralPath $outputFile) {
    Remove-Item -LiteralPath $outputFile -Force
    Write-Host ("Removed consolidated file: {0}" -f $outputFile)
}