--DROP TABLE adventureworks2012_production.productdocument;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.productdocument
(
	productid INTEGER NOT NULL  ENCODE az64
	,documentnode VARCHAR(3000) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (productid, documentnode)
)
DISTSTYLE KEY
 DISTKEY (productid)
;
