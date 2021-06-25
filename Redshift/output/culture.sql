--DROP TABLE adventureworks2012_production.culture;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.culture
(
	cultureid VARCHAR(18) NOT NULL  ENCODE lzo
	,name VARCHAR(150) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (cultureid)
)
DISTSTYLE KEY
 DISTKEY (cultureid)
;
