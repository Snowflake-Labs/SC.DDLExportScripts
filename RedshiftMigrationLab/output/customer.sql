--DROP TABLE adventureworks2012_sales.customer;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.customer
(
	customerid INTEGER NOT NULL DEFAULT "identity"(144545, 0, '1,1'::text) ENCODE az64
	,personid INTEGER   ENCODE az64
	,storeid INTEGER   ENCODE az64
	,territoryid INTEGER   ENCODE RAW
	,accountnumber VARCHAR(30) NOT NULL  ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (customerid)
)
DISTSTYLE KEY
 DISTKEY (customerid)
 SORTKEY (
	territoryid
	)
;
