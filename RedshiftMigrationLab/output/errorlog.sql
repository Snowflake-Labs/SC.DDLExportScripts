--DROP TABLE adventureworks2012_dbo.errorlog;
CREATE TABLE IF NOT EXISTS adventureworks2012_dbo.errorlog
(
	errorlogid INTEGER NOT NULL DEFAULT "identity"(144202, 0, '1,1'::text) ENCODE az64
	,errortime TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,username VARCHAR(384) NOT NULL  ENCODE zstd
	,errornumber INTEGER NOT NULL  ENCODE az64
	,errorseverity INTEGER   ENCODE az64
	,errorstate INTEGER   ENCODE az64
	,errorprocedure VARCHAR(378)   ENCODE zstd
	,errorline INTEGER   ENCODE az64
	,errormessage VARCHAR(12000) NOT NULL  ENCODE zstd
	,PRIMARY KEY (errorlogid)
)
DISTSTYLE KEY
 DISTKEY (errorlogid)
;
