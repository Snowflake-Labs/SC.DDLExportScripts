SELECT
    N'@@START_SCHEMA@@' +
    s.name COLLATE DATABASE_DEFAULT + 
    N'@@END_SCHEMA@@' +
    N'@@START_NAME@@' +
    t.name COLLATE DATABASE_DEFAULT + 
    '_Idx_' + i.name COLLATE DATABASE_DEFAULT +
    N'@@END_NAME@@' +
    N'@@START_OBJECT_DEFINITION@@' +
    CHAR(13) + CHAR(10) +
    'CREATE ' + CASE WHEN i.is_unique = 1 THEN 'UNIQUE ' ELSE '' END +
    i.type_desc COLLATE DATABASE_DEFAULT + ' INDEX [' + i.name COLLATE DATABASE_DEFAULT + ']' + CHAR(13) + CHAR(10) +
    'ON [' + s.name COLLATE DATABASE_DEFAULT + '].[' + t.name COLLATE DATABASE_DEFAULT + '] (' + CHAR(13) + CHAR(10) +
    STRING_AGG(
        '    , [' + c.name COLLATE DATABASE_DEFAULT + ']' + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END,
        ',' + CHAR(13) + CHAR(10)
    ) WITHIN GROUP (ORDER BY ic.key_ordinal) COLLATE DATABASE_DEFAULT + CHAR(13) + CHAR(10) + -- Apply collation to STRING_AGG result
    ')' + CHAR(13) + CHAR(10) +
    CASE WHEN i.has_filter = 1 THEN 'WHERE ' + i.filter_definition COLLATE DATABASE_DEFAULT + CHAR(13) + CHAR(10) ELSE '' END +
    'WITH (' + CHAR(13) + CHAR(10) +
    '    DATA_COMPRESSION = ' + CASE WHEN i.type = 5 THEN 'COLUMNSTORE' ELSE 'NONE' END COLLATE DATABASE_DEFAULT +
    ');' + CHAR(13) + CHAR(10) +
    N'@@END_OBJECT_DEFINITION@@'
FROM
    sys.indexes i
INNER JOIN
    sys.tables t ON i.object_id = t.object_id
INNER JOIN
    sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN
    sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id AND ic.is_included_column = 0
INNER JOIN
    sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE
    i.is_disabled = 0
    AND i.type IN (1, 2)
    AND i.is_primary_key = 0
    AND i.is_unique_constraint = 0
    AND i.name NOT LIKE 'PK_%'
    AND i.name NOT LIKE 'UQ_%'
GROUP BY
    s.name, t.name, i.name, i.is_unique, i.type_desc, i.type, i.has_filter, i.filter_definition,
    i.object_id, i.index_id
ORDER BY
    s.name, t.name, i.name;