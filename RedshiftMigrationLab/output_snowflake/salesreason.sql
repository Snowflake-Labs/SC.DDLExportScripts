--DROP TABLE adventureworks2012_sales.salesreason;
CREATE OR REPLACE TABLE  adventureworks2012_sales.salesreason		--// CREATE TABLE 
(
	salesreasonid INTEGER NOT NULL  IDENTITY(144581,1) 		--//  ENCODE az64
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,reasontype VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (salesreasonid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (salesreasonid)
;
