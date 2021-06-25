--DROP TABLE adventureworks2012_sales.currencyrate;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.currencyrate
(
	currencyrateid INTEGER NOT NULL DEFAULT "identity"(144541, 0, '1,1'::text) ENCODE az64
	,currencyratedate TIMESTAMP WITHOUT TIME ZONE NOT NULL  ENCODE az64
	,fromcurrencycode VARCHAR(9) NOT NULL  ENCODE zstd
	,tocurrencycode VARCHAR(9) NOT NULL  ENCODE zstd
	,averagerate NUMERIC(19,4) NOT NULL  ENCODE az64
	,endofdayrate NUMERIC(19,4) NOT NULL  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (currencyrateid)
)
DISTSTYLE KEY
 DISTKEY (currencyrateid)
;
