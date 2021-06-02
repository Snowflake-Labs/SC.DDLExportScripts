cd /workspace/SnowConvertDDLExportScripts/RedshiftMigrationLab/output
rm -rf *
cd /workspace/SnowConvertDDLExportScripts/RedshiftMigrationLab/output_snowflake
rm -rf *
cd /workspace/SnowConvertDDLExportScripts/RedshiftMigrationLab/Code
R < extract_redshift_tables_from_CSV.r --no-save
python COM-ES-Scripts-sql2sf.py /workspace/SnowConvertDDLExportScripts/RedshiftMigrationLab/output /workspace/SnowConvertDDLExportScripts/RedshiftMigrationLab/output_snowflake
R < extract_redshift_tables_from_CSV.r --no-save
R < Assembly_exec_sqls.r --no-save
cd /workspace/SnowConvertDDLExportScripts/RedshiftMigrationLab/output_snowflake
rm schemas.sql