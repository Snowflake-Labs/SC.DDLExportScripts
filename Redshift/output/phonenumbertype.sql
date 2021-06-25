--DROP TABLE adventureworks2012_person.phonenumbertype;
CREATE TABLE IF NOT EXISTS adventureworks2012_person.phonenumbertype
(
	phonenumbertypeid INTEGER NOT NULL DEFAULT "identity"(144347, 0, '1,1'::text) ENCODE az64
	,name VARCHAR(150) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (phonenumbertypeid)
)
DISTSTYLE KEY
 DISTKEY (phonenumbertypeid)
;
