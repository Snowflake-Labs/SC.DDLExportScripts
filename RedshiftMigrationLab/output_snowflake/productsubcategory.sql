--DROP TABLE adventureworks2012_production.productsubcategory;
CREATE OR REPLACE TABLE  adventureworks2012_production.productsubcategory		--// CREATE TABLE 
(
	productsubcategoryid INTEGER NOT NULL  IDENTITY(144478,1) 		--//  ENCODE az64
	,productcategoryid INTEGER NOT NULL 		--//  ENCODE az64
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (productsubcategoryid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (productsubcategoryid)
;
