SELECT
    N'@@START_SCHEMA@@' +
    s.name +
    N'@@END_SCHEMA@@' +
    N'@@START_NAME@@' +
    o.name +
    N'@@END_NAME@@' +
    N'@@START_OBJECT_DEFINITION@@' +
    CHAR(13) + CHAR(10) +
    sm.definition +
    CHAR(13) + CHAR(10) +
    N'@@END_OBJECT_DEFINITION@@'
FROM
    sys.sql_modules sm
INNER JOIN
    sys.objects o ON sm.object_id = o.object_id
INNER JOIN
    sys.schemas s ON o.schema_id = s.schema_id
WHERE
    o.type = 'P'
    AND s.name <> 'sys'; 