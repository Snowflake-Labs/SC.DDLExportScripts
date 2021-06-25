--DROP TABLE adventureworks2012_production.workorder;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.workorder
(
	workorderid INTEGER NOT NULL DEFAULT "identity"(144496, 0, '1,1'::text) ENCODE az64
	,productid INTEGER NOT NULL  ENCODE RAW
	,orderqty INTEGER NOT NULL  ENCODE az64
	,stockedqty INTEGER NOT NULL  ENCODE az64
	,scrappedqty SMALLINT NOT NULL  ENCODE az64
	,startdate TIMESTAMP WITHOUT TIME ZONE NOT NULL  ENCODE az64
	,enddate TIMESTAMP WITHOUT TIME ZONE   ENCODE az64
	,duedate TIMESTAMP WITHOUT TIME ZONE NOT NULL  ENCODE az64
	,scrapreasonid SMALLINT   ENCODE RAW
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (workorderid)
)
DISTSTYLE KEY
 DISTKEY (workorderid)
 SORTKEY (
	scrapreasonid
	, productid
	)
;
