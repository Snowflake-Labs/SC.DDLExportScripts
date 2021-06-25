--DROP TABLE adventureworks2012_person.phonenumbertype;
CREATE OR REPLACE TABLE  adventureworks2012_person.phonenumbertype		--// CREATE TABLE 
(
	phonenumbertypeid INTEGER NOT NULL  IDENTITY(144347,1) 		--//  ENCODE az64
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (phonenumbertypeid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (phonenumbertypeid)
;
