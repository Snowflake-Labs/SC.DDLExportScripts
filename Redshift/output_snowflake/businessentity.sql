--DROP TABLE adventureworks2012_person.businessentity;
CREATE OR REPLACE TABLE  adventureworks2012_person.businessentity		--// CREATE TABLE 
(
	businessentityid INTEGER NOT NULL  IDENTITY(144315,1) 		--//  ENCODE az64
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (businessentityid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (businessentityid)
;
