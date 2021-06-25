--DROP TABLE adventureworks2012_purchasing.purchaseorderdetail;
CREATE TABLE IF NOT EXISTS adventureworks2012_purchasing.purchaseorderdetail
(
	purchaseorderid INTEGER NOT NULL  ENCODE az64
	,purchaseorderdetailid INTEGER NOT NULL DEFAULT "identity"(144506, 1, '1,1'::text) ENCODE az64
	,duedate TIMESTAMP WITHOUT TIME ZONE NOT NULL  ENCODE az64
	,orderqty SMALLINT NOT NULL  ENCODE az64
	,productid INTEGER NOT NULL  ENCODE RAW
	,unitprice NUMERIC(19,4) NOT NULL  ENCODE az64
	,linetotal NUMERIC(19,4) NOT NULL  ENCODE az64
	,receivedqty NUMERIC(8,2) NOT NULL  ENCODE az64
	,rejectedqty NUMERIC(8,2) NOT NULL  ENCODE az64
	,stockedqty NUMERIC(9,2) NOT NULL  ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (purchaseorderid, purchaseorderdetailid)
)
DISTSTYLE KEY
 DISTKEY (purchaseorderid)
 SORTKEY (
	productid
	)
;
