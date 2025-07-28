SELECT
    N'@@START_SCHEMA@@' +
    s.name +
    N'@@END_SCHEMA@@' +
    N'@@START_NAME@@' +
    t.name +
    N'@@END_NAME@@' +
    N'@@START_OBJECT_DEFINITION@@' +
    CHAR(13) + CHAR(10) +
    'CREATE TABLE [' + s.name + '].[' + t.name + '] (' + CHAR(13) + CHAR(10) +
    -- The result of the STRING_AGG is cast to NVARCHAR(MAX) to avoid the 8000 byte limit.
    -- This is done by casting the *input* expression to NVARCHAR(MAX).
    STRING_AGG(
        CAST(
            '    [' + c.name + '] ' +
            TYPE_NAME(c.system_type_id) +
            CASE 
                WHEN c.max_length != -1 AND TYPE_NAME(c.system_type_id) IN ('nvarchar', 'varchar', 'varbinary') THEN '(' + CAST(c.max_length AS VARCHAR(10)) + ')'
                WHEN c.max_length = -1 AND TYPE_NAME(c.system_type_id) IN ('nvarchar', 'varchar', 'varbinary') THEN '(MAX)'
                WHEN TYPE_NAME(c.system_type_id) IN ('decimal', 'numeric') THEN '(' + CAST(c.precision AS VARCHAR(10)) + ',' + CAST(c.scale AS VARCHAR(10)) + ')'
                ELSE ''
            END +
            CASE WHEN c.is_nullable = 1 THEN ' NULL' ELSE ' NOT NULL' END +
            CASE WHEN ic.is_identity = 1 THEN ' IDENTITY(' + CAST(ISNULL(ic.seed_value, 1) AS VARCHAR(10)) + ',' + CAST(ISNULL(ic.increment_value, 1) AS VARCHAR(10)) + ')' ELSE '' END
        AS NVARCHAR(MAX)), -- <<< THIS IS THE FIX
        ',' + CHAR(13) + CHAR(10)
    ) WITHIN GROUP (ORDER BY c.column_id) + CHAR(13) + CHAR(10) +
    ')' + CASE WHEN t.temporal_type = 2 THEN ' FOR SYSTEM_TIME AS HISTORY_TABLE = [' + OBJECT_SCHEMA_NAME(t.history_table_id) + '].[' + OBJECT_NAME(t.history_table_id) + ']' ELSE '' END + ';' + CHAR(13) + CHAR(10) + N'@@END_OBJECT_DEFINITION@@'
FROM
    sys.tables t
INNER JOIN
    sys.schemas s ON t.schema_id = s.schema_id 
INNER JOIN
    sys.columns c ON t.object_id = c.object_id
LEFT JOIN
    sys.identity_columns ic ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE
    t.is_ms_shipped = 0
GROUP BY
    s.name, t.name, t.temporal_type, t.history_table_id 
ORDER BY
    s.name, t.name;