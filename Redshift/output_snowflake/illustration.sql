--DROP TABLE adventureworks2012_production.illustration;
CREATE OR REPLACE TABLE  adventureworks2012_production.illustration		--// CREATE TABLE 
(
	illustrationid INTEGER NOT NULL  IDENTITY(144370,1) 		--//  ENCODE az64
	,diagram VARCHAR(1300)  		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (illustrationid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (illustrationid)
;
