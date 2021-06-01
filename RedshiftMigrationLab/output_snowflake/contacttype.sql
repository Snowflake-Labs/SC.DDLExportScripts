--DROP TABLE adventureworks2012_person.contacttype;
CREATE OR REPLACE TABLE  adventureworks2012_person.contacttype		--// CREATE TABLE 
(
	contacttypeid INTEGER NOT NULL  IDENTITY(144325,1) 		--//  ENCODE az64
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (contacttypeid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (contacttypeid)
;
