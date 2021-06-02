--DROP TABLE adventureworks2012_purchasing.vendor;
CREATE OR REPLACE TABLE  adventureworks2012_purchasing.vendor		--// CREATE TABLE 
(
	businessentityid INTEGER NOT NULL 		--//  ENCODE az64
	,accountnumber VARCHAR(45) NOT NULL 		--//  ENCODE zstd
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,creditrating SMALLINT NOT NULL 		--//  ENCODE az64
	,preferredvendorstatus BOOLEAN NOT NULL DEFAULT  TRUE		--// BOOLEAN
	,activeflag BOOLEAN NOT NULL DEFAULT  TRUE		--// BOOLEAN
	,purchasingwebserviceurl VARCHAR(3072)  		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (businessentityid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (businessentityid)
;
