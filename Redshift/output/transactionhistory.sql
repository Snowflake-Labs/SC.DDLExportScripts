--DROP TABLE adventureworks2012_production.transactionhistory;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.transactionhistory
(
	transactionid INTEGER NOT NULL DEFAULT "identity"(144482, 0, '100000,1'::text) ENCODE az64
	,productid INTEGER NOT NULL  ENCODE RAW
	,referenceorderid INTEGER NOT NULL  ENCODE RAW
	,referenceorderlineid INTEGER NOT NULL DEFAULT 0 ENCODE RAW
	,transactiondate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,transactiontype VARCHAR(3) NOT NULL  ENCODE zstd
	,quantity INTEGER NOT NULL  ENCODE az64
	,actualcost NUMERIC(19,4) NOT NULL  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (transactionid)
)
DISTSTYLE KEY
 DISTKEY (transactionid)
 SORTKEY (
	productid
	, referenceorderid
	, referenceorderlineid
	)
;
