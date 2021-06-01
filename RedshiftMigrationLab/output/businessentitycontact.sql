--DROP TABLE adventureworks2012_person.businessentitycontact;
CREATE TABLE IF NOT EXISTS adventureworks2012_person.businessentitycontact
(
	businessentityid INTEGER NOT NULL  ENCODE az64
	,personid INTEGER NOT NULL  ENCODE RAW
	,contacttypeid INTEGER NOT NULL  ENCODE RAW
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (businessentityid, personid, contacttypeid)
)
DISTSTYLE KEY
 DISTKEY (businessentityid)
 SORTKEY (
	personid
	, contacttypeid
	)
;
