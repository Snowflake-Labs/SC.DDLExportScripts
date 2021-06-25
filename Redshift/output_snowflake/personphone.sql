--DROP TABLE adventureworks2012_person.personphone;
CREATE OR REPLACE TABLE  adventureworks2012_person.personphone		--// CREATE TABLE 
(
	businessentityid INTEGER NOT NULL 		--//  ENCODE az64
	,phonenumber VARCHAR(75) NOT NULL 		--//  ENCODE RAW
	,phonenumbertypeid INTEGER NOT NULL 		--//  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (businessentityid, phonenumber, phonenumbertypeid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (businessentityid)
		--// SORTKEY ( 
		--// 	phonenumber
		--// 	)
		--// ;
