SELECT
    N'@@START_SCHEMA@@' +
    s.name +
    N'@@END_SCHEMA@@' +
    N'@@START_NAME@@' +
    s.name +
    N'@@END_NAME@@' +
    N'@@START_OBJECT_DEFINITION@@' +
    CHAR(13) + CHAR(10) +
    'CREATE SCHEMA [' + s.name + '];' +
    CHAR(13) + CHAR(10) +
    N'@@END_OBJECT_DEFINITION@@'
FROM
    sys.schemas s
WHERE
    s.schema_id > 4
    AND s.name NOT IN ('db_owner', 'db_accessadmin', 'db_securityadmin', 'db_ddladmin', 'db_backupoperator', 'db_datareader', 'db_datawriter', 'db_denieddatawriter', 'db_denieddatareader') -- Excluir roles de base de datos
    AND s.name <> 'sysdiag' 
ORDER BY
    s.name;