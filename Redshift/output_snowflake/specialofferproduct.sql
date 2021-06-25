--DROP TABLE adventureworks2012_sales.specialofferproduct;
CREATE OR REPLACE TABLE  adventureworks2012_sales.specialofferproduct		--// CREATE TABLE 
(
	specialofferid INTEGER NOT NULL 		--//  ENCODE az64
	,productid INTEGER NOT NULL 		--//  ENCODE RAW
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (specialofferid, productid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (specialofferid)
		--// SORTKEY ( 
		--// 	productid
		--// 	)
		--// ;
