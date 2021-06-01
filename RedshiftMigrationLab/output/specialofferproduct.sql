--DROP TABLE adventureworks2012_sales.specialofferproduct;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.specialofferproduct
(
	specialofferid INTEGER NOT NULL  ENCODE az64
	,productid INTEGER NOT NULL  ENCODE RAW
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (specialofferid, productid)
)
DISTSTYLE KEY
 DISTKEY (specialofferid)
 SORTKEY (
	productid
	)
;
