--DROP TABLE adventureworks2012_sales.countryregioncurrency;
CREATE OR REPLACE TABLE  adventureworks2012_sales.countryregioncurrency		--// CREATE TABLE 
(
	countryregioncode VARCHAR(9) NOT NULL 		--//  ENCODE lzo
	,currencycode VARCHAR(9) NOT NULL 		--//  ENCODE RAW
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (countryregioncode, currencycode)
)
		--// DISTSTYLE KEY
		--// DISTKEY (countryregioncode)
		--// SORTKEY ( 
		--// 	currencycode
		--// 	)
		--// ;
