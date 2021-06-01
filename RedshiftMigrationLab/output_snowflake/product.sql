--DROP TABLE adventureworks2012_production.product;
CREATE OR REPLACE TABLE  adventureworks2012_production.product		--// CREATE TABLE 
(
	productid INTEGER NOT NULL  IDENTITY(144428,1) 		--//  ENCODE az64
	,name VARCHAR(150) NOT NULL 		--//  ENCODE zstd
	,productnumber VARCHAR(75) NOT NULL 		--//  ENCODE zstd
	,makeflag BOOLEAN NOT NULL DEFAULT 1		--//  ENCODE zstd
	,finishedgoodsflag BOOLEAN NOT NULL DEFAULT 1		--//  ENCODE zstd
	,color VARCHAR(45)  		--//  ENCODE zstd
	,safetystocklevel SMALLINT NOT NULL 		--//  ENCODE az64
	,reorderpoint SMALLINT NOT NULL 		--//  ENCODE az64
	,standardcost NUMERIC(19,4) NOT NULL 		--//  ENCODE az64
	,listprice NUMERIC(19,4) NOT NULL 		--//  ENCODE az64
	,size VARCHAR(15)  		--//  ENCODE zstd
	,sizeunitmeasurecode VARCHAR(9)  		--//  ENCODE zstd
	,weightunitmeasurecode VARCHAR(9)  		--//  ENCODE zstd
	,weight NUMERIC(8,2)  		--//  ENCODE az64
	,daystomanufacture INTEGER NOT NULL 		--//  ENCODE az64
	,productline VARCHAR(6)  		--//  ENCODE zstd
	,"class" VARCHAR(6)  		--//  ENCODE zstd
	,style VARCHAR(6)  		--//  ENCODE zstd
	,productsubcategoryid INTEGER  		--//  ENCODE az64
	,productmodelid INTEGER  		--//  ENCODE az64
	,sellstartdate TIMESTAMP WITHOUT TIME ZONE NOT NULL 		--//  ENCODE az64
	,sellenddate TIMESTAMP WITHOUT TIME ZONE  		--//  ENCODE az64
	,discontinueddate TIMESTAMP WITHOUT TIME ZONE  		--//  ENCODE az64
	,rowguid VARCHAR(36) NOT NULL 		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (productid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (productid)
;
