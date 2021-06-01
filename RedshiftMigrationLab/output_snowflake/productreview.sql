--DROP TABLE adventureworks2012_production.productreview;
CREATE OR REPLACE TABLE  adventureworks2012_production.productreview		--// CREATE TABLE 
(
	productreviewid INTEGER NOT NULL  IDENTITY(144473,1) 		--//  ENCODE az64
	,productid INTEGER NOT NULL 		--//  ENCODE RAW
	,reviewername VARCHAR(150) NOT NULL 		--//  ENCODE RAW
	,reviewdate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
	,emailaddress VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,rating INTEGER NOT NULL 		--//  ENCODE az64
	,comments VARCHAR(11550)  		--//  ENCODE RAW
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (productreviewid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (productreviewid)
		--// SORTKEY ( 
		--// 	productid
		--// 	, reviewername
		--// 	, comments
		--// 	)
		--// ;
