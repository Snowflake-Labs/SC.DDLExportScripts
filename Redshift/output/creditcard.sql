--DROP TABLE adventureworks2012_sales.creditcard;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.creditcard
(
	creditcardid INTEGER NOT NULL DEFAULT "identity"(144534, 0, '1,1'::text) ENCODE az64
	,cardtype VARCHAR(150) NOT NULL  ENCODE zstd
	,cardnumber VARCHAR(75) NOT NULL  ENCODE zstd
	,expmonth SMALLINT NOT NULL  ENCODE az64
	,expyear SMALLINT NOT NULL  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (creditcardid)
)
DISTSTYLE KEY
 DISTKEY (creditcardid)
;
