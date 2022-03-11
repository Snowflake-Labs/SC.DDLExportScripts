WITH arguments AS
(
  	-- Query to get arguments for all procedures
    SELECT
	    oid
		, i
		, arg_name [i] AS argument_name
        , CASE
        	WHEN lower(arg_mode [i]) = 'i' THEN 'IN'
            WHEN lower(arg_mode [i]) = 'b' THEN 'INOUT'
            WHEN lower(arg_mode [i]) = 'o' THEN 'OUT'
  			ELSE 'IN'
        END AS argument_mode
  		, COALESCE(out_types[i], CASE WHEN arg_types [i-1] = 0 THEN NULL ELSE arg_types [i-1] END) argument_type
	FROM (
		SELECT
      		-- Generating a series of 64 possible parameters, that's the maximum parameters
      		-- according to this link https://docs.aws.amazon.com/redshift/latest/dg/stored-procedure-constraints.html
		    generate_series(1, 64) AS i
			, arg_name
			, arg_types
			, oid
      		, arg_mode
      		, out_types
		FROM (
			SELECT
			    prooid 			 AS oid
				, proargnames    AS arg_name
				, proargtypes 	 AS arg_types
          		, proargmodes 	 AS arg_mode
          		, proallargtypes AS out_types
			FROM
			    pg_proc_info
			WHERE
			    proowner != 1
          		and prokind = 'p'
		) t
	) t
  	where
  		COALESCE(out_types[i], CASE WHEN arg_types [i-1] = 0 THEN NULL ELSE arg_types [i-1] END) is not null
)
SELECT
	ddl
FROM
(
    SELECT
        *
    FROM
    (
      	-- Subquery to generate the sc-procedure header
        SELECT
            n.nspname AS schemaname
            , p.proname AS proc_name
            , p.oid AS proc_oid
            , 1 AS seq
            , ('\n/* <sc-procedure> ' || n.nspname || '.' || p.proname || ' </sc-procedure> */\n')::VARCHAR(max) AS ddl
        FROM
            pg_proc p
            LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
            JOIN pg_proc_info pi ON pi.prooid = p.oid
            JOIN pg_language l ON p.prolang = l.oid
        WHERE
            p.proowner != 1
            AND pi.prokind = 'p'

        UNION ALL

      	-- Subquery to generate the CREATE OR REPLACE command
        SELECT
            n.nspname AS schemaname
            , p.proname AS proc_name
            , p.oid AS proc_oid
            , 2 AS seq
            , ('CREATE OR REPLACE PROCEDURE ' || n.nspname || '.' || p.proname || ' \(')::VARCHAR(max) AS ddl
        FROM
            pg_proc p
            LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
            JOIN pg_proc_info pi ON pi.prooid = p.oid
            JOIN pg_language l ON p.prolang = l.oid
        WHERE
            p.proowner != 1
            AND pi.prokind = 'p'

        UNION ALL

      	-- Subquery to generate the stored procedure arguments
        SELECT
            n.nspname AS schemaname
            , p.proname AS udfname
            , p.oid AS udfoid
            , 2000 + nvl(i, 0) AS seq
            , COALESCE(CASE
                WHEN i = 1 THEN
              		        NVL(argument_name, '') || ' ' || NVL(argument_mode, '') || ' ' || format_type(argument_type, NULL)
                ELSE ',' || NVL(argument_name, '') || ' ' || NVL(argument_mode, '') || ' ' || format_type(argument_type, NULL)
            END, '') AS ddl
        FROM
            pg_proc p
            LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
            LEFT JOIN arguments a ON a.oid = p.oid
            JOIN pg_proc_info pi ON pi.prooid = p.oid
            JOIN pg_language l ON p.prolang = l.oid
        WHERE
            p.proowner != 1
            AND pi.prokind = 'p'

        UNION ALL

      	-- Subquery to close the stored procedure parameters and start the body definition
        SELECT
            n.nspname AS schemaname
            , p.proname AS proc_name
            , p.oid AS proc_oid
            , 3000 AS seq
            , (') AS $$')::VARCHAR(max) AS ddl
        FROM
            pg_proc p
            LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
            JOIN pg_proc_info pi ON pi.prooid = p.oid
            JOIN pg_language l ON p.prolang = l.oid
        WHERE
            p.proowner != 1
            AND pi.prokind = 'p'

        UNION ALL

      	-- Query to get the body definition
        SELECT
            n.nspname AS schemaname
            , p.proname AS proc_name
            , p.oid AS proc_oid
            , 4000 AS seq
            , P.prosrc AS ddl
        FROM
            pg_proc p
            LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
            JOIN pg_proc_info pi ON pi.prooid = p.oid
            JOIN pg_language l ON p.prolang = l.oid
        WHERE
            p.proowner != 1
            AND pi.prokind = 'p'

        UNION ALL

      	-- Query to get the language and security definitions
        SELECT
            n.nspname AS schemaname
            , p.proname AS proc_name
            , p.oid AS proc_oid
            , 6000 AS seq
            , '$$ LANGUAGE ' + l.lanname + '\n SECURITY ' + CASE WHEN p.prosecdef = true THEN 'DEFINER' ELSE 'INVOKER' END + ';' AS ddl
        FROM
            pg_proc p
            LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
            JOIN pg_proc_info pi ON pi.prooid = p.oid
            JOIN pg_language l ON p.prolang = l.oid
        WHERE
            p.proowner != 1
            AND pi.prokind = 'p'
    )
    ORDER BY proc_oid, seq
)
WHERE
    {schema_filter}
    -- For manual runs, remove the above line and replace with something like this:
    -- Example:
    -- lower(schemaname) LIKE '%'
;