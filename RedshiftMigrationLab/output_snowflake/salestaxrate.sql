--DROP TABLE adventureworks2012_sales.salestaxrate;
CREATE OR REPLACE TABLE  adventureworks2012_sales.salestaxrate		--// CREATE TABLE 
(
	salestaxrateid INTEGER NOT NULL  IDENTITY(144585,1) 		--//  ENCODE az64
	,stateprovinceid INTEGER NOT NULL 		--//  ENCODE az64
	,taxtype SMALLINT NOT NULL 		--//  ENCODE az64
	,taxrate NUMERIC(10,4) NOT NULL DEFAULT 0.00		--//  ENCODE az64
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (salestaxrateid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (salestaxrateid)
;
