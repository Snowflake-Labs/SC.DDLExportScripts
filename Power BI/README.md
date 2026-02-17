# Power BI Bulk PBIX to PBIT Converter

## Version
0.2.0

## Overview

This PowerShell script (`bulk-convert-pbix-to-pbit.ps1`) provides an interactive, automated way to convert Power BI `.pbix` files to `.pbit` template files in bulk. It uses a hybrid approach that preserves **all visuals AND data connections**, making it ideal for creating reusable templates from existing Power BI reports.

## Key Features

- **Hybrid Conversion**: Combines the best of both worlds:
  - Preserves ALL visuals from the original PBIX (including custom, Python, and R visuals)
  - Maintains correct data model schema with connections, tables, measures, and M queries
- **Bulk Processing**: Convert multiple PBIX files in a single run
- **Automatic Tool Installation**: Downloads and configures required dependencies (`pbi-tools`)
- **Visual Detection**: Identifies and reports custom visuals, Python visuals, and R visuals
- **Fallback Mechanism**: Automatically falls back to direct compilation if the hybrid approach fails
- **Interactive Interface**: User-friendly prompts guide you through the conversion process

## How It Works

The script uses a sophisticated 5-step process:

1. **Extract PBIX** (pbi-tools Desktop Edition) - Parses the model and report structure
2. **Compile Temporary PBIT** (pbi-tools Core Edition) - Generates correct DataModelSchema
3. **Extract Schema** - Retrieves the DataModelSchema from the compiled PBIT
4. **Clone & Modify** - Clones the original PBIX and surgically replaces the data model
5. **Create PBIT** - Produces a template with all visuals + correct data connections

**Why this approach?**
- Direct PBIT compilation may lose custom/Python/R visuals
- The original PBIX has all visuals intact
- This version combines the model from compilation with the report from the original PBIX

## Prerequisites

### Required

1. **Power BI Desktop (MSI Version)**
   - Microsoft Store version is NOT supported
   - Download from: https://www.microsoft.com/en-us/download/details.aspx?id=58494
   - The script will detect if you have the wrong version

2. **Windows PowerShell**
   - Built into Windows (requires Windows)
   - PowerShell 5.1 or later recommended

### Auto-Installed by Script

The script will automatically download and install these if missing:

1. **pbi-tools Desktop Edition (v1.2.0)**
   - Used for extracting PBIX files
   - Requires Power BI Desktop DLLs

2. **pbi-tools Core Edition (v1.2.0 .NET 9)**
   - Used for compiling PBIT files
   - No Power BI Desktop dependency

## Installation

1. Download the script: `bulk-convert-pbix-to-pbit.ps1`
2. Place it in any folder on your Windows machine
3. No additional installation required - the script handles dependencies

## Usage

### Basic Steps

1. **Run the script**:
   ```powershell
   .\bulk-convert-pbix-to-pbit.ps1
   ```

2. **Follow the interactive prompts**:
   - The script will check for Power BI Desktop installation
   - It will verify/install pbi-tools if needed
   - You'll be asked to provide the folder containing your PBIX files
   - Choose an output subfolder name (default: `PBIT_Output`)
   - Confirm and proceed with conversion

3. **Review results**:
   - The script displays progress for each file
   - Summary report shows successes, failures, and warnings
   - Option to open the output folder when complete

### Example Session

```
  =========================================================
  |                                                       |
  |   Power BI Bulk PBIX to PBIT Converter (pbi-tools)    |
  |   Preserves Visuals + Data Connections                |
  |                                                       |
  =========================================================

  Checking for Power BI Desktop...
  Power BI Desktop (MSI) found. Version: 2.134.1102.0

  Checking for pbi-tools Desktop Edition (extract)...
  Found: C:\Users\...\pbi-tools\pbi-tools.exe

  Checking for pbi-tools Core Edition (compile)...
  Found: C:\Users\...\pbi-tools-core\pbi-tools.core.exe

  Enter the folder path containing .pbix files to convert:
  Folder path: C:\MyReports

  Found 5 .pbix file(s):
    - SalesReport.pbix (12.5 MB)
    - InventoryDashboard.pbix (8.2 MB)
    ...

  Output: C:\MyReports\PBIT_Output

  Proceed with conversion? (Y/N): Y

  Converting: SalesReport.pbix... OK [visuals + data preserved]
      [i] CUSTOM_VISUALS: MyCustomChart
  ...
```

## Output

### Conversion Results

- **OK**: Successful conversion using V3 hybrid method (all visuals + data preserved)
- **OK [fallback]**: Successful conversion using direct compile (data preserved, visuals may be incomplete)
- **FAILED**: Conversion failed (error details provided)

### Files with Special Visuals

The script detects and reports:
- **Custom Visuals**: Third-party or organizational visuals
- **Python Visuals**: Visuals using Python scripts
- **R Visuals**: Visuals using R scripts

These are preserved in the current hybrid mode but may be lost in fallback mode.

### Summary Report

After conversion, you'll see:
- Total files processed
- Success count (broken down by method)
- Failed count with details
- Output folder location
- List of files with special visuals
- List of failed files with error messages

## Configuration

You can modify these variables at the top of the script:

```powershell
$DefaultSubfolderName = "PBIT_Output"     # Default output folder name
$BytesPerMegabyte = 1048576               # Used for size calculations
$PbiToolsInstallPath = "$env:LOCALAPPDATA\pbi-tools"
$PbiToolsCoreInstallPath = "$env:LOCALAPPDATA\pbi-tools-core"
```

## Troubleshooting

### Common Issues

**1. "Microsoft Store version detected"**
- Solution: Install Power BI Desktop MSI version
- Download from the official Microsoft download center

**2. "extract command not available"**
- Solution: The script will auto-install pbi-tools Desktop Edition
- If auto-install fails, manually download from GitHub

**3. "Compile failed for this file"**
- Some complex PBIX files may not compile successfully
- The script will report these as failed
- Check if the PBIX file opens correctly in Power BI Desktop

**4. "FAILED" during conversion**
- Check the error message for specific details
- Verify the PBIX file is not corrupted
- Ensure sufficient disk space for temporary files

### Visual Preservation

- **Current Hybrid Mode** (preferred): Preserves all visuals including custom/Python/R
- **Fallback Mode**: May lose custom visuals during report reconstruction
- Always review the output PBIT files to ensure all visuals are present

## Technical Details

### Temporary Files

The script creates temporary folders during conversion:
- Location: `%TEMP%\pbi-v3-[random-id]`
- Automatically cleaned up after conversion
- Contains extracted PBIX contents and intermediate files

### Data Preservation

**Preserved in PBIT:**
- Data source connections
- Tables and columns
- Measures and calculated columns
- Relationships
- M queries (Power Query)
- All report visuals
- Report layout and formatting

**Removed from PBIT:**
- Actual data (PBIT is a template)
- Data cache

## License

See the [License.txt](License.txt) file in this directory for licensing information.

## Additional Resources

- **pbi-tools GitHub**: https://github.com/pbi-tools/pbi-tools
- **Power BI Desktop**: https://www.microsoft.com/en-us/download/details.aspx?id=58494
- **PBIT Template Documentation**: https://docs.microsoft.com/en-us/power-bi/create-reports/desktop-templates

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Verify all prerequisites are met
3. Review error messages for specific guidance
4. Ensure PBIX files open correctly in Power BI Desktop
5. Contact snowconvert-support@snowflake.com

## Considerations

- The conversion process does not modify original PBIX files
- PBIT files are templates - they prompt for credentials when opened
- Large files may take several minutes to convert
- Temporary files can use significant disk space during conversion
- The script requires Windows (PowerShell is Windows-specific)
- **IMPORTANT**: There may be Power BI files that are not supported by this script and may have to be converted manually.
