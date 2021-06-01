--DROP TABLE adventureworks2012_dbo.databaselog;
CREATE TABLE IF NOT EXISTS adventureworks2012_dbo.databaselog
(
	databaselogid INTEGER NOT NULL DEFAULT "identity"(144199, 0, '1,1'::text) ENCODE az64
	,posttime TIMESTAMP WITHOUT TIME ZONE NOT NULL  ENCODE az64
	,databaseuser VARCHAR(384) NOT NULL  ENCODE zstd
	,event VARCHAR(384) NOT NULL  ENCODE zstd
	,"schema" VARCHAR(384)   ENCODE zstd
	,"object" VARCHAR(384)   ENCODE zstd
	,tsql VARCHAR(1300) NOT NULL  ENCODE zstd
	,xmlevent VARCHAR(1300) NOT NULL  ENCODE zstd
	,PRIMARY KEY (databaselogid)
)
DISTSTYLE KEY
 DISTKEY (databaselogid)
;
