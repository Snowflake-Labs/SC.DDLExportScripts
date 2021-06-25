--DROP TABLE adventureworks2012_production.productmodel;
CREATE OR REPLACE TABLE  adventureworks2012_production.productmodel		--// CREATE TABLE 
(
	productmodelid INTEGER NOT NULL  IDENTITY(144455,1) 		--//  ENCODE az64
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,catalogdescription VARCHAR(1300)  		--//  ENCODE zstd
	,instructions VARCHAR(1300)  		--//  ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (productmodelid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (productmodelid)
;
