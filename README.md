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

## Important Note

**For contributors:** After cloning this repository, you must run the following script **once** to set up Git hooks:

```bash
./.github/scripts/install-hooks.sh
```

This script installs necessary Git hooks that help maintain code quality and consistency across the repository.

## Getting Started

1. Select the directory for your source database platform
2. Follow the instructions in the platform-specific README file
3. Use the exported DDL files as input for SnowConvert

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](./LICENSE) file for details.

