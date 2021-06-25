--DROP TABLE adventureworks2012_humanresources.employeedepartmenthistory;
CREATE TABLE IF NOT EXISTS adventureworks2012_humanresources.employeedepartmenthistory
(
	businessentityid INTEGER NOT NULL  ENCODE az64
	,departmentid SMALLINT NOT NULL  ENCODE RAW
	,shiftid SMALLINT NOT NULL  ENCODE RAW
	,startdate DATE NOT NULL  ENCODE az64
	,enddate DATE   ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (businessentityid, startdate, departmentid, shiftid)
)
DISTSTYLE KEY
 DISTKEY (businessentityid)
 SORTKEY (
	departmentid
	, shiftid
	)
;
