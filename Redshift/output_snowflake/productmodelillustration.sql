--DROP TABLE adventureworks2012_production.productmodelillustration;
CREATE OR REPLACE TABLE  adventureworks2012_production.productmodelillustration		--// CREATE TABLE 
(
	productmodelid INTEGER NOT NULL 		--//  ENCODE az64
	,illustrationid INTEGER NOT NULL 		--//  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (productmodelid, illustrationid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (productmodelid)
;
