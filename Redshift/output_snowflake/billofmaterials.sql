--DROP TABLE adventureworks2012_production.billofmaterials;
CREATE OR REPLACE TABLE  adventureworks2012_production.billofmaterials		--// CREATE TABLE 
(
	billofmaterialsid INTEGER NOT NULL  IDENTITY(144356,1) 		--//  ENCODE az64
	,productassemblyid INTEGER  		--//  ENCODE az64
	,componentid INTEGER NOT NULL 		--//  ENCODE az64
	,startdate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
	,enddate TIMESTAMP WITHOUT TIME ZONE  		--//  ENCODE az64
	,unitmeasurecode VARCHAR(9) NOT NULL 		--//  ENCODE RAW
	,bomlevel SMALLINT NOT NULL 		--//  ENCODE az64
	,perassemblyqty NUMERIC(8,2) NOT NULL DEFAULT 1.00		--//  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (billofmaterialsid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (productassemblyid)
		--// SORTKEY ( 
		--// 	unitmeasurecode
		--// 	)
		--// ;
