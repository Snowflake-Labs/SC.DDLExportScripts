--DROP TABLE adventureworks2012_production.productmodelproductdescriptionculture;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.productmodelproductdescriptionculture
(
	productmodelid INTEGER NOT NULL  ENCODE az64
	,productdescriptionid INTEGER NOT NULL  ENCODE az64
	,cultureid VARCHAR(18) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (productmodelid, productdescriptionid, cultureid)
)
DISTSTYLE KEY
 DISTKEY (productmodelid)
;
