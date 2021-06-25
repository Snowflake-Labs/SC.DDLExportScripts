--DROP TABLE adventureworks2012_sales.shoppingcartitem;
CREATE TABLE IF NOT EXISTS adventureworks2012_sales.shoppingcartitem
(
	shoppingcartitemid INTEGER NOT NULL DEFAULT "identity"(144601, 0, '1,1'::text) ENCODE az64
	,shoppingcartid VARCHAR(150) NOT NULL  ENCODE RAW
	,quantity INTEGER NOT NULL DEFAULT 1 ENCODE az64
	,productid INTEGER NOT NULL  ENCODE RAW
	,datecreated TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (shoppingcartitemid)
)
DISTSTYLE KEY
 DISTKEY (shoppingcartitemid)
 SORTKEY (
	shoppingcartid
	, productid
	)
;
