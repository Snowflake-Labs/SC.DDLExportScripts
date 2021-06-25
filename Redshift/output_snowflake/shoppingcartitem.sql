--DROP TABLE adventureworks2012_sales.shoppingcartitem;
CREATE OR REPLACE TABLE  adventureworks2012_sales.shoppingcartitem		--// CREATE TABLE 
(
	shoppingcartitemid INTEGER NOT NULL  IDENTITY(144601,1) 		--//  ENCODE az64
	,shoppingcartid VARCHAR(150) NOT NULL 		--//  ENCODE RAW
	,quantity INTEGER NOT NULL DEFAULT 1		--//  ENCODE az64
	,productid INTEGER NOT NULL 		--//  ENCODE RAW
	,datecreated TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (shoppingcartitemid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (shoppingcartitemid)
		--// SORTKEY ( 
		--// 	shoppingcartid
		--// 	, productid
		--// 	)
		--// ;
