--DROP TABLE adventureworks2012_production.unitmeasure;
CREATE OR REPLACE TABLE  adventureworks2012_production.unitmeasure		--// CREATE TABLE 
(
	unitmeasurecode VARCHAR(9) NOT NULL 		--//  ENCODE lzo
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (unitmeasurecode)
)
		--// DISTSTYLE KEY
		--// DISTKEY (unitmeasurecode)
;
