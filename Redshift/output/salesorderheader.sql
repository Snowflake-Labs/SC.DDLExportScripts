--DROP TABLE adventureworks2012_sales.salesorderheader;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.salesorderheader
(
	salesorderid INTEGER NOT NULL DEFAULT "identity"(144557, 0, '1,1'::text) ENCODE az64
	,revisionnumber SMALLINT NOT NULL DEFAULT 0 ENCODE az64
	,orderdate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,duedate TIMESTAMP WITHOUT TIME ZONE NOT NULL  ENCODE az64
	,shipdate TIMESTAMP WITHOUT TIME ZONE   ENCODE az64
	,status SMALLINT NOT NULL DEFAULT 1 ENCODE az64
	,onlineorderflag BOOLEAN NOT NULL DEFAULT 1 ENCODE zstd
	,salesordernumber VARCHAR(75) NOT NULL  ENCODE zstd
	,purchaseordernumber VARCHAR(75)   ENCODE zstd
	,accountnumber VARCHAR(45)   ENCODE zstd
	,customerid INTEGER NOT NULL  ENCODE RAW
	,salespersonid INTEGER   ENCODE RAW
	,territoryid INTEGER   ENCODE az64
	,billtoaddressid INTEGER NOT NULL  ENCODE az64
	,shiptoaddressid INTEGER NOT NULL  ENCODE az64
	,shipmethodid INTEGER NOT NULL  ENCODE az64
	,creditcardid INTEGER   ENCODE az64
	,creditcardapprovalcode VARCHAR(45)   ENCODE zstd
	,currencyrateid INTEGER   ENCODE az64
	,subtotal NUMERIC(19,4) NOT NULL DEFAULT 0.00 ENCODE az64
	,taxamt NUMERIC(19,4) NOT NULL DEFAULT 0.00 ENCODE az64
	,freight NUMERIC(19,4) NOT NULL DEFAULT 0.00 ENCODE az64
	,totaldue NUMERIC(19,4) NOT NULL  ENCODE az64
	,"comment" VARCHAR(384)   ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (salesorderid)
)
DISTSTYLE KEY
 DISTKEY (salesorderid)
 SORTKEY (
	customerid
	, salespersonid
	)
;
