--DROP TABLE adventureworks2012_production.billofmaterials;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.billofmaterials
(
	billofmaterialsid INTEGER NOT NULL DEFAULT "identity"(144356, 0, '1,1'::text) ENCODE az64
	,productassemblyid INTEGER   ENCODE az64
	,componentid INTEGER NOT NULL  ENCODE az64
	,startdate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,enddate TIMESTAMP WITHOUT TIME ZONE   ENCODE az64
	,unitmeasurecode VARCHAR(9) NOT NULL  ENCODE RAW
	,bomlevel SMALLINT NOT NULL  ENCODE az64
	,perassemblyqty NUMERIC(8,2) NOT NULL DEFAULT 1.00 ENCODE az64
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (billofmaterialsid)
)
DISTSTYLE KEY
 DISTKEY (productassemblyid)
 SORTKEY (
	unitmeasurecode
	)
;
