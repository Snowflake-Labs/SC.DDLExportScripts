-- SQL to Extract Stored procedure DDL from Redshift for current database
-- Updated 5/25/2022 by Bob Maglies @ Snowflake
--    Added support for stored procedures longer than 64K
--    Changes are in
--       With clause: added body_source and body_source2 CTEs to make chunking of source code simplier
--       stored procedure body generation section is all new
--  Please note:
--      This code will place language and security options at end of generated code, even if original source had it at the top
--      SQL will prefix the create procedure object name with the source schema
--      Only the database that you are connected to will be processed
--      Some lines could be split differently than original source, but generated code will run the same

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
, body_source as (
      	-- Query to get the body definition
        SELECT
            n.nspname AS schemaname
            , p.proname AS proc_name
            , p.oid AS proc_oid
            , 4000 AS seq
            , P.prosrc AS prosrc
        FROM
            pg_proc p
            LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
            JOIN pg_proc_info pi ON pi.prooid = p.oid
            JOIN pg_language l ON p.prolang = l.oid
        WHERE
            p.proowner != 1
            AND pi.prokind = 'p'
)
, body_source2 as (
select schemaname, proc_name, proc_oid
, substr(prosrc,1,20000) as s_01
, substr(prosrc, 20001,20000) as s_02
, substr(prosrc, 40001,20000) as s_03
, substr(prosrc, 60001,20000) as s_04
, substr(prosrc, 80001,20000) as s_05
, substr(prosrc,100001,20000) as s_06
, substr(prosrc,120001,20000) as s_07
, substr(prosrc,140001,20000) as s_08
, substr(prosrc,160001,20000) as s_09
, substr(prosrc,180001,20000) as s_10
, substr(prosrc,200001,20000) as s_11
, substr(prosrc,220001,20000) as s_12
, substr(prosrc,240001,20000) as s_13
, substr(prosrc,260001,20000) as s_14
, substr(prosrc,280001,20000) as s_15
, substr(prosrc,300001,20000) as s_16
, substr(prosrc,320001,20000) as s_17
, substr(prosrc,340001,20000) as s_18
, substr(prosrc,360001,20000) as s_19
, substr(prosrc,380001,20000) as s_20
, substr(prosrc,400001,20000) as s_21
, substr(prosrc,420001,20000) as s_22
, substr(prosrc,440001,20000) as s_23
, substr(prosrc,460001,20000) as s_24
, substr(prosrc,480001,20000) as s_25
-- Extend 1

, reverse(s_01) as r_01
, reverse(s_02) as r_02
, reverse(s_03) as r_03
, reverse(s_04) as r_04
, reverse(s_05) as r_05
, reverse(s_06) as r_06
, reverse(s_07) as r_07
, reverse(s_08) as r_08
, reverse(s_09) as r_09
, reverse(s_10) as r_10
, reverse(s_11) as r_11
, reverse(s_12) as r_12
, reverse(s_13) as r_13
, reverse(s_14) as r_14
, reverse(s_15) as r_15
, reverse(s_16) as r_16
, reverse(s_17) as r_17
, reverse(s_18) as r_18
, reverse(s_19) as r_19
, reverse(s_20) as r_20
, reverse(s_21) as r_21
, reverse(s_22) as r_22
, reverse(s_23) as r_23
, reverse(s_24) as r_24
, reverse(s_25) as r_25
-- Extend 2

, len(s_01) as l_01
, len(s_02) as l_02
, len(s_03) as l_03
, len(s_04) as l_04
, len(s_05) as l_05
, len(s_06) as l_06
, len(s_07) as l_07
, len(s_08) as l_08
, len(s_09) as l_09
, len(s_10) as l_10
, len(s_11) as l_11
, len(s_12) as l_12
, len(s_13) as l_13
, len(s_14) as l_14
, len(s_15) as l_15
, len(s_16) as l_16
, len(s_17) as l_17
, len(s_18) as l_18
, len(s_19) as l_19
, len(s_20) as l_20
, len(s_21) as l_21
, len(s_22) as l_22
, len(s_23) as l_23
, len(s_24) as l_24
, len(s_25) as l_25
-- Extend 3

, len(prosrc)  as len_prosrc
       from body_source
)

SELECT
	ddl
FROM
(
  --select prosrc as ddl from body_source

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
            , ('\n/* <sc-procedure> ' || n.nspname || '.' || p.proname || ' </sc-procedure> */\n')::VARCHAR(65000) AS ddl
        FROM
            pg_proc p
            LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
            JOIN pg_proc_info pi ON pi.prooid = p.oid
            JOIN pg_language l ON p.prolang = l.oid
        WHERE
            p.proowner != 1
            AND pi.prokind = 'p'
    )

    UNION ALL

    -- Subquery to generate the CREATE OR REPLACE command
    SELECT
        n.nspname AS schemaname
        , p.proname AS proc_name
        , p.oid AS proc_oid
        , 2 AS seq
        , ('CREATE OR REPLACE PROCEDURE ' || n.nspname || '.' || p.proname || ' \(')::VARCHAR(65000) AS ddl
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
        , p.proname AS proc_name
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
        AND len(ddl) > 0

    UNION ALL

    -- Subquery to close the stored procedure parameters and start the body definition
    SELECT
        n.nspname AS schemaname
        , p.proname AS proc_name
        , p.oid AS proc_oid
        , 3000 AS seq
        , (') AS $$')::VARCHAR(65000) AS ddl
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
    -- Break lines on last space before boundry point
    -- Lines are broken at 20,000 to support multi byte characters, so that they fit into varchar(64000) for the output
    SELECT
        schemaname
        , proc_name
        , proc_oid
        , seq
        , ddl
    FROM
    (
        SELECT schemaname, proc_name, proc_oid, 4001 as seq
            , position(' ' in r_01) as last_space
            , 0 as prior_last_space
            , '' as prior_end_str
            , prior_end_str || substr(s_01,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2
        UNION ALL
        select schemaname, proc_name, proc_oid, 4002 as seq
            , position(' ' in r_02) as last_space
            , position(' ' in r_01) as prior_last_space
            , substr(s_01,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_02,1,20001 - last_space)::varchar(64000) as ddl
            from body_source2 where l_02 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4003 as seq
            , position(' ' in r_03) as last_space
            , position(' ' in r_02) as prior_last_space
            , substr(s_02,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_03,1,20001 - last_space - 1)::varchar(64000) as ddl
            from body_source2 where l_03 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4004 as seq
            , position(' ' in r_04) as last_space
            , position(' ' in r_03) as prior_last_space
            , substr(s_03,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_04,1,20001 - last_space)::varchar(64000) as ddl
            from body_source2 where l_04 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4005 as seq
            , position(' ' in r_05) as last_space
            , position(' ' in r_04) as prior_last_space
            , substr(s_04,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_05,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_05 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4006 as seq
            , position(' ' in r_06) as last_space
            , position(' ' in r_05) as prior_last_space
            , substr(s_05,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_06,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_06 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4007 as seq
            , position(' ' in r_07) as last_space
            , position(' ' in r_06) as prior_last_space
            , substr(s_06,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_07,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_07 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4008 as seq
            , position(' ' in r_08) as last_space
            , position(' ' in r_07) as prior_last_space
            , substr(s_07,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_08,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_08 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4009 as seq
            , position(' ' in r_09) as last_space
            , position(' ' in r_08) as prior_last_space
            , substr(s_08,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_09,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_09 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4010 as seq
            , position(' ' in r_10) as last_space
            , position(' ' in r_09) as prior_last_space
            , substr(s_09,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_10,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_10 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4011 as seq
            , position(' ' in r_11) as last_space
            , position(' ' in r_10) as prior_last_space
            , substr(s_10,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_11,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_11 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4012 as seq
            , position(' ' in r_12) as last_space
            , position(' ' in r_11) as prior_last_space
            , substr(s_11,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_12,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_12 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4013 as seq
            , position(' ' in r_13) as last_space
            , position(' ' in r_12) as prior_last_space
            , substr(s_12,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_13,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_13 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4014 as seq
            , position(' ' in r_14) as last_space
            , position(' ' in r_13) as prior_last_space
            , substr(s_13,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_14,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_14 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4015 as seq
            , position(' ' in r_15) as last_space
            , position(' ' in r_14) as prior_last_space
            , substr(s_14,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_15,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_15 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4016 as seq
            , position(' ' in r_16) as last_space
            , position(' ' in r_15) as prior_last_space
            , substr(s_15,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_16,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_16 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4017 as seq
            , position(' ' in r_17) as last_space
            , position(' ' in r_16) as prior_last_space
            , substr(s_16,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_17,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_17 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4018 as seq
            , position(' ' in r_18) as last_space
            , position(' ' in r_17) as prior_last_space
            , substr(s_17,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_18,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_18 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4019 as seq
            , position(' ' in r_19) as last_space
            , position(' ' in r_18) as prior_last_space
            , substr(s_18,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_19,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_19 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4020 as seq
            , position(' ' in r_20) as last_space
            , position(' ' in r_19) as prior_last_space
            , substr(s_19,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_20,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_20 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4021 as seq
            , position(' ' in r_21) as last_space
            , position(' ' in r_20) as prior_last_space
            , substr(s_20,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_21,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_21 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4022 as seq
            , position(' ' in r_22) as last_space
            , position(' ' in r_21) as prior_last_space
            , substr(s_21,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_22,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_22 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4023 as seq
            , position(' ' in r_23) as last_space
            , position(' ' in r_22) as prior_last_space
            , substr(s_22,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_23,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_23 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4024 as seq
            , position(' ' in r_24) as last_space
            , position(' ' in r_23) as prior_last_space
            , substr(s_23,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_24,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_24 > 0
        UNION ALL
        select schemaname, proc_name, proc_oid, 4025 as seq
            , position(' ' in r_25) as last_space
            , position(' ' in r_24) as prior_last_space
            , substr(s_24,20001 - prior_last_space,prior_last_space)::varchar(64000) as prior_end_str
            , prior_end_str || substr(s_25,1,20001 - last_space)::varchar(64000) as ddl
           from body_source2 where l_25 > 0
        -- Extend 4
        UNION ALL
            select schemaname, proc_name, proc_oid, 4999 as seq
                , 0 as last_space
                , 0 as prior_last_space
                , '' as prior_end_str
                , 'CODE GENERATION ERROR source body text is ' || len_prosrc || ' characters long, which exceeds max of this extractor (500,000). Please update extractor to process longer lines' as ddl
                from body_source2 where len_prosrc > 500000
       )

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
WHERE
    {schema_filter}
    -- For manual runs, remove the above line and replace with something like this:
    -- Example:
    -- lower(schemaname) LIKE '%'
ORDER BY proc_oid, seq
;
