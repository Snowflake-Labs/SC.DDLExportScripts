--DROP TABLE adventureworks2012_production.productlistpricehistory;
CREATE OR REPLACE TABLE  adventureworks2012_production.productlistpricehistory		--// CREATE TABLE 
(
	productid INTEGER NOT NULL 		--//  ENCODE az64
	,startdate TIMESTAMP WITHOUT TIME ZONE NOT NULL 		--//  ENCODE az64
	,enddate TIMESTAMP WITHOUT TIME ZONE  		--//  ENCODE az64
	,listprice NUMERIC(19,4) NOT NULL 		--//  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (productid, startdate)
)
		--// DISTSTYLE KEY
		--// DISTKEY (productid)
;
