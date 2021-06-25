--DROP TABLE adventureworks2012_humanresources.employeepayhistory;
CREATE TABLE IF NOT EXISTS adventureworks2012_humanresources.employeepayhistory
(
	businessentityid INTEGER NOT NULL  ENCODE az64
	,ratechangedate TIMESTAMP WITHOUT TIME ZONE NOT NULL  ENCODE az64
	,rate NUMERIC(19,4) NOT NULL  ENCODE az64
	,payfrequency SMALLINT NOT NULL  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (businessentityid, ratechangedate)
)
DISTSTYLE KEY
 DISTKEY (businessentityid)
;
