--DROP TABLE adventureworks2012_person."password";
CREATE OR REPLACE TABLE  adventureworks2012_person."password"		--// CREATE TABLE 
(
	businessentityid INTEGER NOT NULL 		--//  ENCODE az64
	,passwordhash VARCHAR(384) NOT NULL 		--//  ENCODE zstd
	,passwordsalt VARCHAR(30) NOT NULL 		--//  ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (businessentityid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (businessentityid)
;
