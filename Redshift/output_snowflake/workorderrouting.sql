--DROP TABLE adventureworks2012_production.workorderrouting;
CREATE OR REPLACE TABLE  adventureworks2012_production.workorderrouting		--// CREATE TABLE 
(
	workorderid INTEGER NOT NULL 		--//  ENCODE az64
	,productid INTEGER NOT NULL 		--//  ENCODE RAW
	,operationsequence SMALLINT NOT NULL 		--//  ENCODE az64
	,locationid SMALLINT NOT NULL 		--//  ENCODE az64
	,scheduledstartdate TIMESTAMP WITHOUT TIME ZONE NOT NULL 		--//  ENCODE az64
	,scheduledenddate TIMESTAMP WITHOUT TIME ZONE NOT NULL 		--//  ENCODE az64
	,actualstartdate TIMESTAMP WITHOUT TIME ZONE  		--//  ENCODE az64
	,actualenddate TIMESTAMP WITHOUT TIME ZONE  		--//  ENCODE az64
	,actualresourcehrs NUMERIC(9,4)  		--//  ENCODE az64
	,plannedcost NUMERIC(19,4) NOT NULL 		--//  ENCODE az64
	,actualcost NUMERIC(19,4)  		--//  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (workorderid, productid, operationsequence)
)
		--// DISTSTYLE KEY
		--// DISTKEY (workorderid)
		--// SORTKEY ( 
		--// 	productid
		--// 	)
		--// ;
