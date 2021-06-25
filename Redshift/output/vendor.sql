--DROP TABLE adventureworks2012_purchasing.vendor;
CREATE TABLE IF NOT EXISTS adventureworks2012_purchasing.vendor
(
	businessentityid INTEGER NOT NULL  ENCODE az64
	,accountnumber VARCHAR(45) NOT NULL  ENCODE zstd
	,name VARCHAR(150) NOT NULL  ENCODE zstd
	,creditrating SMALLINT NOT NULL  ENCODE az64
	,preferredvendorstatus BOOLEAN NOT NULL DEFAULT 1 ENCODE zstd
	,activeflag BOOLEAN NOT NULL DEFAULT 1 ENCODE zstd
	,purchasingwebserviceurl VARCHAR(3072)   ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (businessentityid)
)
DISTSTYLE KEY
 DISTKEY (businessentityid)
;
