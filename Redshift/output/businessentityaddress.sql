--DROP TABLE adventureworks2012_person.businessentityaddress;
CREATE TABLE IF NOT EXISTS adventureworks2012_person.businessentityaddress
(
	businessentityid INTEGER NOT NULL  ENCODE az64
	,addressid INTEGER NOT NULL  ENCODE RAW
	,addresstypeid INTEGER NOT NULL  ENCODE RAW
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (businessentityid, addressid, addresstypeid)
)
DISTSTYLE KEY
 DISTKEY (businessentityid)
 SORTKEY (
	addressid
	, addresstypeid
	)
;
