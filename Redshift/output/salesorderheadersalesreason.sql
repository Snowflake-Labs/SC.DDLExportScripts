--DROP TABLE adventureworks2012_sales.salesorderheadersalesreason;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.salesorderheadersalesreason
(
	salesorderid INTEGER NOT NULL  ENCODE az64
	,salesreasonid INTEGER NOT NULL  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (salesorderid, salesreasonid)
)
DISTSTYLE KEY
 DISTKEY (salesorderid)
;
