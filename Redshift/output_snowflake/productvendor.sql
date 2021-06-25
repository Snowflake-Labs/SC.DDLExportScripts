--DROP TABLE adventureworks2012_purchasing.productvendor;
CREATE OR REPLACE TABLE  adventureworks2012_purchasing.productvendor		--// CREATE TABLE 
(
	productid INTEGER NOT NULL 		--//  ENCODE az64
	,businessentityid INTEGER NOT NULL 		--//  ENCODE RAW
	,averageleadtime INTEGER NOT NULL 		--//  ENCODE az64
	,standardprice NUMERIC(19,4) NOT NULL 		--//  ENCODE az64
	,lastreceiptcost NUMERIC(19,4)  		--//  ENCODE az64
	,lastreceiptdate TIMESTAMP WITHOUT TIME ZONE  		--//  ENCODE az64
	,minorderqty INTEGER NOT NULL 		--//  ENCODE az64
	,maxorderqty INTEGER NOT NULL 		--//  ENCODE az64
	,onorderqty INTEGER  		--//  ENCODE az64
	,unitmeasurecode VARCHAR(9) NOT NULL 		--//  ENCODE RAW
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (productid, businessentityid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (productid)
		--// SORTKEY ( 
		--// 	unitmeasurecode
		--// 	, businessentityid
		--// 	)
		--// ;
