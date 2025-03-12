SELECT
    ddl
FROM (
	SELECT table_id
		, REGEXP_REPLACE(schemaname, '^zzzzzzzz', '') AS schemaname
		, REGEXP_REPLACE(tablename, '^zzzzzzzz', '') AS tablename
		, seq
		, ddl
	FROM
	(
		SELECT table_id
			, schemaname
			, tablename
			, seq
			, ddl
		FROM (
			-- SNOWCONVERT OBJECT HEADER
			SELECT c.oid::BIGINT AS table_id
				, n.nspname AS schemaname
				, c.relname AS tablename
				, 0 AS seq
				, '\n/* <sc-table> ' + n.nspname + '.' + c.relname + ' </sc-table> */\n' AS ddl
			FROM pg_namespace AS n
			INNER JOIN pg_class AS c ON n.oid = c.relnamespace
			WHERE c.relkind = 'r'

			--CREATE TABLE

			UNION

			SELECT c.oid::BIGINT AS table_id
				, n.nspname AS schemaname
				, c.relname AS tablename
				, 2 AS seq
				, 'CREATE TABLE IF NOT EXISTS ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relname) + '' AS ddl
			FROM pg_namespace AS n
			INNER JOIN pg_class AS c ON n.oid = c.relnamespace
			WHERE c.relkind = 'r'
			--OPEN PAREN COLUMN LIST

			UNION

			SELECT c.oid::BIGINT AS table_id
				, n.nspname AS schemaname
				, c.relname AS tablename
				, 5 AS seq
				, '(' AS ddl
			FROM pg_namespace AS n
			INNER JOIN pg_class AS c ON n.oid = c.relnamespace
			WHERE c.relkind = 'r'
			--COLUMN LIST

			UNION

			SELECT table_id
				, schemaname
				, tablename
				, seq
				, '\t' + col_delim + col_name + ' ' + col_datatype + ' ' + col_nullable + ' ' + col_default AS ddl
			FROM (
				SELECT c.oid::BIGINT AS table_id
					, n.nspname AS schemaname
					, c.relname AS tablename
					, 100000000 + a.attnum AS seq
					, CASE
						WHEN a.attnum > 1
							THEN ','
						ELSE ''
						END AS col_delim
					, QUOTE_IDENT(a.attname) AS col_name
					, CASE
						WHEN STRPOS(UPPER(format_type(a.atttypid, a.atttypmod)), 'CHARACTER VARYING') > 0
							THEN REPLACE(UPPER(format_type(a.atttypid, a.atttypmod)), 'CHARACTER VARYING', 'VARCHAR')
						WHEN STRPOS(UPPER(format_type(a.atttypid, a.atttypmod)), 'CHARACTER') > 0
							THEN REPLACE(UPPER(format_type(a.atttypid, a.atttypmod)), 'CHARACTER', 'CHAR')
						ELSE UPPER(format_type(a.atttypid, a.atttypmod))
						END AS col_datatype
					, CASE
						WHEN a.atthasdef IS TRUE
							THEN 'DEFAULT ' + adef.adsrc
						ELSE ''
						END AS col_default
					, CASE
						WHEN a.attnotnull IS TRUE
							THEN 'NOT NULL'
						ELSE ''
						END AS col_nullable
				FROM pg_namespace AS n
				INNER JOIN pg_class AS c ON n.oid = c.relnamespace
				INNER JOIN pg_attribute AS a ON c.oid = a.attrelid
				LEFT OUTER JOIN pg_attrdef AS adef ON a.attrelid = adef.adrelid
					AND a.attnum = adef.adnum
				WHERE c.relkind = 'r'
					AND a.attnum > 0
				ORDER BY a.attnum
				)
			--CONSTRAINT LIST

			UNION

			(
				SELECT c.oid::BIGINT AS table_id
					, n.nspname AS schemaname
					, c.relname AS tablename
					, 200000000 + CAST(con.oid AS INT) AS seq
					, '\t,' + pg_get_constraintdef(con.oid) AS ddl
				FROM pg_constraint AS con
				INNER JOIN pg_class AS c ON c.relnamespace = con.connamespace
					AND c.oid = con.conrelid
				INNER JOIN pg_namespace AS n ON n.oid = c.relnamespace
				WHERE c.relkind = 'r'
					AND pg_get_constraintdef(con.oid) NOT LIKE 'FOREIGN KEY%'
				ORDER BY seq
				)
			--CLOSE PAREN COLUMN LIST

			UNION

			SELECT c.oid::BIGINT AS table_id
				, n.nspname AS schemaname
				, c.relname AS tablename
				, 299999999 AS seq
				, ')' AS ddl
			FROM pg_namespace AS n
			INNER JOIN pg_class AS c ON n.oid = c.relnamespace
			WHERE c.relkind = 'r'
			--SORTKEY COLUMNS

			UNION

			SELECT table_id
				, schemaname
				, tablename
				, seq
				, CASE
					WHEN min_sort < 0
						THEN 'INTERLEAVED SORTKEY ('
					ELSE ' SORTKEY ('
					END AS ddl
			FROM (
				SELECT c.oid::BIGINT AS table_id
					, n.nspname AS schemaname
					, c.relname AS tablename
					, 499999999 AS seq
					, min(attsortkeyord) min_sort
				FROM pg_namespace AS n
				INNER JOIN pg_class AS c ON n.oid = c.relnamespace
				INNER JOIN pg_attribute AS a ON c.oid = a.attrelid
				WHERE c.relkind = 'r'
					AND abs(a.attsortkeyord) > 0
					AND a.attnum > 0
				GROUP BY 1
					, 2
					, 3
					, 4
				)

			UNION

			(
				SELECT c.oid::BIGINT AS table_id
					, n.nspname AS schemaname
					, c.relname AS tablename
					, 500000000 + abs(a.attsortkeyord) AS seq
					, CASE
						WHEN abs(a.attsortkeyord) = 1
							THEN '\t' + QUOTE_IDENT(a.attname)
						ELSE '\t, ' + QUOTE_IDENT(a.attname)
						END AS ddl
				FROM pg_namespace AS n
				INNER JOIN pg_class AS c ON n.oid = c.relnamespace
				INNER JOIN pg_attribute AS a ON c.oid = a.attrelid
				WHERE c.relkind = 'r'
					AND abs(a.attsortkeyord) > 0
					AND a.attnum > 0
				ORDER BY abs(a.attsortkeyord)
				)

			UNION

			SELECT c.oid::BIGINT AS table_id
				, n.nspname AS schemaname
				, c.relname AS tablename
				, 599999999 AS seq
				, '\t)' AS ddl
			FROM pg_namespace AS n
			INNER JOIN pg_class AS c ON n.oid = c.relnamespace
			INNER JOIN pg_attribute AS a ON c.oid = a.attrelid
			WHERE c.relkind = 'r'
				AND abs(a.attsortkeyord) > 0
				AND a.attnum > 0
			--END SEMICOLON

			UNION

			SELECT c.oid::BIGINT AS table_id
				, n.nspname AS schemaname
				, c.relname AS tablename
				, 600000000 AS seq
				, ';' AS ddl
			FROM pg_namespace AS n
			INNER JOIN pg_class AS c ON n.oid = c.relnamespace
			WHERE c.relkind = 'r'
			)
		--COMMENT
		UNION

		SELECT c.oid::BIGINT AS table_id
			, n.nspname AS schemaname
			, c.relname AS tablename
			, 600250000 AS seq
			, ('COMMENT ON '::text + nvl2(cl.column_name, 'column '::text, 'table '::text)
				+ quote_ident(n.nspname::text)
				+ '.'::text
				+ quote_ident(c.relname::text)
				+ nvl2(cl.column_name, '.'::text
				+ cl.column_name::text, ''::text)
				+ ' IS '::text
				+ quote_literal(des.description)
			    + ';'::text)::character VARYING
			AS ddl
		FROM pg_description des
		JOIN pg_class c ON c.oid = des.objoid
		JOIN pg_namespace n ON n.oid = c.relnamespace
		LEFT JOIN information_schema.columns cl ON cl.ordinal_position::INTEGER = des.objsubid
			AND cl.table_name::NAME = c.relname
		WHERE c.relkind = 'r'


		UNION

		(
			SELECT c.oid::BIGINT AS table_id
				, 'zzzzzzzz' || n.nspname AS schemaname
				, 'zzzzzzzz' || c.relname AS tablename
				, 700000000 + CAST(con.oid AS INT) AS seq
				, 'ALTER TABLE ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relname) + ' ADD ' + pg_get_constraintdef(con.oid)::VARCHAR(1024) + ';' AS ddl
			FROM pg_constraint AS con
			INNER JOIN pg_class AS c ON c.relnamespace = con.connamespace
				AND c.oid = con.conrelid
			INNER JOIN pg_namespace AS n ON n.oid = c.relnamespace
			WHERE c.relkind = 'r'
				AND con.contype = 'f'
			ORDER BY seq
		)

		ORDER BY table_id
			, schemaname
			, tablename
			, seq
    )
    WHERE
      	schemaname not in ('information_schema', 'pg_catalog', 'pg_internal')
)
WHERE
    {schema_filter}
    -- For manual runs, remove the above line and replace with something like this:
    -- Example:
    -- lower(schemaname) LIKE '%'
;
