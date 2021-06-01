--DROP TABLE adventureworks2012_production.productdescription;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.productdescription
(
	productdescriptionid INTEGER NOT NULL DEFAULT "identity"(144441, 0, '1,1'::text) ENCODE az64
	,description VARCHAR(1200) NOT NULL  ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (productdescriptionid)
)
DISTSTYLE KEY
 DISTKEY (productdescriptionid)
;
