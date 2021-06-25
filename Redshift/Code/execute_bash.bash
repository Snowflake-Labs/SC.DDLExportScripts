
# Clear output dir
pushd .
cd ../../Redshift/output
rm -rf *
popd
# Clear output_snowflake dir
pushd .
cd ../../Redshift/output_snowflake
rm -rf *
popd
# run extract
R < extract_redshift_tables_from_CSV.r --no-save
# convert to Snowflake
python COM-ES-Scripts-sql2sf.py ../output ../output_snowflake
# run extract
R < extract_redshift_tables_from_CSV.r --no-save
R < Assembly_exec_sqls.r --no-save

cd ../../Redshift/output_snowflake
rm schemas.sql