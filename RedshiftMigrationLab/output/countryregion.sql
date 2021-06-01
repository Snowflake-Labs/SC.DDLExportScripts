--DROP TABLE adventureworks2012_person.countryregion;
CREATE TABLE IF NOT EXISTS adventureworks2012_person.countryregion
(
	countryregioncode VARCHAR(9) NOT NULL  ENCODE lzo
	,name VARCHAR(150) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (countryregioncode)
)
DISTSTYLE KEY
 DISTKEY (countryregioncode)
;
