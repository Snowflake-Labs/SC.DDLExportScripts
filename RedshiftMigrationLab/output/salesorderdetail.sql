--DROP TABLE adventureworks2012_sales.salesorderdetail;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.salesorderdetail
(
	salesorderid INTEGER NOT NULL  ENCODE az64
	,salesorderdetailid INTEGER NOT NULL DEFAULT "identity"(144552, 1, '1,1'::text) ENCODE az64
	,carriertrackingnumber VARCHAR(75)   ENCODE zstd
	,orderqty SMALLINT NOT NULL  ENCODE az64
	,productid INTEGER NOT NULL  ENCODE RAW
	,specialofferid INTEGER NOT NULL  ENCODE az64
	,unitprice NUMERIC(19,4) NOT NULL  ENCODE az64
	,unitpricediscount NUMERIC(19,4) NOT NULL DEFAULT 0.0 ENCODE az64
	,linetotal NUMERIC(38,6) NOT NULL  ENCODE az64
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (salesorderid, salesorderdetailid)
)
DISTSTYLE KEY
 DISTKEY (salesorderid)
 SORTKEY (
	productid
	)
;
