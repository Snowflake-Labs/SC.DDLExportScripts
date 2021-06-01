--DROP TABLE adventureworks2012_production.productmodelproductdescriptionculture;
CREATE OR REPLACE TABLE  adventureworks2012_production.productmodelproductdescriptionculture		--// CREATE TABLE 
(
	productmodelid INTEGER NOT NULL 		--//  ENCODE az64
	,productdescriptionid INTEGER NOT NULL 		--//  ENCODE az64
	,cultureid VARCHAR(18) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (productmodelid, productdescriptionid, cultureid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (productmodelid)
;
