--DROP TABLE adventureworks2012_sales.customer;
CREATE OR REPLACE TABLE  adventureworks2012_sales.customer		--// CREATE TABLE 
(
	customerid INTEGER NOT NULL  IDENTITY(144545,1) 		--//  ENCODE az64
	,personid INTEGER  		--//  ENCODE az64
	,storeid INTEGER  		--//  ENCODE az64
	,territoryid INTEGER  		--//  ENCODE RAW
	,accountnumber VARCHAR(30) NOT NULL 		--//  ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (customerid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (customerid)
		--// SORTKEY ( 
		--// 	territoryid
		--// 	)
		--// ;
