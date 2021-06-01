--DROP TABLE adventureworks2012_person.businessentity;
CREATE TABLE IF NOT EXISTS adventureworks2012_person.businessentity
(
	businessentityid INTEGER NOT NULL DEFAULT "identity"(144315, 0, '1,1'::text) ENCODE az64
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (businessentityid)
)
DISTSTYLE KEY
 DISTKEY (businessentityid)
;
