SELECT
    ddl
FROM
(
    SELECT
        '/* <sc-view> ' + n.nspname + '.' + c.relname + ' </sc-view> */\n\n'
        + CASE
            WHEN c.relnatts > 0 and pg_get_viewdef(c.oid, TRUE) not ILIKE 'CREATE MATERIALIZED View%' THEN
                'CREATE OR REPLACE VIEW ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relname) + ' AS\n' + COALESCE(pg_get_viewdef(c.oid, TRUE), '')
            ELSE
                COALESCE(pg_get_viewdef(c.oid, TRUE), '')
        END
        + '\n' AS ddl
        , n.nspname as schemaname
    FROM
        pg_catalog.pg_class AS c
        INNER JOIN pg_catalog.pg_namespace AS n ON c.relnamespace = n.oid
    WHERE
        relkind = 'v'
        AND n.nspname not in ('information_schema', 'pg_catalog', 'pg_internal')
)
WHERE
    {schema_filter}
    -- For manual runs, remove the above line and replace with something like this:
    -- Example:
    -- lower(schemaname) LIKE '%'
;
