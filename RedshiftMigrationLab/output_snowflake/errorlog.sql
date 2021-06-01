--DROP TABLE adventureworks2012_dbo.errorlog;
CREATE OR REPLACE TABLE  adventureworks2012_dbo.errorlog		--// CREATE TABLE 
(
	errorlogid INTEGER NOT NULL  IDENTITY(144202,1) 		--//  ENCODE az64
	,errortime TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
	,username VARCHAR(384) NOT NULL 		--//  ENCODE zstd
	,errornumber INTEGER NOT NULL 		--//  ENCODE az64
	,errorseverity INTEGER  		--//  ENCODE az64
	,errorstate INTEGER  		--//  ENCODE az64
	,errorprocedure VARCHAR(378)  		--//  ENCODE zstd
	,errorline INTEGER  		--//  ENCODE az64
	,errormessage VARCHAR(12000) NOT NULL 		--//  ENCODE zstd
		--// ,PRIMARY KEY (errorlogid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (errorlogid)
;
