--DROP TABLE adventureworks2012_production.productphoto;
CREATE TABLE IF NOT EXISTS adventureworks2012_production.productphoto
(
	productphotoid INTEGER NOT NULL DEFAULT "identity"(144465, 0, '1,1'::text) ENCODE az64
	,thumbnailphoto VARCHAR(1300)   ENCODE zstd
	,thumbnailphotofilename VARCHAR(150)   ENCODE zstd
	,largephoto VARCHAR(1300)   ENCODE zstd
	,largephotofilename VARCHAR(150)   ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (productphotoid)
)
DISTSTYLE KEY
 DISTKEY (productphotoid)
;
