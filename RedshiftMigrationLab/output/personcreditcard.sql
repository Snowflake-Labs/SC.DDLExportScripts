--DROP TABLE adventureworks2012_sales.personcreditcard;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.personcreditcard
(
	businessentityid INTEGER NOT NULL  ENCODE az64
	,creditcardid INTEGER NOT NULL  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (businessentityid, creditcardid)
)
DISTSTYLE KEY
 DISTKEY (businessentityid)
;
