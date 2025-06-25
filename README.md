# Database Export Scripts Collection for SnowConvert

[![Run All Release Process](https://github.com/Snowflake-Labs/SC.DDLExportScripts/actions/workflows/release-all-ci.yml/badge.svg)](https://github.com/Snowflake-Labs/SC.DDLExportScripts/actions/workflows/release-all-ci.yml)

## Overview

This repository contains utility scripts for exporting database objects from various database platforms to be migrated with the [SnowConvert tool](https://docs.snowconvert.com/sc/). These scripts help extract DDL (Data Definition Language) statements that can be used as input for SnowConvert, facilitating the migration process to Snowflake.

## Supported Databases

- [Teradata](./Teradata)
- [SQL Server](./SQLServer)
- [Oracle](./Oracle)
- [Redshift](./Redshift)
- [Netezza](./Netezza)
- [Vertica](./Vertica)
- [DB2](./DB2)
- [Hive](./Hive)
- [BigQuery](./BigQuery)
- [Databricks](./Databricks)

## 🚀 Quick Start

**After cloning this repository, run the setup script:**

```bash
./setup.sh
```

Or manually install the Git hooks:

```bash
./.github/scripts/install-hooks.sh
```

This sets up Git hooks for code quality and version management.

## Getting Started

1. Select the directory for your source database platform
2. Follow the instructions in the platform-specific README file
3. Use the exported DDL files as input for SnowConvert

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](./LICENSE) file for details.

