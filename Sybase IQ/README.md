# Sybase IQ DDL Export Scripts

This folder contains scripts to export Sybase IQ database objects so they can be analyzed or migrated to [Snowflake](https://www.snowflake.com/) with [SnowConvert](https://docs.snowflake.com/en/migrations/snowconvert-docs/general/about).

## Version

0.1.0

## What the scripts do

Both the Bash and PowerShell scripts:
- Connect to Sybase IQ using `iqunload` and export a consolidated SQL file with object DDLs.
- Split the consolidated SQL into individual statements on lines that are exactly `go` (case-insensitive).
- Classify statements by object type and write them to:
  - `Tables/`, `Views/`, `Procedures/`, `Functions/`, `Sequences/`, `Triggers/`, `Indexes/`, `Grants/`
  - A fallback `Misc/Misc.sql` when a statement cannot be classified
- Track created objects to route subsequent `ALTER`, `COMMENT`, and `GRANT` statements to the right file.
- Generate a `.sc_extraction` metadata file with script version, extraction timestamp, source engine, and database name.
- Remove the initial consolidated SQL after the split completes.

## Prerequisites

1. Sybase IQ client utilities installed and accessible, specifically `iqunload` (or `iqunload.bat` on Windows).
2. Sufficient privileges for the user in the target database to extract DDL.
3. Disk space in the output directory for the consolidated SQL and split files.
4. A valid Sybase IQ connection string (examples below).

## Usage (Linux/macOS)

Run the Bash script:

```bash
bash "bin/Create_ddls.sh" \
  -c "ENG=myserver;DBN=mydb;UID=myuser;PWD=mypassword" \
  -o "/path/to/output" \
  -i "/opt/sap/SAPIQ/bin64/iqunload"
```

Arguments:
- `-c` Connection string (e.g., `ENG=server;DBN=database;UID=user;PWD=pass`)
- `-o` Output directory (will be created if it does not exist)
- `-i` Path to `iqunload` (or `iqunload.bat` in Windows environments)
- `--version` Print version and exit
- `--help` Show usage

Notes:
- The script derives the database name primarily from `DBN` (or from `DBF` file name if present).
- The consolidated SQL is produced with `iqunload -n -r <output.sql>` and split on `go`.

## Usage (Windows)

Run the PowerShell script:

```powershell
.\bin\Create_ddls.ps1 `
  -ConnectionString 'ENG=myserver;DBN=mydb;UID=myuser;PWD=mypassword' `
  -OutputPath 'C:\path\to\output' `
  -IqunloadPath 'C:\SAP\IQ\bin64\iqunload.bat'
```

Parameters:
- `-ConnectionString` Sybase IQ connection string
- `-OutputPath` Output directory (created if not present)
- `-IqunloadPath` Full path to `iqunload.bat`

## Output Layout

```
/path/to/output/
├── .sc_extraction               # Metadata: script version, extracted_on, source_engine, database_name
├── <schema_name>/
│   ├── Tables/
│   │   └── <object>.sql
│   ├── Views/
│   ├── Procedures/
│   ├── Functions/
│   ├── Sequences/
│   ├── Triggers/
│   ├── Indexes/
│   ├── Grants/
│   └── Misc/
│       └── Misc.sql
└── GLOBAL/
    └── Misc/
        └── Misc.sql
```

## Connection String Tips

Common keys include:
- `ENG` (server/engine), `DBN` (database name), `DBF` (database file), `UID` (user), `PWD` (password)

Examples:
- `ENG=server1;DBN=finance;UID=reporter;PWD=secret`
- `ENG=server2;DBF=/sap/iq/dbs/sales.db;UID=admin;PWD=secret`

If both `DBN` and `DBF` are present, the script prefers `DBN`. If only `DBF` is present, the base filename (without extension) is used as the database name.

## Troubleshooting

- `iqunload not found`: Verify the `-i` (Bash) or `-IqunloadPath` (PowerShell) points to the correct executable.
- `Input SQL not found`: Ensure `iqunload` can connect and that the provided connection string is valid.
- Empty or few objects: Check user permissions and that the target database contains the expected objects.
- Statement splitting: The splitter looks for lines that are exactly `go` (case-insensitive). Ensure the exported SQL uses this delimiter.

## License

These scripts are provided under the repository’s MIT license. See `LICENSE` at the root of this repo for details.


