--DROP TABLE adventureworks2012_person.businessentitycontact;
CREATE OR REPLACE TABLE  adventureworks2012_person.businessentitycontact		--// CREATE TABLE 
(
	businessentityid INTEGER NOT NULL 		--//  ENCODE az64
	,personid INTEGER NOT NULL 		--//  ENCODE RAW
	,contacttypeid INTEGER NOT NULL 		--//  ENCODE RAW
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (businessentityid, personid, contacttypeid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (businessentityid)
		--// SORTKEY ( 
		--// 	personid
		--// 	, contacttypeid
		--// 	)
		--// ;
