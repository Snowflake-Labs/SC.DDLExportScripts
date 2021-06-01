--DROP TABLE adventureworks2012_purchasing.shipmethod;
CREATE TABLE IF NOT EXISTS adventureworks2012_purchasing.shipmethod
(
	shipmethodid INTEGER NOT NULL DEFAULT "identity"(144520, 0, '1,1'::text) ENCODE az64
	,name VARCHAR(150) NOT NULL  ENCODE zstd
	,shipbase NUMERIC(19,4) NOT NULL DEFAULT 0.00 ENCODE az64
	,shiprate NUMERIC(19,4) NOT NULL DEFAULT 0.00 ENCODE az64
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (shipmethodid)
)
DISTSTYLE KEY
 DISTKEY (shipmethodid)
;
