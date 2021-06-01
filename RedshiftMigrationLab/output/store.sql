--DROP TABLE adventureworks2012_sales.store;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.store
(
	businessentityid INTEGER NOT NULL  ENCODE az64
	,name VARCHAR(150) NOT NULL  ENCODE zstd
	,salespersonid INTEGER   ENCODE RAW
	,demographics VARCHAR(1300)   ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (businessentityid)
)
DISTSTYLE KEY
 DISTKEY (businessentityid)
 SORTKEY (
	salespersonid
	)
;
