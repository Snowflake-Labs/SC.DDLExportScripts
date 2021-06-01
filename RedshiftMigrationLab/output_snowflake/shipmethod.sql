--DROP TABLE adventureworks2012_purchasing.shipmethod;
CREATE OR REPLACE TABLE  adventureworks2012_purchasing.shipmethod		--// CREATE TABLE 
(
	shipmethodid INTEGER NOT NULL  IDENTITY(144520,1) 		--//  ENCODE az64
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,shipbase NUMERIC(19,4) NOT NULL DEFAULT 0.00		--//  ENCODE az64
	,shiprate NUMERIC(19,4) NOT NULL DEFAULT 0.00		--//  ENCODE az64
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (shipmethodid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (shipmethodid)
;
