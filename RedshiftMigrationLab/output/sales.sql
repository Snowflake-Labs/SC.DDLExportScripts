
--DROP TABLE public.sales;
CREATE OR REPLACE TEMPORARY TABLE  public.sales		--// CREATE TEMP TABLE 
(
	salesid INTEGER NOT NULL 		--//  ENCODE az64
	,listid INTEGER NOT NULL 		--//  ENCODE az64
	,sellerid INTEGER NOT NULL 		--//  ENCODE az64
	,buyerid INTEGER NOT NULL 		--//  ENCODE az64
	,eventid INTEGER NOT NULL 		--//  ENCODE az64
	,dateid SMALLINT NOT NULL 		--//  ENCODE RAW
	,qtysold SMALLINT NOT NULL 		--//  ENCODE az64
	,pricepaid NUMERIC(8,2)  		--//  ENCODE az64
	,commission NUMERIC(8,2)  		--//  ENCODE az64
	,saletime TIMESTAMP WITHOUT TIME ZONE  		--//  ENCODE az64
)
		--// DISTSTYLE KEY
		--// DISTKEY (listid)
		--// SORTKEY ( 
		--// 	dateid
		--// 	)
		--// ;
