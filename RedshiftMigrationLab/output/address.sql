--DROP TABLE adventureworks2012_person.address;
CREATE TABLE IF NOT EXISTS adventureworks2012_person.address
(
	addressid INTEGER NOT NULL DEFAULT "identity"(144307, 0, '1,1'::text) ENCODE az64
	,addressline1 VARCHAR(180) NOT NULL  ENCODE zstd
	,addressline2 VARCHAR(180)   ENCODE zstd
	,city VARCHAR(90) NOT NULL  ENCODE zstd
	,stateprovinceid INTEGER NOT NULL  ENCODE RAW
	,postalcode VARCHAR(45) NOT NULL  ENCODE zstd
	,spatiallocation VARCHAR(10000)   ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (addressid)
)
DISTSTYLE KEY
 DISTKEY (addressid)
 SORTKEY (
	stateprovinceid
	)
;
