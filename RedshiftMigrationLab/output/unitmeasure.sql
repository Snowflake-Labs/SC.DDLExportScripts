--DROP TABLE adventureworks2012_production.unitmeasure;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.unitmeasure
(
	unitmeasurecode VARCHAR(9) NOT NULL  ENCODE lzo
	,name VARCHAR(150) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (unitmeasurecode)
)
DISTSTYLE KEY
 DISTKEY (unitmeasurecode)
;
