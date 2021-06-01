--DROP TABLE adventureworks2012_humanresources.jobcandidate;
CREATE OR REPLACE TABLE  adventureworks2012_humanresources.jobcandidate		--// CREATE TABLE 
(
	jobcandidateid INTEGER NOT NULL  IDENTITY(144236,1) 		--//  ENCODE az64
	,businessentityid INTEGER  		--//  ENCODE RAW
	,resume VARCHAR(1300)  		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (jobcandidateid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (jobcandidateid)
		--// SORTKEY ( 
		--// 	businessentityid
		--// 	)
		--// ;
