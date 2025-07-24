SELECT
    N'@@START_SCHEMA@@' +
    s.name COLLATE DATABASE_DEFAULT +
    N'@@END_SCHEMA@@' +
    N'@@START_NAME@@' +
    t.name COLLATE DATABASE_DEFAULT +
    N'@@END_NAME@@' +
    N'@@START_OBJECT_DEFINITION@@' +
    CHAR(13) + CHAR(10) +
    'CREATE EXTERNAL TABLE [' + s.name COLLATE DATABASE_DEFAULT + '].[' + t.name COLLATE DATABASE_DEFAULT + '] (' + CHAR(13) + CHAR(10) +
    -- The fix is to cast the input expression for STRING_AGG to NVARCHAR(MAX).
    -- This promotes the result to a large object type, avoiding the 8000-byte limit.
    STRING_AGG(
        CAST(
            '    [' + c.name COLLATE DATABASE_DEFAULT + '] ' +
            TYPE_NAME(c.system_type_id) COLLATE DATABASE_DEFAULT +
            CASE 
                WHEN c.max_length != -1 AND TYPE_NAME(c.system_type_id) IN ('nvarchar', 'varchar', 'varbinary') THEN '(' + CAST(c.max_length AS VARCHAR(10)) + ')'
                WHEN c.max_length = -1 AND TYPE_NAME(c.system_type_id) IN ('nvarchar', 'varchar', 'varbinary') THEN '(MAX)'
                WHEN TYPE_NAME(c.system_type_id) IN ('decimal', 'numeric') THEN '(' + CAST(c.precision AS VARCHAR(10)) + ',' + CAST(c.scale AS VARCHAR(10)) + ')'
                ELSE ''
            END +
            CASE WHEN c.is_nullable = 1 THEN ' NULL' ELSE ' NOT NULL' END
        AS NVARCHAR(MAX)), -- <<< THIS IS THE FIX
        ',' + CHAR(13) + CHAR(10)
    ) WITHIN GROUP (ORDER BY c.column_id) + CHAR(13) + CHAR(10) +
    ')' + CHAR(13) + CHAR(10) +
    'WITH (' + CHAR(13) + CHAR(10) +
    '    LOCATION = ''' + ext_t.location COLLATE DATABASE_DEFAULT + ''',' + CHAR(13) + CHAR(10) +
    '    DATA_SOURCE = [' + eds.name COLLATE DATABASE_DEFAULT + '],' + CHAR(13) + CHAR(10) +
    '    FILE_FORMAT = [' + eff.name COLLATE DATABASE_DEFAULT + ']' + CHAR(13) + CHAR(10) +
    ');' + CHAR(13) + CHAR(10) +
    N'@@END_OBJECT_DEFINITION@@'
FROM
    sys.external_tables AS ext_t
INNER JOIN
    sys.objects AS t ON ext_t.object_id = t.object_id
INNER JOIN
    sys.schemas AS s ON t.schema_id = s.schema_id
INNER JOIN
    sys.columns AS c ON t.object_id = c.object_id
INNER JOIN
    sys.external_data_sources AS eds ON ext_t.data_source_id = eds.data_source_id
INNER JOIN
    sys.external_file_formats AS eff ON ext_t.file_format_id = eff.file_format_id
WHERE
    t.is_ms_shipped = 0
GROUP BY
    s.name, t.name, ext_t.location, eds.name, eff.name
ORDER BY
    s.name, t.name;