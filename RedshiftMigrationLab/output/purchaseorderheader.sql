--DROP TABLE adventureworks2012_purchasing.purchaseorderheader;
CREATE TABLE IF NOT EXISTS adventureworks2012_purchasing.purchaseorderheader
(
	purchaseorderid INTEGER NOT NULL DEFAULT "identity"(144510, 0, '1,1'::text) ENCODE az64
	,revisionnumber SMALLINT NOT NULL DEFAULT 0 ENCODE az64
	,status SMALLINT NOT NULL DEFAULT 1 ENCODE az64
	,employeeid INTEGER NOT NULL  ENCODE RAW
	,vendorid INTEGER NOT NULL  ENCODE RAW
	,shipmethodid INTEGER NOT NULL  ENCODE az64
	,orderdate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,shipdate TIMESTAMP WITHOUT TIME ZONE   ENCODE az64
	,subtotal NUMERIC(19,4) NOT NULL DEFAULT 0.00 ENCODE az64
	,taxamt NUMERIC(19,4) NOT NULL DEFAULT 0.00 ENCODE az64
	,freight NUMERIC(19,4) NOT NULL DEFAULT 0.00 ENCODE az64
	,totaldue NUMERIC(19,4) NOT NULL  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (purchaseorderid)
)
DISTSTYLE KEY
 DISTKEY (purchaseorderid)
 SORTKEY (
	vendorid
	, employeeid
	)
;
