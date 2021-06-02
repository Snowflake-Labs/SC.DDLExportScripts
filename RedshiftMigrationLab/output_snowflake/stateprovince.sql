--DROP TABLE adventureworks2012_person.stateprovince;
CREATE OR REPLACE TABLE  adventureworks2012_person.stateprovince		--// CREATE TABLE 
(
	stateprovinceid INTEGER NOT NULL  IDENTITY(144351,1) 		--//  ENCODE az64
	,stateprovincecode VARCHAR(9) NOT NULL 		--//  ENCODE zstd
	,countryregioncode VARCHAR(9) NOT NULL 		--//  ENCODE zstd
	,isonlystateprovinceflag BOOLEAN NOT NULL DEFAULT  TRUE		--// BOOLEAN
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,territoryid INTEGER NOT NULL 		--//  ENCODE az64
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (stateprovinceid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (stateprovinceid)
;
