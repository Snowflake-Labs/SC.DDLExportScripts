--DROP TABLE adventureworks2012_sales.salestaxrate;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.salestaxrate
(
	salestaxrateid INTEGER NOT NULL DEFAULT "identity"(144585, 0, '1,1'::text) ENCODE az64
	,stateprovinceid INTEGER NOT NULL  ENCODE az64
	,taxtype SMALLINT NOT NULL  ENCODE az64
	,taxrate NUMERIC(10,4) NOT NULL DEFAULT 0.00 ENCODE az64
	,name VARCHAR(150) NOT NULL  ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (salestaxrateid)
)
DISTSTYLE KEY
 DISTKEY (salestaxrateid)
;
