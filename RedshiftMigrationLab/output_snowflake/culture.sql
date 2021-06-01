--DROP TABLE adventureworks2012_production.culture;
CREATE OR REPLACE TABLE  adventureworks2012_production.culture		--// CREATE TABLE 
(
	cultureid VARCHAR(18) NOT NULL 		--//  ENCODE lzo
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (cultureid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (cultureid)
;
