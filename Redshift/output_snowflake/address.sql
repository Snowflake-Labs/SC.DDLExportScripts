--DROP TABLE adventureworks2012_person.address;
CREATE OR REPLACE TABLE  adventureworks2012_person.address		--// CREATE TABLE 
(
	addressid INTEGER NOT NULL  IDENTITY(144307,1) 		--//  ENCODE az64
	,addressline1 VARCHAR(180) NOT NULL 		--//  ENCODE zstd
	,addressline2 VARCHAR(180)  		--//  ENCODE zstd
	,city VARCHAR(90) NOT NULL 		--//  ENCODE zstd
	,stateprovinceid INTEGER NOT NULL 		--//  ENCODE RAW
	,postalcode VARCHAR(45) NOT NULL 		--//  ENCODE zstd
	,spatiallocation VARCHAR(10000)  		--//  ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (addressid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (addressid)
		--// SORTKEY ( 
		--// 	stateprovinceid
		--// 	)
		--// ;
