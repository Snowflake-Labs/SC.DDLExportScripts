--DROP TABLE adventureworks2012_production.productproductphoto;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.productproductphoto
(
	productid INTEGER NOT NULL  ENCODE az64
	,productphotoid INTEGER NOT NULL  ENCODE az64
	,"primary" BOOLEAN NOT NULL DEFAULT 0 ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (productid, productphotoid)
)
DISTSTYLE KEY
 DISTKEY (productid)
;
