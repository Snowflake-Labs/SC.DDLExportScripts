--DROP TABLE adventureworks2012_production.productproductphoto;
CREATE OR REPLACE TABLE  adventureworks2012_production.productproductphoto		--// CREATE TABLE 
(
	productid INTEGER NOT NULL 		--//  ENCODE az64
	,productphotoid INTEGER NOT NULL 		--//  ENCODE az64
	,"primary" BOOLEAN NOT NULL DEFAULT 0		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (productid, productphotoid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (productid)
;
