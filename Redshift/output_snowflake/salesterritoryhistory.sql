--DROP TABLE adventureworks2012_sales.salesterritoryhistory;
CREATE OR REPLACE TABLE  adventureworks2012_sales.salesterritoryhistory		--// CREATE TABLE 
(
	businessentityid INTEGER NOT NULL 		--//  ENCODE az64
	,territoryid INTEGER NOT NULL 		--//  ENCODE az64
	,startdate TIMESTAMP WITHOUT TIME ZONE NOT NULL 		--//  ENCODE az64
	,enddate TIMESTAMP WITHOUT TIME ZONE  		--//  ENCODE az64
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (businessentityid, startdate, territoryid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (businessentityid)
;
