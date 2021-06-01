--DROP TABLE adventureworks2012_sales.salesreason;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.salesreason
(
	salesreasonid INTEGER NOT NULL DEFAULT "identity"(144581, 0, '1,1'::text) ENCODE az64
	,name VARCHAR(150) NOT NULL  ENCODE zstd
	,reasontype VARCHAR(150) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (salesreasonid)
)
DISTSTYLE KEY
 DISTKEY (salesreasonid)
;
