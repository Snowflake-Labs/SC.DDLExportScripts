--DROP TABLE adventureworks2012_sales.currencyrate;
CREATE OR REPLACE TABLE  adventureworks2012_sales.currencyrate		--// CREATE TABLE 
(
	currencyrateid INTEGER NOT NULL  IDENTITY(144541,1) 		--//  ENCODE az64
	,currencyratedate TIMESTAMP WITHOUT TIME ZONE NOT NULL 		--//  ENCODE az64
	,fromcurrencycode VARCHAR(9) NOT NULL 		--//  ENCODE zstd
	,tocurrencycode VARCHAR(9) NOT NULL 		--//  ENCODE zstd
	,averagerate NUMERIC(19,4) NOT NULL 		--//  ENCODE az64
	,endofdayrate NUMERIC(19,4) NOT NULL 		--//  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (currencyrateid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (currencyrateid)
;
