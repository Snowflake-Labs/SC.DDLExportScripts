--DROP TABLE adventureworks2012_sales.salesperson;
CREATE OR REPLACE TABLE  adventureworks2012_sales.salesperson		--// CREATE TABLE 
(
	businessentityid INTEGER NOT NULL 		--//  ENCODE az64
	,territoryid INTEGER  		--//  ENCODE az64
	,salesquota NUMERIC(19,4)  		--//  ENCODE az64
	,bonus NUMERIC(19,4) NOT NULL DEFAULT 0.00		--//  ENCODE az64
	,commissionpct NUMERIC(10,4) NOT NULL DEFAULT 0.00		--//  ENCODE az64
	,salesytd NUMERIC(19,4) NOT NULL DEFAULT 0.00		--//  ENCODE az64
	,saleslastyear NUMERIC(19,4) NOT NULL DEFAULT 0.00		--//  ENCODE az64
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (businessentityid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (businessentityid)
;
