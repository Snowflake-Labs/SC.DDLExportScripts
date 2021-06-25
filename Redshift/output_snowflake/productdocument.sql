--DROP TABLE adventureworks2012_production.productdocument;
CREATE OR REPLACE TABLE  adventureworks2012_production.productdocument		--// CREATE TABLE 
(
	productid INTEGER NOT NULL 		--//  ENCODE az64
	,documentnode VARCHAR(3000) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (productid, documentnode)
)
		--// DISTSTYLE KEY
		--// DISTKEY (productid)
;
