--DROP TABLE adventureworks2012_production.document;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.document
(
	documentnode VARCHAR(3000) NOT NULL  ENCODE zstd
	,documentlevel SMALLINT   ENCODE az64
	,title VARCHAR(150) NOT NULL  ENCODE zstd
	,"owner" INTEGER NOT NULL  ENCODE az64
	,folderflag BOOLEAN NOT NULL DEFAULT 0 ENCODE zstd
	,filename VARCHAR(1200) NOT NULL  ENCODE RAW
	,fileextension VARCHAR(24) NOT NULL  ENCODE zstd
	,revision VARCHAR(15) NOT NULL  ENCODE RAW
	,changenumber INTEGER NOT NULL DEFAULT 0 ENCODE az64
	,status SMALLINT NOT NULL  ENCODE az64
	,documentsummary VARCHAR(1300)   ENCODE zstd
	,document VARCHAR(1300)   ENCODE zstd
	,rowguid VARCHAR(36) NOT NULL  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (documentnode)
	,UNIQUE (rowguid)
)
DISTSTYLE KEY
 DISTKEY (documentlevel)
 SORTKEY (
	filename
	, revision
	)
;
