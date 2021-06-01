--DROP TABLE adventureworks2012_humanresources.employeedepartmenthistory;
CREATE OR REPLACE TABLE  adventureworks2012_humanresources.employeedepartmenthistory		--// CREATE TABLE 
(
	businessentityid INTEGER NOT NULL 		--//  ENCODE az64
	,departmentid SMALLINT NOT NULL 		--//  ENCODE RAW
	,shiftid SMALLINT NOT NULL 		--//  ENCODE RAW
	,startdate DATE NOT NULL 		--//  ENCODE az64
	,enddate DATE  		--//  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (businessentityid, startdate, departmentid, shiftid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (businessentityid)
		--// SORTKEY ( 
		--// 	departmentid
		--// 	, shiftid
		--// 	)
		--// ;
