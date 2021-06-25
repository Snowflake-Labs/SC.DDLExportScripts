--DROP TABLE adventureworks2012_sales.salesterritory;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.salesterritory
(
	territoryid INTEGER NOT NULL DEFAULT "identity"(144590, 0, '1,1'::text) ENCODE az64
	,name VARCHAR(150) NOT NULL  ENCODE zstd
	,countryregioncode VARCHAR(9) NOT NULL  ENCODE zstd
	,"group" VARCHAR(150) NOT NULL  ENCODE zstd
	,salesytd NUMERIC(19,4) NOT NULL DEFAULT 0.00 ENCODE az64
	,saleslastyear NUMERIC(19,4) NOT NULL DEFAULT 0.00 ENCODE az64
	,costytd NUMERIC(19,4) NOT NULL DEFAULT 0.00 ENCODE az64
	,costlastyear NUMERIC(19,4) NOT NULL DEFAULT 0.00 ENCODE az64
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (territoryid)
)
DISTSTYLE KEY
 DISTKEY (territoryid)
;
