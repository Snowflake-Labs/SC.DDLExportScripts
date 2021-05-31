
--DROP TABLE public.event;
CREATE TABLE IF NOT EXISTS public.event
(
	eventid INTEGER NOT NULL  ENCODE az64
	,venueid SMALLINT NOT NULL  ENCODE az64
	,catid SMALLINT NOT NULL  ENCODE az64
	,dateid SMALLINT NOT NULL  ENCODE RAW
	,eventname VARCHAR(200)   ENCODE lzo
	,starttime TIMESTAMP WITHOUT TIME ZONE   ENCODE az64
)
DISTSTYLE KEY
 DISTKEY (eventid)
 SORTKEY (
	dateid
	)
;
