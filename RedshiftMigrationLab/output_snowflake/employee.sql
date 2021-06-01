--DROP TABLE adventureworks2012_humanresources.employee;
CREATE OR REPLACE TABLE  adventureworks2012_humanresources.employee		--// CREATE TABLE 
(
	businessentityid INTEGER NOT NULL 		--//  ENCODE az64
	,nationalidnumber VARCHAR(45) NOT NULL 		--//  ENCODE zstd
	,loginid VARCHAR(768) NOT NULL 		--//  ENCODE zstd
	,organizationnode VARCHAR(3000)  		--//  ENCODE zstd
	,organizationlevel SMALLINT  		--//  ENCODE RAW
	,jobtitle VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,birthdate DATE NOT NULL 		--//  ENCODE az64
	,maritalstatus VARCHAR(3) NOT NULL 		--//  ENCODE zstd
	,gender VARCHAR(3) NOT NULL 		--//  ENCODE zstd
	,hiredate DATE NOT NULL 		--//  ENCODE az64
	,salariedflag BOOLEAN NOT NULL DEFAULT 1		--//  ENCODE zstd
	,vacationhours SMALLINT NOT NULL DEFAULT 0		--//  ENCODE az64
	,sickleavehours SMALLINT NOT NULL DEFAULT 0		--//  ENCODE az64
	,currentflag BOOLEAN NOT NULL DEFAULT 1		--//  ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (businessentityid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (businessentityid)
		--// SORTKEY ( 
		--// 	organizationlevel
		--// 	)
		--// ;
