SELECT
    N'@@START_SCHEMA@@' +
    s.name COLLATE DATABASE_DEFAULT +
    N'@@END_SCHEMA@@' +
    N'@@START_NAME@@' +
    o.name COLLATE DATABASE_DEFAULT +
    N'@@END_NAME@@' +
    N'@@START_OBJECT_DEFINITION@@' +
    CHAR(13) + CHAR(10) +
    sm.definition COLLATE DATABASE_DEFAULT +
    CHAR(13) + CHAR(10) +
    N'@@END_OBJECT_DEFINITION@@'
FROM
    sys.sql_modules sm
INNER JOIN
    sys.objects o ON sm.object_id = o.object_id
INNER JOIN
    sys.schemas s ON o.schema_id = s.schema_id
WHERE
    o.type = 'V' -- Filter for Views
    AND s.name <> 'sys' COLLATE DATABASE_DEFAULT;