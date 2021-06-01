--DROP TABLE adventureworks2012_sales.specialoffer;
CREATE OR REPLACE TABLE  adventureworks2012_sales.specialoffer		--// CREATE TABLE 
(
	specialofferid INTEGER NOT NULL  IDENTITY(144607,1) 		--//  ENCODE az64
	,description VARCHAR(765) NOT NULL 		--//  ENCODE zstd
	,discountpct NUMERIC(10,4) NOT NULL DEFAULT 0.00		--//  ENCODE az64
	,"type" VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,category VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,startdate TIMESTAMP WITHOUT TIME ZONE NOT NULL 		--//  ENCODE az64
	,enddate TIMESTAMP WITHOUT TIME ZONE NOT NULL 		--//  ENCODE az64
	,minqty INTEGER NOT NULL DEFAULT 0		--//  ENCODE az64
	,maxqty INTEGER  		--//  ENCODE az64
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (specialofferid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (specialofferid)
;
