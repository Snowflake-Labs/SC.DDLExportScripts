# Informatica Workflow Exporter (Python)

Cross-platform Python script to export all workflows from an Informatica PowerCenter folder as separate XML files. Works on both Windows and Linux.

Requires Python 3.7+ and `pmrep` installed. No third-party dependencies — uses only the Python standard library.

## Prerequisites

- Python 3.7+
- Informatica PowerCenter 10.4.1 (or compatible version)
- `pmrep` command-line utility
- Active connection to PowerCenter repository

## Quick Start

### Step 1: Connect to Repository

```bash
pmrep connect -r <reposervicename> -h <hostname> -o <portal_port_number> -n <username> -x <password>
```

### Step 2: Run the Export Script

```bash
python export_all_workflows.py --folder-name "<folder_name>"
```

### Step 3: Disconnect When Done

```bash
pmrep cleanup
```

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `--pmrep-path` | No | OS-specific (see below) | Path to the `pmrep` executable |
| `--folder-name` | Yes | — | Informatica PowerCenter folder name to export workflows from |
| `--export-dir` | No | `./exports` | Directory where the exported `.xml` files will be saved |

### Default `pmrep` paths by OS

| OS | Default Path |
|----|-------------|
| Windows | `C:\Informatica\10.4.1\server\bin\pmrep.exe` |
| Linux | `/opt/informatica/10.4.1/server/bin/pmrep` |

## Usage Examples

### Basic Usage

```bash
python export_all_workflows.py --folder-name "<folder_name>"
```

### Specify Custom Export Directory

```bash
python export_all_workflows.py --folder-name "<folder_name>" --export-dir "<export_directory>"
```

### Use Different Informatica Version

```bash
python export_all_workflows.py --pmrep-path "<path_to_pmrep>" --folder-name "<folder_name>"
```

## Output

The script creates one XML file per workflow in the export directory:

```
<export_directory>/
  ├── WF_DAILY_LOAD.xml
  ├── WF_NIGHTLY_BATCH.xml
  └── WF_CUSTOMER_SYNC.xml
```
