--DROP TABLE adventureworks2012_sales.salesorderheadersalesreason;
CREATE OR REPLACE TABLE  adventureworks2012_sales.salesorderheadersalesreason		--// CREATE TABLE 
(
	salesorderid INTEGER NOT NULL 		--//  ENCODE az64
	,salesreasonid INTEGER NOT NULL 		--//  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (salesorderid, salesreasonid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (salesorderid)
;
