--DROP TABLE adventureworks2012_humanresources.employeepayhistory;
CREATE OR REPLACE TABLE  adventureworks2012_humanresources.employeepayhistory		--// CREATE TABLE 
(
	businessentityid INTEGER NOT NULL 		--//  ENCODE az64
	,ratechangedate TIMESTAMP WITHOUT TIME ZONE NOT NULL 		--//  ENCODE az64
	,rate NUMERIC(19,4) NOT NULL 		--//  ENCODE az64
	,payfrequency SMALLINT NOT NULL 		--//  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (businessentityid, ratechangedate)
)
		--// DISTSTYLE KEY
		--// DISTKEY (businessentityid)
;
