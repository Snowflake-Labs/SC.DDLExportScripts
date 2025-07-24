SELECT
    N'@@START_SCHEMA@@' +
    DB_NAME() COLLATE DATABASE_DEFAULT + -- File Formats are usually at the database level in serverless
    N'@@END_SCHEMA@@' +
    N'@@START_NAME@@' +
    name COLLATE DATABASE_DEFAULT +
    N'@@END_NAME@@' +
    N'@@START_OBJECT_DEFINITION@@' +
    CHAR(13) + CHAR(10) +
    'CREATE EXTERNAL FILE FORMAT [' + name COLLATE DATABASE_DEFAULT + ']' + CHAR(13) + CHAR(10) +
    'WITH (' + CHAR(13) + CHAR(10) +
    -- FIX: Use 'format_type' column (integer) and map it to a string description
    '    FORMAT_TYPE = ' +
        CASE format_type
            WHEN 1 THEN 'DELIMITEDTEXT' COLLATE DATABASE_DEFAULT
            WHEN 2 THEN 'PARQUET' COLLATE DATABASE_DEFAULT
            WHEN 3 THEN 'ORC' COLLATE DATABASE_DEFAULT
            WHEN 4 THEN 'DELTA' COLLATE DATABASE_DEFAULT -- Delta is type 4
            ELSE 'UNKNOWN' COLLATE DATABASE_DEFAULT -- Fallback for any unmapped types
        END + ',' + CHAR(13) + CHAR(10) +
    -- END FIX
    CASE
        WHEN format_type = 1 -- Only DELIMITEDTEXT has these options (using format_type now)
        THEN
            '    FIELD_TERMINATOR = ''' + ISNULL(field_terminator, '') COLLATE DATABASE_DEFAULT + ''',' + CHAR(13) + CHAR(10) +
            '    STRING_DELIMITER = ''' + ISNULL(string_delimiter, '') COLLATE DATABASE_DEFAULT + ''',' + CHAR(13) + CHAR(10) +
            '    USE_TYPE_DEFAULT = ' + CASE WHEN use_type_default = 1 THEN 'ON' ELSE 'OFF' END COLLATE DATABASE_DEFAULT + ',' + CHAR(13) + CHAR(10) +
            '    DATE_FORMAT = ''' + ISNULL(date_format, '') COLLATE DATABASE_DEFAULT + ''',' + CHAR(13) + CHAR(10) +
            '    FIRST_ROW = ' + CAST(first_row AS VARCHAR(10)) COLLATE DATABASE_DEFAULT + ',' + CHAR(13) + CHAR(10) +
            '    ROW_TERMINATOR = ''' + ISNULL(row_terminator, '') COLLATE DATABASE_DEFAULT + '''' + CHAR(13) + CHAR(10) +
            CASE WHEN parser_version IS NOT NULL THEN ', PARSER_VERSION = ' + CAST(parser_version AS VARCHAR(10)) COLLATE DATABASE_DEFAULT ELSE '' END
        ELSE ''
    END COLLATE DATABASE_DEFAULT +
    ');' + CHAR(13) + CHAR(10) +
    N'@@END_OBJECT_DEFINITION@@'
FROM
    sys.external_file_formats;