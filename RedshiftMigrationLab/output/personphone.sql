--DROP TABLE adventureworks2012_person.personphone;
CREATE TABLE IF NOT EXISTS adventureworks2012_person.personphone
(
	businessentityid INTEGER NOT NULL  ENCODE az64
	,phonenumber VARCHAR(75) NOT NULL  ENCODE RAW
	,phonenumbertypeid INTEGER NOT NULL  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (businessentityid, phonenumber, phonenumbertypeid)
)
DISTSTYLE KEY
 DISTKEY (businessentityid)
 SORTKEY (
	phonenumber
	)
;
