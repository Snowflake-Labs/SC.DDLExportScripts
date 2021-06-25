--DROP TABLE adventureworks2012_person.emailaddress;
CREATE OR REPLACE TABLE  adventureworks2012_person.emailaddress		--// CREATE TABLE 
(
	businessentityid INTEGER NOT NULL 		--//  ENCODE az64
	,emailaddressid INTEGER NOT NULL  IDENTITY(144332,1) 		--//  ENCODE az64
	,emailaddress VARCHAR(150)  		--//  ENCODE RAW
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (businessentityid, emailaddressid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (businessentityid)
		--// SORTKEY ( 
		--// 	emailaddress
		--// 	)
		--// ;
