--DROP TABLE adventureworks2012_production.productreview;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.productreview
(
	productreviewid INTEGER NOT NULL DEFAULT "identity"(144473, 0, '1,1'::text) ENCODE az64
	,productid INTEGER NOT NULL  ENCODE RAW
	,reviewername VARCHAR(150) NOT NULL  ENCODE RAW
	,reviewdate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,emailaddress VARCHAR(150) NOT NULL  ENCODE zstd
	,rating INTEGER NOT NULL  ENCODE az64
	,comments VARCHAR(11550)   ENCODE RAW
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (productreviewid)
)
DISTSTYLE KEY
 DISTKEY (productreviewid)
 SORTKEY (
	productid
	, reviewername
	, comments
	)
;
