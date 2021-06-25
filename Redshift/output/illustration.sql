--DROP TABLE adventureworks2012_production.illustration;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.illustration
(
	illustrationid INTEGER NOT NULL DEFAULT "identity"(144370, 0, '1,1'::text) ENCODE az64
	,diagram VARCHAR(1300)   ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (illustrationid)
)
DISTSTYLE KEY
 DISTKEY (illustrationid)
;
