--DROP TABLE adventureworks2012_production.productsubcategory;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.productsubcategory
(
	productsubcategoryid INTEGER NOT NULL DEFAULT "identity"(144478, 0, '1,1'::text) ENCODE az64
	,productcategoryid INTEGER NOT NULL  ENCODE az64
	,name VARCHAR(150) NOT NULL  ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (productsubcategoryid)
)
DISTSTYLE KEY
 DISTKEY (productsubcategoryid)
;
