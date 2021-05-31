--DROP TABLE public.category;
CREATE OR REPLACE TABLE  public.category		--// CREATE TABLE 
(
	catid SMALLINT NOT NULL 		--//  ENCODE RAW
	,catgroup VARCHAR(10)  		--//  ENCODE lzo
	,catname VARCHAR(10)  		--//  ENCODE lzo
	,catdesc VARCHAR(50)  		--//  ENCODE lzo
)
		--// DISTSTYLE KEY
		--// DISTKEY (catid)
		--// SORTKEY ( 
		--// 	catid
		--// 	)
		--// ;
