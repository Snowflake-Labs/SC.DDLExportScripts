--DROP TABLE adventureworks2012_production.transactionhistory;
CREATE OR REPLACE TABLE  adventureworks2012_production.transactionhistory		--// CREATE TABLE 
(
	transactionid INTEGER NOT NULL  IDENTITY(144482,1) 		--//  ENCODE az64
	,productid INTEGER NOT NULL 		--//  ENCODE RAW
	,referenceorderid INTEGER NOT NULL 		--//  ENCODE RAW
	,referenceorderlineid INTEGER NOT NULL DEFAULT 0		--//  ENCODE RAW
	,transactiondate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
	,transactiontype VARCHAR(3) NOT NULL 		--//  ENCODE zstd
	,quantity INTEGER NOT NULL 		--//  ENCODE az64
	,actualcost NUMERIC(19,4) NOT NULL 		--//  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (transactionid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (transactionid)
		--// SORTKEY ( 
		--// 	productid
		--// 	, referenceorderid
		--// 	, referenceorderlineid
		--// 	)
		--// ;
