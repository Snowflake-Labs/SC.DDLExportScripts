--DROP TABLE adventureworks2012_person.addresstype;
CREATE OR REPLACE TABLE  adventureworks2012_person.addresstype		--// CREATE TABLE 
(
	addresstypeid INTEGER NOT NULL  IDENTITY(144311,1) 		--//  ENCODE az64
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (addresstypeid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (addresstypeid)
;
