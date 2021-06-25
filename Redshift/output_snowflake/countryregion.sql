--DROP TABLE adventureworks2012_person.countryregion;
CREATE OR REPLACE TABLE  adventureworks2012_person.countryregion		--// CREATE TABLE 
(
	countryregioncode VARCHAR(9) NOT NULL 		--//  ENCODE lzo
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (countryregioncode)
)
		--// DISTSTYLE KEY
		--// DISTKEY (countryregioncode)
;
