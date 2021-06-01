--DROP TABLE adventureworks2012_production.productdescription;
CREATE OR REPLACE TABLE  adventureworks2012_production.productdescription		--// CREATE TABLE 
(
	productdescriptionid INTEGER NOT NULL  IDENTITY(144441,1) 		--//  ENCODE az64
	,description VARCHAR(1200) NOT NULL 		--//  ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (productdescriptionid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (productdescriptionid)
;
