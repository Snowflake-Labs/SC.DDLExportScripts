--DROP TABLE adventureworks2012_sales.salespersonquotahistory;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.salespersonquotahistory
(
	businessentityid INTEGER NOT NULL  ENCODE az64
	,quotadate TIMESTAMP WITHOUT TIME ZONE NOT NULL  ENCODE az64
	,salesquota NUMERIC(19,4) NOT NULL  ENCODE az64
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (businessentityid, quotadate)
)
DISTSTYLE KEY
 DISTKEY (businessentityid)
;
