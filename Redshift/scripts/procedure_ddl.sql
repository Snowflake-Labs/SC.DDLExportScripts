WITH arguments
AS (
	SELECT
	    oid
		, i
		, arg_name [i] AS argument_name
		, arg_types [i-1] argument_type
 		, arg_count
	FROM (
		SELECT
		    generate_series(1, arg_count) AS i
			, arg_name
			, arg_types
			, oid
      		, arg_count
		FROM (
			SELECT
			    oid
				, proargnames arg_name
				, proargtypes arg_types
				, pronargs arg_count
			FROM
			    pg_proc
			WHERE
			    proowner != 1
		) t
	) t
)

SELECT
	schemaname || '.' || proc_name as object_name
    , ddl
FROM
(
    SELECT
        n.nspname AS schemaname
        , p.proname AS proc_name
        , p.oid AS proc_oid
        , 2000 + nvl(i, 0) AS seq
        , a.arg_count
        , NVL(
            CASE
            	WHEN i = 1 THEN '('
                ELSE ','
              END || ' ' || format_type(argument_type, NULL)
              || CASE WHEN i = arg_count THEN ')' ELSE '' END
        , '') AS ddl
    FROM
        pg_proc p
        LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
        LEFT JOIN arguments a ON a.oid = p.oid
        LEFT JOIN pg_proc_info pi ON pi.prooid = p.oid
        WHERE
            p.proowner != 1
            AND pi.prokind = 'p'
    ORDER BY
        schemaname
        , proc_name
        , proc_oid, seq
)
WHERE
{schema_filter}
;