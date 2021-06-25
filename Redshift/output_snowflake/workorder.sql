--DROP TABLE adventureworks2012_production.workorder;
CREATE OR REPLACE TABLE  adventureworks2012_production.workorder		--// CREATE TABLE 
(
	workorderid INTEGER NOT NULL  IDENTITY(144496,1) 		--//  ENCODE az64
	,productid INTEGER NOT NULL 		--//  ENCODE RAW
	,orderqty INTEGER NOT NULL 		--//  ENCODE az64
	,stockedqty INTEGER NOT NULL 		--//  ENCODE az64
	,scrappedqty SMALLINT NOT NULL 		--//  ENCODE az64
	,startdate TIMESTAMP WITHOUT TIME ZONE NOT NULL 		--//  ENCODE az64
	,enddate TIMESTAMP WITHOUT TIME ZONE  		--//  ENCODE az64
	,duedate TIMESTAMP WITHOUT TIME ZONE NOT NULL 		--//  ENCODE az64
	,scrapreasonid SMALLINT  		--//  ENCODE RAW
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (workorderid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (workorderid)
		--// SORTKEY ( 
		--// 	scrapreasonid
		--// 	, productid
		--// 	)
		--// ;
