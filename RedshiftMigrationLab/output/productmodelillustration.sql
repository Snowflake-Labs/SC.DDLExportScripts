--DROP TABLE adventureworks2012_production.productmodelillustration;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.productmodelillustration
(
	productmodelid INTEGER NOT NULL  ENCODE az64
	,illustrationid INTEGER NOT NULL  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (productmodelid, illustrationid)
)
DISTSTYLE KEY
 DISTKEY (productmodelid)
;
