
--DROP TABLE public.listing;
CREATE TABLE IF NOT EXISTS public.listing
(
	listid INTEGER NOT NULL  ENCODE az64
	,sellerid INTEGER NOT NULL  ENCODE az64
	,eventid INTEGER NOT NULL  ENCODE az64
	,dateid SMALLINT NOT NULL  ENCODE RAW
	,numtickets SMALLINT NOT NULL  ENCODE az64
	,priceperticket NUMERIC(8,2)   ENCODE az64
	,totalprice NUMERIC(8,2)   ENCODE az64
	,listtime TIMESTAMP WITHOUT TIME ZONE   ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (listid)
 SORTKEY (
	dateid
	)
;
