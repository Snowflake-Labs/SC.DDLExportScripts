--DROP TABLE adventureworks2012_person.person;
CREATE TABLE IF NOT EXISTS adventureworks2012_person.person
(
	businessentityid INTEGER NOT NULL  ENCODE az64
	,persontype VARCHAR(6) NOT NULL  ENCODE zstd
	,namestyle BOOLEAN NOT NULL DEFAULT 0 ENCODE zstd
	,title VARCHAR(24)   ENCODE zstd
	,firstname VARCHAR(150) NOT NULL  ENCODE RAW
	,middlename VARCHAR(150)   ENCODE RAW
	,lastname VARCHAR(150) NOT NULL  ENCODE RAW
	,suffix VARCHAR(30)   ENCODE zstd
	,emailpromotion INTEGER NOT NULL DEFAULT 0 ENCODE az64
	,additionalcontactinfo VARCHAR(1300)   ENCODE zstd
	,demographics VARCHAR(1300)   ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (businessentityid)
)
DISTSTYLE KEY
 DISTKEY (businessentityid)
 SORTKEY (
	lastname
	, firstname
	, middlename
	)
;
