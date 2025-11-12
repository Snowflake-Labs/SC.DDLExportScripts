# Alternative SQL Server Extraction Methods

## Version
0.1.1

## Extraction Methods

This folder contains a set of alternative methods for code extraction for SQL Server, in case SQL Server Management Studio can not be executed in your system.
- mssql-scripter: Is a Python package developed by Microsoft developed to generate data definition language (DDL) and data manipulation language (DML) T-SQL scripts for database objects in SQL Server. We recommend using this option for MacOS and Linux. Also runs in Windows, but always try using SSMS in Windows environments. Needs a previous Python installation in your system.

- PowerShell Extraction Script: The Script attempts to connect to an instance of SQL Server and retrieves certain object definitions as individual DDL files to a local directory. This script should be executed in a Windows environment but we recommend using it in case SSMS and mssql-scripter definitely can't be executed in your system. 


## Table Sizing Report

