<#
.SYNOPSIS
    Interactive bulk converter for Power BI .pbix files to .pbit templates using pbi-tools.

.DESCRIPTION
    Current version - Hybrid approach that preserves ALL visuals AND data connections:

    1. pbi-tools Desktop Edition EXTRACTS the PBIX (parses model + report)
    2. pbi-tools Core Edition COMPILES a temporary PBIT (produces correct DataModelSchema)
    3. The DataModelSchema is extracted from the temp PBIT
    4. The original PBIX is cloned and surgically modified:
       - DataModel (binary+data) is replaced with the correct DataModelSchema
       - SecurityBindings is removed
       - [Content_Types].xml is updated
    5. Result: a PBIT with ALL visuals from the original PBIX + correct data model

    Why this works:
    - pbi-tools compile produces a valid DataModelSchema (connections, tables, M queries)
      but may lose custom/Python/R visuals during report reconstruction
    - The original PBIX has all visuals intact
    - Current version (v3) takes the model from compile and the report from the original = complete PBIT

.NOTES
    - Requires Power BI Desktop MSI version (NOT Microsoft Store version)
    - pbi-tools Desktop Edition: extract command (needs PBI Desktop DLLs)
    - pbi-tools Core Edition: compile command (no PBI Desktop dependency)
    - Custom/Python/R visuals are fully preserved
    - Data connections, tables, measures, relationships are fully preserved

.EXAMPLE
    .\bulk-convert-pbix-to-pbit.ps1
#>

# ============================================
# CONFIGURATION
# ============================================
$DefaultSubfolderName = "PBIT_Output"
$BytesPerMegabyte = 1048576
$PbiToolsInstallPath = "$env:LOCALAPPDATA\pbi-tools"
$PbiToolsCoreInstallPath = "$env:LOCALAPPDATA\pbi-tools-core"

$PbiToolsDesktopUrl = "https://github.com/pbi-tools/pbi-tools/releases/download/1.2.0/pbi-tools.1.2.0.zip"
$PbiToolsCoreNet9Url = "https://github.com/pbi-tools/pbi-tools/releases/download/1.2.0/pbi-tools.net9.1.2.0_win-x64.zip"

# ============================================
# UTILITY FUNCTIONS
# ============================================

function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  =========================================================" -ForegroundColor Cyan
    Write-Host "  |                                                       |" -ForegroundColor Cyan
    Write-Host "  |   Power BI Bulk PBIX to PBIT Converter (pbi-tools)    |" -ForegroundColor Cyan
    Write-Host "  |   Preserves Visuals + Data Connections                |" -ForegroundColor Cyan
    Write-Host "  |                                                       |" -ForegroundColor Cyan
    Write-Host "  =========================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Get-PowerBIDesktopVersion {
    $pbiExePath = "$env:ProgramFiles\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
    if (Test-Path $pbiExePath) {
        try {
            $versionInfo = (Get-Item $pbiExePath).VersionInfo
            return @{ Version = $versionInfo.FileVersion; Path = $pbiExePath }
        }
        catch { return $null }
    }
    return $null
}

function Test-PowerBIDesktopInstalled {
    $msiPaths = @(
        "$env:ProgramFiles\Microsoft Power BI Desktop\bin\PBIDesktop.exe",
        "${env:ProgramFiles(x86)}\Microsoft Power BI Desktop\bin\PBIDesktop.exe",
        "$env:LOCALAPPDATA\Microsoft\Power BI Desktop\bin\PBIDesktop.exe"
    )
    foreach ($path in $msiPaths) {
        if (Test-Path $path) { return "MSI" }
    }
    $storePath = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\WindowsApps" -Filter "PBIDesktop*.exe" -ErrorAction SilentlyContinue
    if ($storePath) { return "Store" }
    $storeApps = Get-ChildItem -Path "$env:ProgramFiles\WindowsApps" -Filter "Microsoft.MicrosoftPowerBIDesktop*" -Directory -ErrorAction SilentlyContinue
    if ($storeApps) { return "Store" }
    return $null
}

function Add-ToPath {
    param([string]$FolderPath)
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    $pathArray = $currentPath -split ";"
    foreach ($p in $pathArray) {
        if ($p.Trim() -eq $FolderPath.Trim()) {
            Write-Host "  pbi-tools folder already in PATH." -ForegroundColor DarkGray
            return $false
        }
    }
    Write-Host "  Adding pbi-tools to user PATH..." -ForegroundColor Cyan
    $newPath = $currentPath.TrimEnd(";") + ";" + $FolderPath
    [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::User)
    $env:Path = $env:Path.TrimEnd(";") + ";" + $FolderPath
    Write-Host "  Added to PATH: $FolderPath" -ForegroundColor Green
    return $true
}

function Get-PbiToolsExecutable {
    $localPath = Join-Path $PbiToolsInstallPath "pbi-tools.exe"
    if (Test-Path $localPath) { return $localPath }
    $cmd = Get-Command "pbi-tools.exe" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    foreach ($basePath in @("$env:ProgramFiles\pbi-tools","${env:ProgramFiles(x86)}\pbi-tools","C:\pbi-tools","C:\Tools\pbi-tools")) {
        $exePath = Join-Path $basePath "pbi-tools.exe"
        if (Test-Path $exePath) { return $exePath }
    }
    return $null
}

function Get-PbiToolsCoreExecutable {
    $localPath = Join-Path $PbiToolsCoreInstallPath "pbi-tools.core.exe"
    if (Test-Path $localPath) { return $localPath }
    $cmd = Get-Command "pbi-tools.core.exe" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    foreach ($basePath in @("$env:LOCALAPPDATA\pbi-tools-core","$env:ProgramFiles\pbi-tools-core","C:\pbi-tools-core","C:\Tools\pbi-tools-core")) {
        $exePath = Join-Path $basePath "pbi-tools.core.exe"
        if (Test-Path $exePath) { return $exePath }
    }
    return $null
}

function Install-PbiToolsDesktop {
    Write-Host ""
    Write-Host "  Installing pbi-tools Desktop Edition..." -ForegroundColor Yellow
    try {
        if (-not (Test-Path $PbiToolsInstallPath)) { New-Item -ItemType Directory -Path $PbiToolsInstallPath -Force | Out-Null }
        $zipPath = Join-Path $env:TEMP "pbi-tools-desktop.zip"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Host "  Downloading from: $PbiToolsDesktopUrl" -ForegroundColor Cyan
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "PowerShell-PbiTools-Installer")
        $wc.DownloadFile($PbiToolsDesktopUrl, $zipPath)
        Get-ChildItem -Path $PbiToolsInstallPath -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $PbiToolsInstallPath)
        Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
        $null = Add-ToPath -FolderPath $PbiToolsInstallPath
        $exe = Join-Path $PbiToolsInstallPath "pbi-tools.exe"
        if (Test-Path $exe) { Write-Host "  Installed successfully!" -ForegroundColor Green; return $exe }
        else { throw "pbi-tools.exe not found after installation" }
    }
    catch {
        Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Download manually: $PbiToolsDesktopUrl" -ForegroundColor Yellow
        return $null
    }
}

function Install-PbiToolsCore {
    Write-Host ""
    Write-Host "  Installing pbi-tools Core Edition (.NET 9)..." -ForegroundColor Yellow
    try {
        if (-not (Test-Path $PbiToolsCoreInstallPath)) { New-Item -ItemType Directory -Path $PbiToolsCoreInstallPath -Force | Out-Null }
        $zipPath = Join-Path $env:TEMP "pbi-tools-core.zip"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Host "  Downloading from: $PbiToolsCoreNet9Url" -ForegroundColor Cyan
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "PowerShell-PbiTools-Installer")
        $wc.DownloadFile($PbiToolsCoreNet9Url, $zipPath)
        Get-ChildItem -Path $PbiToolsCoreInstallPath -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $PbiToolsCoreInstallPath)
        Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
        $null = Add-ToPath -FolderPath $PbiToolsCoreInstallPath
        $exe = Join-Path $PbiToolsCoreInstallPath "pbi-tools.core.exe"
        if (Test-Path $exe) { Write-Host "  Installed successfully!" -ForegroundColor Green; return $exe }
        else { throw "pbi-tools.core.exe not found after installation" }
    }
    catch {
        Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Download manually: $PbiToolsCoreNet9Url" -ForegroundColor Yellow
        return $null
    }
}

function Get-FolderFromUser {
    param([string]$Prompt = "Enter the folder path containing .pbix files")
    while ($true) {
        Write-Host ""
        Write-Host "  $Prompt" -ForegroundColor Yellow
        Write-Host "  (or type 'quit' to exit)" -ForegroundColor DarkGray
        Write-Host ""
        $folderPath = Read-Host "  Folder path"
        if ($folderPath -eq 'quit' -or $folderPath -eq 'exit' -or $folderPath -eq 'q') {
            Write-Host "  Exiting..." -ForegroundColor Yellow; exit 0
        }
        $folderPath = $folderPath.Trim('"', "'", ' ')
        if ([string]::IsNullOrWhiteSpace($folderPath)) {
            Write-Host "  [!] Please enter a valid path." -ForegroundColor Red; continue
        }
        if (-not (Test-Path $folderPath -PathType Container)) {
            Write-Host "  [!] Folder not found: $folderPath" -ForegroundColor Red; continue
        }
        return $folderPath
    }
}

function Get-YesNoFromUser {
    param([string]$Prompt)
    while ($true) {
        $response = Read-Host "  $Prompt (Y/N)"
        switch ($response.ToUpper()) {
            'Y'   { return $true }
            'YES' { return $true }
            'N'   { return $false }
            'NO'  { return $false }
            default { Write-Host "  [!] Please enter Y or N" -ForegroundColor Red }
        }
    }
}

# ============================================
# VISUAL DETECTION
# ============================================

function Get-PbixVisualInfo {
    param([string]$ExtractedPath)

    $result = @{
        HasCustomVisuals  = $false; CustomVisualNames = @()
        HasPythonVisuals  = $false; PythonVisualCount = 0
        HasRVisuals       = $false; RVisualCount      = 0
        Warnings          = @()
    }

    # Check CustomVisuals folder
    $cvPath = Join-Path $ExtractedPath "Report\CustomVisuals"
    if (Test-Path $cvPath) {
        $cvDirs = Get-ChildItem -Path $cvPath -Directory -ErrorAction SilentlyContinue
        if ($cvDirs -and $cvDirs.Count -gt 0) {
            $result.HasCustomVisuals  = $true
            $result.CustomVisualNames = @($cvDirs | ForEach-Object { $_.Name })
            $result.Warnings += "Custom visuals ($($cvDirs.Count)): $($result.CustomVisualNames -join ', ')"
        }
    }

    # Scan report JSON for Python/R/custom visual types
    $reportDir = Join-Path $ExtractedPath "Report"
    $allContent = ""
    if (Test-Path $reportDir) {
        Get-ChildItem -Path $reportDir -Filter "*.json" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            try { $allContent += "`n" + (Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue) } catch {}
        }
    }
    $layoutPath = Join-Path $ExtractedPath "Report\Layout"
    if (Test-Path $layoutPath) {
        try { $allContent += "`n" + (Get-Content $layoutPath -Raw -ErrorAction SilentlyContinue) } catch {}
    }

    if ($allContent) {
        $pyCount = ([regex]::Matches($allContent, '"pythonVisual"', 'IgnoreCase')).Count
        $pyCount += ([regex]::Matches($allContent, '"pythonScript"', 'IgnoreCase')).Count
        if ($pyCount -gt 0) {
            $result.HasPythonVisuals = $true; $result.PythonVisualCount = $pyCount
            $result.Warnings += "Python visuals ($pyCount references)"
        }

        $rCount = ([regex]::Matches($allContent, '"rVisual"', 'IgnoreCase')).Count
        $rCount += ([regex]::Matches($allContent, '"rScript"', 'IgnoreCase')).Count
        if ($rCount -gt 0) {
            $result.HasRVisuals = $true; $result.RVisualCount = $rCount
            $result.Warnings += "R visuals ($rCount references)"
        }

        if (-not $result.HasCustomVisuals) {
            $standardTypes = @(
                'tableEx','pivotTable','barChart','columnChart','clusteredBarChart',
                'clusteredColumnChart','stackedBarChart','stackedColumnChart',
                'hundredPercentStackedBarChart','hundredPercentStackedColumnChart',
                'lineChart','areaChart','stackedAreaChart','lineStackedColumnComboChart',
                'lineClusteredColumnComboChart','ribbonChart','waterfallChart',
                'funnel','scatterChart','pieChart','donutChart','treemap',
                'map','filledMap','shapeMap','gauge','card','multiRowCard',
                'kpi','slicer','textbox','image','shape','bookmarkNavigator',
                'actionButton','pageNavigator','decompositionTreeVisual',
                'keyInfluencersVisual','qnaVisual','scriptVisual',
                'pythonVisual','rVisual','ArcGISMap','esriInfographic',
                'powerAppsVisual','paginatedReportVisual','narrativesVisual',
                'Group','cardVisual'
            )
            $vtMatches = [regex]::Matches($allContent, '"visualType"\s*:\s*"([^"]+)"')
            $unknown = @()
            foreach ($m in $vtMatches) {
                $vt = $m.Groups[1].Value
                if ($vt -notin $standardTypes -and $vt -notin $unknown) { $unknown += $vt }
            }
            if ($unknown.Count -gt 0) {
                $result.HasCustomVisuals = $true; $result.CustomVisualNames = $unknown
                $result.Warnings += "Custom visual types ($($unknown.Count)): $($unknown -join ', ')"
            }
        }
    }

    return $result
}

# ============================================
# CORE: HYBRID CONVERSION
# ============================================

function Get-DataModelSchemaFromCompiledPbit {
    <#
    .SYNOPSIS
        Compiles a temp PBIT via pbi-tools, then extracts the DataModelSchema
        entry from it. This produces the exact TMSL format Power BI expects,
        with all data sources, tables, columns, measures, M queries, etc.
    #>
    param(
        [string]$ExtractedPath,
        [string]$PbiToolsCorePath,
        [string]$TempBasePath
    )

    $tempCompileOutput = Join-Path $TempBasePath "temp_compile_output"
    if (-not (Test-Path $tempCompileOutput)) {
        New-Item -ItemType Directory -Path $tempCompileOutput -Force | Out-Null
    }

    try {
        # Compile extracted folder into a temporary PBIT
        # This PBIT may have broken/missing visuals - we only want its DataModelSchema
        Write-Host "      [i] Compiling temp PBIT to extract DataModelSchema..." -ForegroundColor DarkGray
        $compileResult = & $PbiToolsCorePath compile $ExtractedPath -format PBIT -outPath $tempCompileOutput -overwrite 2>&1

        if ($LASTEXITCODE -ne 0) {
            $errorText = $compileResult | Out-String
            Write-Host "      [!] Compile failed: $($errorText.Substring(0, [Math]::Min(200, $errorText.Length)))" -ForegroundColor DarkYellow
            return $null
        }

        # Find the compiled PBIT file
        $tempPbit = Get-ChildItem -Path $tempCompileOutput -Filter "*.pbit" -File | Select-Object -First 1
        if (-not $tempPbit) {
            Write-Host "      [!] No .pbit file found in compile output" -ForegroundColor DarkYellow
            return $null
        }

        # Open the temp PBIT as ZIP and read DataModelSchema
        Add-Type -AssemblyName System.IO.Compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem

        $zip = [System.IO.Compression.ZipFile]::OpenRead($tempPbit.FullName)
        try {
            $schemaEntry = $zip.GetEntry("DataModelSchema")
            if (-not $schemaEntry) {
                Write-Host "      [!] DataModelSchema not found in compiled PBIT" -ForegroundColor DarkYellow
                return $null
            }

            # Read the raw bytes - preserve exact encoding
            $stream = $schemaEntry.Open()
            $memStream = New-Object System.IO.MemoryStream
            $stream.CopyTo($memStream)
            $stream.Close()

            $rawBytes = $memStream.ToArray()
            $memStream.Dispose()

            Write-Host "      [i] DataModelSchema extracted ($($rawBytes.Length) bytes)" -ForegroundColor DarkGray
            return $rawBytes
        }
        finally {
            $zip.Dispose()
        }
    }
    catch {
        Write-Host "      [!] Failed to get DataModelSchema from compile: $($_.Exception.Message)" -ForegroundColor DarkYellow
        return $null
    }
    finally {
        # Cleanup temp compile output
        if (Test-Path $tempCompileOutput) {
            Remove-Item $tempCompileOutput -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function New-PbitFromPbixZip {
    <#
    .SYNOPSIS
        Creates a .pbit from a .pbix by ZIP manipulation.
        Clones the original PBIX (preserving ALL visuals) and replaces
        DataModel with DataModelSchema from pbi-tools compile output.
    .PARAMETER DataModelSchemaBytes
        Raw bytes of the DataModelSchema entry (exact encoding from compiled PBIT).
    #>
    param(
        [string]$PbixPath,
        [string]$OutputPath,
        [byte[]]$DataModelSchemaBytes
    )

    try {
        Add-Type -AssemblyName System.IO.Compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem

        # Clone the original PBIX
        Copy-Item -Path $PbixPath -Destination $OutputPath -Force

        $zip = [System.IO.Compression.ZipFile]::Open(
            $OutputPath,
            [System.IO.Compression.ZipArchiveMode]::Update
        )

        try {
            # Remove DataModel (binary data blob)
            $dmEntry = $zip.GetEntry("DataModel")
            if ($dmEntry) { $dmEntry.Delete() }

            # Remove SecurityBindings (not in PBIT)
            $sbEntry = $zip.GetEntry("SecurityBindings")
            if ($sbEntry) { $sbEntry.Delete() }

            # Add DataModelSchema with exact bytes from compiled PBIT
            $schemaEntry = $zip.CreateEntry("DataModelSchema", [System.IO.Compression.CompressionLevel]::Optimal)
            $stream = $schemaEntry.Open()
            try {
                $stream.Write($DataModelSchemaBytes, 0, $DataModelSchemaBytes.Length)
            }
            finally {
                $stream.Close()
                $stream.Dispose()
            }

            # Update [Content_Types].xml
            $ctEntry = $zip.GetEntry("[Content_Types].xml")
            if ($ctEntry) {
                $ctStream = $ctEntry.Open()
                $reader = New-Object System.IO.StreamReader($ctStream, [System.Text.Encoding]::UTF8)
                $ctXml = $reader.ReadToEnd()
                $reader.Close()
                $ctStream.Close()

                # Replace DataModel with DataModelSchema
                $ctXml = $ctXml -replace '<Override\s+PartName="/DataModel"\s+ContentType="[^"]*"\s*/>', '<Override PartName="/DataModelSchema" ContentType="application/json" />'
                # Remove SecurityBindings
                $ctXml = $ctXml -replace '<Override\s+PartName="/SecurityBindings"\s+ContentType="[^"]*"\s*/>', ''
                # Clean empty lines
                $ctXml = $ctXml -replace '(\r?\n)\s*(\r?\n)', '$1'

                $ctEntry.Delete()
                $newCtEntry = $zip.CreateEntry("[Content_Types].xml", [System.IO.Compression.CompressionLevel]::Optimal)
                $ctWriteStream = $newCtEntry.Open()
                $writer = New-Object System.IO.StreamWriter($ctWriteStream, (New-Object System.Text.UTF8Encoding($false)))
                try { $writer.Write($ctXml) }
                finally { $writer.Close(); $ctWriteStream.Close() }
            }
        }
        finally {
            $zip.Dispose()
        }

        if ((Test-Path $OutputPath) -and (Get-Item $OutputPath).Length -gt 1000) {
            return $true
        }
        throw "Output file is missing or too small"
    }
    catch {
        Write-Host "      [!] ZIP assembly failed: $($_.Exception.Message)" -ForegroundColor Yellow
        if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force -ErrorAction SilentlyContinue }
        return $false
    }
}

function Convert-SinglePbixToPbit {
    param(
        [System.IO.FileInfo]$PbixFile,
        [string]$OutputPath,
        [string]$PbiToolsDesktopPath,
        [string]$PbiToolsCorePath,
        [string]$TempBasePath
    )

    $baseName = $PbixFile.BaseName
    $tempExtractPath = Join-Path $TempBasePath $baseName
    $pbitOutputFile = Join-Path $OutputPath "$baseName.pbit"
    $visualInfo = $null
    $visualWarnings = @()

    try {
        # ================================================================
        # STEP 1: Extract PBIX with pbi-tools Desktop Edition
        # ================================================================
        $extractResult = & $PbiToolsDesktopPath extract $PbixFile.FullName -extractFolder $tempExtractPath 2>&1

        if ($LASTEXITCODE -ne 0) {
            $errorMsg = $extractResult | Out-String
            if ($errorMsg -match "Unknown action") {
                throw "extract command not available - need pbi-tools.exe (Desktop Edition)"
            }
            throw "pbi-tools extract failed: $errorMsg"
        }

        # ================================================================
        # STEP 2: Detect visuals
        # ================================================================
        $visualInfo = Get-PbixVisualInfo -ExtractedPath $tempExtractPath
        if ($visualInfo.HasCustomVisuals) { $visualWarnings += "CUSTOM_VISUALS: $($visualInfo.CustomVisualNames -join ', ')" }
        if ($visualInfo.HasPythonVisuals) { $visualWarnings += "PYTHON_VISUALS: $($visualInfo.PythonVisualCount) ref(s)" }
        if ($visualInfo.HasRVisuals)      { $visualWarnings += "R_VISUALS: $($visualInfo.RVisualCount) ref(s)" }

        # ================================================================
        # STEP 3: Compile temp PBIT and extract DataModelSchema bytes
        # ================================================================
        $schemaBytes = Get-DataModelSchemaFromCompiledPbit `
            -ExtractedPath $tempExtractPath `
            -PbiToolsCorePath $PbiToolsCorePath `
            -TempBasePath $TempBasePath

        if (-not $schemaBytes) {
            throw "Could not produce DataModelSchema - pbi-tools compile failed for this file"
        }

        # ================================================================
        # STEP 4: Build PBIT by cloning original PBIX + injecting schema
        # ================================================================
        $zipSuccess = New-PbitFromPbixZip `
            -PbixPath $PbixFile.FullName `
            -OutputPath $pbitOutputFile `
            -DataModelSchemaBytes $schemaBytes

        if ($zipSuccess) {
            return @{
                Success    = $true
                OutputFile = $pbitOutputFile
                Error      = $null
                Warnings   = $visualWarnings
                VisualInfo = $visualInfo
                Method     = "V3_HYBRID"
            }
        }

        throw "ZIP assembly failed after successful compile"
    }
    catch {
        # ================================================================
        # FALLBACK: Direct pbi-tools compile (may lose visuals)
        # ================================================================
        Write-Host ""
        Write-Host "      [!] hybrid method failed: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "      [>] Falling back to direct pbi-tools compile..." -ForegroundColor Cyan

        try {
            if (Test-Path $tempExtractPath) {
                $fbResult = & $PbiToolsCorePath compile $tempExtractPath -format PBIT -outPath $OutputPath -overwrite 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $fbWarnings = $visualWarnings + @("FALLBACK: Used direct compile - visuals may be incomplete")
                    return @{
                        Success    = $true
                        OutputFile = $pbitOutputFile
                        Error      = $null
                        Warnings   = $fbWarnings
                        VisualInfo = $visualInfo
                        Method     = "COMPILE_FALLBACK"
                    }
                }
            }
        }
        catch {}

        $errorDetail = $_.Exception.Message
        if ($visualWarnings.Count -gt 0) { $errorDetail += " | Visuals: $($visualWarnings -join '; ')" }

        return @{
            Success    = $false
            OutputFile = $null
            Error      = $errorDetail
            Warnings   = $visualWarnings
            VisualInfo = $visualInfo
            Method     = $null
        }
    }
    finally {
        if (Test-Path $tempExtractPath) {
            Remove-Item $tempExtractPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# ============================================
# MAIN SCRIPT
# ============================================

Write-Banner

# --- Check Power BI Desktop ---
Write-Host "  Checking for Power BI Desktop..." -ForegroundColor Cyan
$pbiInstallType = Test-PowerBIDesktopInstalled

if ($pbiInstallType -eq "MSI") {
    $pbiVersion = Get-PowerBIDesktopVersion
    Write-Host "  Power BI Desktop (MSI) found. Version: $($pbiVersion.Version)" -ForegroundColor Green
}
elseif ($pbiInstallType -eq "Store") {
    Write-Host ""
    Write-Host "  [WARNING] Microsoft Store version detected!" -ForegroundColor Yellow
    Write-Host "  pbi-tools requires the MSI version." -ForegroundColor White
    Write-Host "  Download: https://www.microsoft.com/en-us/download/details.aspx?id=58494" -ForegroundColor Cyan
    Write-Host ""
    if (-not (Get-YesNoFromUser -Prompt "Continue anyway?")) {
        Write-Host "  Press any key to exit..."; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 1
    }
}
else {
    Write-Host ""
    Write-Host "  [WARNING] Power BI Desktop not detected!" -ForegroundColor Yellow
    Write-Host "  Download MSI: https://www.microsoft.com/en-us/download/details.aspx?id=58494" -ForegroundColor Cyan
    Write-Host ""
    if (-not (Get-YesNoFromUser -Prompt "Continue anyway?")) {
        Write-Host "  Press any key to exit..."; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 1
    }
}

# --- Check pbi-tools Desktop Edition ---
Write-Host ""
Write-Host "  Checking for pbi-tools Desktop Edition (extract)..." -ForegroundColor Cyan
$pbiToolsDesktopPath = Get-PbiToolsExecutable
if (-not $pbiToolsDesktopPath) {
    Write-Host "  Not found." -ForegroundColor Yellow
    if (Get-YesNoFromUser -Prompt "Download and install pbi-tools Desktop Edition?") {
        $pbiToolsDesktopPath = Install-PbiToolsDesktop
        if (-not $pbiToolsDesktopPath) { Write-Host "  Press any key to exit..."; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 1 }
    } else { Write-Host "  Cannot proceed." -ForegroundColor Red; Write-Host "  Press any key to exit..."; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 1 }
} else { Write-Host "  Found: $pbiToolsDesktopPath" -ForegroundColor Green }

# --- Check pbi-tools Core Edition ---
Write-Host ""
Write-Host "  Checking for pbi-tools Core Edition (compile)..." -ForegroundColor Cyan
$pbiToolsCorePath = Get-PbiToolsCoreExecutable
if (-not $pbiToolsCorePath) {
    Write-Host "  Not found." -ForegroundColor Yellow
    if (Get-YesNoFromUser -Prompt "Download and install pbi-tools Core Edition?") {
        $pbiToolsCorePath = Install-PbiToolsCore
        if (-not $pbiToolsCorePath) { Write-Host "  Press any key to exit..."; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 1 }
    } else { Write-Host "  Cannot proceed." -ForegroundColor Red; Write-Host "  Press any key to exit..."; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 1 }
} else { Write-Host "  Found: $pbiToolsCorePath" -ForegroundColor Green }

Write-Host ""
Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
Write-Host "    Hybrid Conversion Pipeline" -ForegroundColor Cyan
Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
Write-Host "    Step 1 - Extract (Desktop):  parse PBIX model + report" -ForegroundColor White
Write-Host "    Step 2 - Compile (Core):     produce DataModelSchema" -ForegroundColor White
Write-Host "    Step 3 - ZIP assemble:       PBIX visuals + schema" -ForegroundColor Green
Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
Write-Host ""

# --- Get source folder ---
$sourceFolder = Get-FolderFromUser -Prompt "Enter the folder path containing .pbix files to convert:"

# --- Find PBIX files ---
Write-Host ""
Write-Host "  Scanning folder..." -ForegroundColor Cyan
$pbixFiles = Get-ChildItem -Path $sourceFolder -Filter "*.pbix" -File

if ($pbixFiles.Count -eq 0) {
    Write-Host "  [!] No .pbix files found in: $sourceFolder" -ForegroundColor Red
    Write-Host "  Press any key to exit..."; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 0
}

# --- Preview ---
Write-Host ""
Write-Host "  Found $($pbixFiles.Count) .pbix file(s):" -ForegroundColor Green
Write-Host ""
$totalSize = 0
foreach ($file in $pbixFiles) {
    $sizeMB = [math]::Round($file.Length / $BytesPerMegabyte, 2)
    $totalSize += $file.Length
    Write-Host "    - $($file.Name)" -ForegroundColor White -NoNewline
    Write-Host " ($($sizeMB) MB)" -ForegroundColor DarkGray
}
Write-Host ""
Write-Host "  Total size: $([math]::Round($totalSize / $BytesPerMegabyte, 2)) MB" -ForegroundColor Cyan
Write-Host ""

# --- Output folder ---
Write-Host "  Default output subfolder: $DefaultSubfolderName" -ForegroundColor DarkGray
$subfolderName = Read-Host "  Enter subfolder name (or press Enter for default)"
if ([string]::IsNullOrWhiteSpace($subfolderName)) { $subfolderName = $DefaultSubfolderName }
$outputFolder = Join-Path $sourceFolder $subfolderName
Write-Host ""
Write-Host "  Output: $outputFolder" -ForegroundColor Cyan
Write-Host ""

# --- Confirm ---
if (-not (Get-YesNoFromUser -Prompt "Proceed with conversion?")) {
    Write-Host "  Cancelled." -ForegroundColor Yellow; exit 0
}

# --- Create folders ---
Write-Host ""
if (-not (Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null
    Write-Host "  Created: $outputFolder" -ForegroundColor Green
} else {
    Write-Host "  Using existing: $outputFolder" -ForegroundColor Yellow
}

$tempBasePath = Join-Path $env:TEMP "pbi-v3-$([guid]::NewGuid().ToString('N').Substring(0,8))"
New-Item -ItemType Directory -Path $tempBasePath -Force | Out-Null

# --- Convert ---
Write-Host ""
Write-Host "  ---------------------------------------------------------" -ForegroundColor White
Write-Host "  | Converting (Hybrid method)...                                 |" -ForegroundColor Cyan
Write-Host "  ---------------------------------------------------------" -ForegroundColor White
Write-Host ""

$succeeded = 0; $succeededHybrid = 0; $succeededFallback = 0
$failed = 0; $failedFiles = @(); $filesWithWarnings = @()
$conversionResults = @()

foreach ($pbix in $pbixFiles) {
    Write-Host "    Converting: $($pbix.Name)... " -ForegroundColor White -NoNewline

    $result = Convert-SinglePbixToPbit `
        -PbixFile $pbix `
        -OutputPath $outputFolder `
        -PbiToolsDesktopPath $pbiToolsDesktopPath `
        -PbiToolsCorePath $pbiToolsCorePath `
        -TempBasePath $tempBasePath

    if ($result.Success) {
        if ($result.Method -eq "V3_HYBRID") {
            $hasSpecialVisuals = $result.Warnings -and $result.Warnings.Count -gt 0
            if ($hasSpecialVisuals) {
                Write-Host "OK" -ForegroundColor Green -NoNewline
                Write-Host " [visuals + data preserved]" -ForegroundColor DarkGreen
            } else {
                Write-Host "OK" -ForegroundColor Green
            }
            $succeededHybrid++
        } else {
            Write-Host "OK [fallback]" -ForegroundColor Yellow
            $succeededFallback++
        }
        $succeeded++

        if ($result.Warnings -and $result.Warnings.Count -gt 0) {
            $filesWithWarnings += @{ Name = $pbix.Name; Warnings = $result.Warnings; Method = $result.Method }
            foreach ($w in $result.Warnings) {
                Write-Host "      [i] $w" -ForegroundColor DarkGray
            }
        }

        $statusLabel = if ($result.Method -eq "V3_HYBRID") { "Success" } else { "Success (Fallback)" }
        $conversionResults += [PSCustomObject]@{ Name = $pbix.BaseName; Status = $statusLabel }
    }
    else {
        Write-Host "FAILED" -ForegroundColor Red
        Write-Host "      Error: $($result.Error)" -ForegroundColor DarkRed
        $failed++
        $failedFiles += @{ Name = $pbix.Name; Error = $result.Error; Warnings = if ($result.Warnings) { $result.Warnings } else { @() } }
        $conversionResults += [PSCustomObject]@{ Name = $pbix.BaseName; Status = "Failed" }
    }
}

# Cleanup
if (Test-Path $tempBasePath) { Remove-Item $tempBasePath -Recurse -Force -ErrorAction SilentlyContinue }

# --- Summary ---
Write-Host ""
Write-Host "  =========================================================" -ForegroundColor Cyan
Write-Host "  |                 Conversion Complete                   |" -ForegroundColor Cyan
Write-Host "  =========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "    Total files:     $($pbixFiles.Count)" -ForegroundColor White
Write-Host "    Succeeded:       $succeeded" -ForegroundColor Green
if ($succeededHybrid -gt 0) {
    Write-Host "      Hybrid (full): $succeededHybrid (visuals + data preserved)" -ForegroundColor Green
}
if ($succeededFallback -gt 0) {
    Write-Host "      Fallback:      $succeededFallback (data ok, visuals may be incomplete)" -ForegroundColor Yellow
}
if ($failed -gt 0) { Write-Host "    Failed:          $failed" -ForegroundColor Red }
else { Write-Host "    Failed:          0" -ForegroundColor Green }

Write-Host ""
Write-Host "    Output folder:   $outputFolder" -ForegroundColor Cyan
Write-Host ""

if ($filesWithWarnings.Count -gt 0) {
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "  | Files with Special Visuals                            |" -ForegroundColor Cyan
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    foreach ($fw in $filesWithWarnings) {
        $label = if ($fw.Method -eq "V3_HYBRID") { "[PRESERVED]" } else { "[FALLBACK]" }
        $color = if ($fw.Method -eq "V3_HYBRID") { "Green" } else { "Yellow" }
        Write-Host "    $label $($fw.Name)" -ForegroundColor $color
        foreach ($w in $fw.Warnings) { Write-Host "      - $w" -ForegroundColor DarkGray }
    }
    Write-Host ""
}

if ($failed -gt 0) {
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Red
    Write-Host "  | Failed Files                                          |" -ForegroundColor Red
    Write-Host "  ---------------------------------------------------------" -ForegroundColor Red
    Write-Host ""
    foreach ($f in $failedFiles) {
        Write-Host "    - $($f.Name)" -ForegroundColor DarkRed
        Write-Host "      $($f.Error)" -ForegroundColor DarkRed
        foreach ($w in $f.Warnings) { Write-Host "      - $w" -ForegroundColor DarkYellow }
    }
    Write-Host ""
}

# --- Export conversion report CSV ---
$csvFileName = "ConversionReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$csvFilePath = Join-Path $outputFolder $csvFileName
$conversionResults | Export-Csv -Path $csvFilePath -NoTypeInformation -Encoding UTF8
Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
Write-Host "  | Conversion Report Saved                               |" -ForegroundColor Cyan
Write-Host "  ---------------------------------------------------------" -ForegroundColor Cyan
Write-Host ""
Write-Host "    CSV report: $csvFilePath" -ForegroundColor Green
Write-Host ""

if ($succeeded -gt 0) {
    if (Get-YesNoFromUser -Prompt "Open output folder in Explorer?") {
        Start-Process explorer.exe -ArgumentList $outputFolder
    }
}

Write-Host ""
Write-Host "  Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
