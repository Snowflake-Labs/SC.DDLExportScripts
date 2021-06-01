--DROP TABLE adventureworks2012_production.productphoto;
CREATE OR REPLACE TABLE  adventureworks2012_production.productphoto		--// CREATE TABLE 
(
	productphotoid INTEGER NOT NULL  IDENTITY(144465,1) 		--//  ENCODE az64
	,thumbnailphoto VARCHAR(1300)  		--//  ENCODE zstd
	,thumbnailphotofilename VARCHAR(150)  		--//  ENCODE zstd
	,largephoto VARCHAR(1300)  		--//  ENCODE zstd
	,largephotofilename VARCHAR(150)  		--//  ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP)::timestamp without time zone		--//  ENCODE az64 // 'now'::text
		--// ,PRIMARY KEY (productphotoid)
)
		--// DISTSTYLE KEY
		--// DISTKEY (productphotoid)
;
