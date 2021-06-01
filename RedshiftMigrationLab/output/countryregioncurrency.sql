--DROP TABLE adventureworks2012_sales.countryregioncurrency;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.countryregioncurrency
(
	countryregioncode VARCHAR(9) NOT NULL  ENCODE lzo
	,currencycode VARCHAR(9) NOT NULL  ENCODE RAW
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (countryregioncode, currencycode)
)
DISTSTYLE KEY
 DISTKEY (countryregioncode)
 SORTKEY (
	currencycode
	)
;
