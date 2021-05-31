
--DROP TABLE public.venue;
CREATE OR REPLACE TABLE  public.venue		--// CREATE TABLE 
(
	venueid SMALLINT NOT NULL 		--//  ENCODE RAW
	,venuename VARCHAR(100)  		--//  ENCODE lzo
	,venuecity VARCHAR(30)  		--//  ENCODE lzo
	,venuestate CHAR(2)  		--//  ENCODE lzo
	,venueseats INTEGER  		--//  ENCODE az64
)
		--// DISTSTYLE KEY
		--// DISTKEY (venueid)
		--// SORTKEY ( 
		--// 	venueid
		--// 	)
		--// ;
