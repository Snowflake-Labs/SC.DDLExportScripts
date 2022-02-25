WITH arguments
AS (
	SELECT oid
		, i
		, arg_name [i] AS argument_name
		, arg_types [i-1] argument_type
	FROM (
		SELECT generate_series(1, arg_count) AS i
			, arg_name
			, arg_types
			, oid
		FROM (
			SELECT oid
				, proargnames arg_name
				, proargtypes arg_types
				, pronargs arg_count
			FROM pg_proc
			WHERE proowner != 1
			) t
		) t
	)
SELECT
	ddl
FROM
(
	SELECT
		schemaname
		, udfname
		, seq
		, trim(ddl) ddl
	FROM
	(
		SELECT
			n.nspname AS schemaname
			, p.proname AS udfname
			, p.oid AS udfoid
			, 1 AS seq
			, ('\n/* <sc-function> ' || n.nspname || '.' || p.proname || ' </sc-table> */\n')::VARCHAR(max) AS ddl
		FROM pg_proc p
		LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
		JOIN pg_language l ON p.prolang = l.oid
		WHERE p.proowner != 1
			AND l.lanname <> 'plpgsql'

		UNION ALL

		SELECT n.nspname AS schemaname
			, p.proname AS udfname
			, p.oid AS udfoid
			, 1000 AS seq
			, ('CREATE OR REPLACE FUNCTION ' || QUOTE_IDENT(n.nspname) || '.' || QUOTE_IDENT(p.proname) || ' \(')::VARCHAR(max) AS ddl
		FROM pg_proc p
		LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
		JOIN pg_language l ON p.prolang = l.oid
		WHERE p.proowner != 1
			AND l.lanname <> 'plpgsql'

		UNION ALL

		SELECT n.nspname AS schemaname
			, p.proname AS udfname
			, p.oid AS udfoid
			, 2000 + nvl(i, 0) AS seq
			, CASE
				WHEN i = 1
					THEN NVL(argument_name, '') || ' ' || format_type(argument_type, NULL)
				ELSE ',' || NVL(argument_name, '') || ' ' || format_type(argument_type, NULL)
				END AS ddl
		FROM pg_proc p
		LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
		LEFT JOIN arguments a ON a.oid = p.oid
		JOIN pg_language l ON p.prolang = l.oid
		WHERE p.proowner != 1
			AND l.lanname <> 'plpgsql'

		UNION ALL

		SELECT n.nspname AS schemaname
			, p.proname AS udfname
			, p.oid AS udfoid
			, 3000 AS seq
			, '\)' AS ddl
		FROM pg_proc p
		LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
		JOIN pg_language l ON p.prolang = l.oid
		WHERE p.proowner != 1
			AND l.lanname <> 'plpgsql'

		UNION ALL

		SELECT n.nspname AS schemaname
			, p.proname AS udfname
			, p.oid AS udfoid
			, 4000 AS seq
			, '  RETURNS ' || pg_catalog.format_type(p.prorettype, NULL) AS ddl
		FROM pg_proc p
		LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
		JOIN pg_language l ON p.prolang = l.oid
		WHERE p.proowner != 1
			AND l.lanname <> 'plpgsql'

		UNION ALL

		SELECT n.nspname AS schemaname
			, p.proname AS udfname
			, p.oid AS udfoid
			, 5000 AS seq
			, CASE
				WHEN p.provolatile = 'v'
					THEN 'VOLATILE'
				WHEN p.provolatile = 's'
					THEN 'STABLE'
				WHEN p.provolatile = 'i'
					THEN 'IMMUTABLE'
				ELSE ''
				END AS ddl
		FROM pg_proc p
		LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
		JOIN pg_language l ON p.prolang = l.oid
		WHERE p.proowner != 1
			AND l.lanname <> 'plpgsql'

		UNION ALL

		SELECT n.nspname AS schemaname
			, p.proname AS udfname
			, p.oid AS udfoid
			, 6000 AS seq
			, 'AS $$' AS ddl
		FROM pg_proc p
		LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
		JOIN pg_language l ON p.prolang = l.oid
		WHERE p.proowner != 1
			AND l.lanname <> 'plpgsql'

		UNION ALL

		SELECT n.nspname AS schemaname
			, p.proname AS udfname
			, p.oid AS udfoid
			, 7000 AS seq
			, p.prosrc AS DDL
		FROM pg_proc p
		LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
		JOIN pg_language l ON p.prolang = l.oid
		WHERE p.proowner != 1
			AND l.lanname <> 'plpgsql'

		UNION ALL

		SELECT n.nspname AS schemaname
			, p.proname AS udfname
			, p.oid AS udfoid
			, 8000 AS seq
			, '$$ LANGUAGE ' + lang.lanname + ';' AS ddl
		FROM pg_proc p
		LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
		LEFT JOIN (
			SELECT oid
				, lanname
			FROM pg_language
			) lang ON p.prolang = lang.oid
		WHERE p.proowner != 1
			AND lang.lanname <> 'plpgsql'
	)
	ORDER BY
		udfoid
		, seq
)
WHERE
{schema_filter}
;
