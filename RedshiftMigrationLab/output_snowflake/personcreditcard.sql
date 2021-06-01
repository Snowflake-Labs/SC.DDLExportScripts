--DROP TABLE adventureworks2012_sales.personcreditcard;
CREATE OR REPLACE TABLE  adventureworks2012_sales.personcreditcard		--// CREATE TABLE 
(
	businessentityid INTEGER NOT NULL 		--//  ENCODE az64
	,creditcardid INTEGER NOT NULL 		--//  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (businessentityid, creditcardid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (businessentityid)
;
