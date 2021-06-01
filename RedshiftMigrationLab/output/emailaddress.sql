--DROP TABLE adventureworks2012_person.emailaddress;
CREATE TABLE IF NOT EXISTS adventureworks2012_person.emailaddress
(
	businessentityid INTEGER NOT NULL  ENCODE az64
	,emailaddressid INTEGER NOT NULL DEFAULT "identity"(144332, 1, '1,1'::text) ENCODE az64
	,emailaddress VARCHAR(150)   ENCODE RAW
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (businessentityid, emailaddressid)
)
DISTSTYLE KEY
 DISTKEY (businessentityid)
 SORTKEY (
	emailaddress
	)
;
