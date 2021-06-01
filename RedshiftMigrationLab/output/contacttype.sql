--DROP TABLE adventureworks2012_person.contacttype;
CREATE TABLE IF NOT EXISTS adventureworks2012_person.contacttype
(
	contacttypeid INTEGER NOT NULL DEFAULT "identity"(144325, 0, '1,1'::text) ENCODE az64
	,name VARCHAR(150) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (contacttypeid)
)
DISTSTYLE KEY
 DISTKEY (contacttypeid)
;
