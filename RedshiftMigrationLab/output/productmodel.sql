--DROP TABLE adventureworks2012_production.productmodel;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.productmodel
(
	productmodelid INTEGER NOT NULL DEFAULT "identity"(144455, 0, '1,1'::text) ENCODE az64
	,name VARCHAR(150) NOT NULL  ENCODE zstd
	,catalogdescription VARCHAR(1300)   ENCODE zstd
	,instructions VARCHAR(1300)   ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (productmodelid)
)
DISTSTYLE KEY
 DISTKEY (productmodelid)
;
