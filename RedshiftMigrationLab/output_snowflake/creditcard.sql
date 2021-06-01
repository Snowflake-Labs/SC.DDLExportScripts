--DROP TABLE adventureworks2012_sales.creditcard;
CREATE OR REPLACE TABLE  adventureworks2012_sales.creditcard		--// CREATE TABLE 
(
	creditcardid INTEGER NOT NULL  IDENTITY(144534,1) 		--//  ENCODE az64
	,cardtype VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,cardnumber VARCHAR(75) NOT NULL 		--//  ENCODE zstd
	,expmonth SMALLINT NOT NULL 		--//  ENCODE az64
	,expyear SMALLINT NOT NULL 		--//  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (creditcardid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (creditcardid)
;
