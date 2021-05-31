--DROP TABLE public.date; CREATE TABLE IF NOT EXISTS public.date
CREATE TABLE public.date
(
	dateid SMALLINT NOT NULL  ENCODE RAW
	,caldate DATE NOT NULL  ENCODE az64
	,"day" CHAR(3) NOT NULL  ENCODE lzo
	,week SMALLINT NOT NULL  ENCODE az64
	,"month" CHAR(5) NOT NULL  ENCODE lzo
	,qtr CHAR(5) NOT NULL  ENCODE lzo
	,"year" SMALLINT NOT NULL  ENCODE az64
	,holiday BOOLEAN  DEFAULT false ENCODE RAW
)
DISTSTYLE KEY
 DISTKEY (dateid)
 SORTKEY (
	dateid
	)
;
