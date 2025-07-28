SELECT
    N'@@START_SCHEMA@@' +
    DB_NAME() COLLATE DATABASE_DEFAULT + -- Data Sources are usually at the database level in serverless
    N'@@END_SCHEMA@@' +
    N'@@START_NAME@@' +
    name COLLATE DATABASE_DEFAULT +
    N'@@END_NAME@@' +
    N'@@START_OBJECT_DEFINITION@@' +
    CHAR(13) + CHAR(10) +
    'CREATE EXTERNAL DATA SOURCE [' + name COLLATE DATABASE_DEFAULT + ']' + CHAR(13) + CHAR(10) +
    'WITH (' + CHAR(13) + CHAR(10) +
    '    LOCATION = ''' + location COLLATE DATABASE_DEFAULT + '''' + CHAR(13) + CHAR(10) +
    '    ' + CASE WHEN credential_id IS NOT NULL THEN ', CREDENTIAL = [' + (SELECT name COLLATE DATABASE_DEFAULT FROM sys.database_scoped_credentials WHERE credential_id = s.credential_id) + ']' ELSE '' END COLLATE DATABASE_DEFAULT + CHAR(13) + CHAR(10) +
    ');' + CHAR(13) + CHAR(10) +
    N'@@END_OBJECT_DEFINITION@@'
FROM
    sys.external_data_sources s
WHERE
    name <> 'data_lake_store' COLLATE DATABASE_DEFAULT; -- Exclude default data source if not desired