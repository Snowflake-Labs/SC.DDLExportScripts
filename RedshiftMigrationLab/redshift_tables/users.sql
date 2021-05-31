
--DROP TABLE public.;
CREATE TEMPORARY TABLE users
(
	userid INTEGER NOT NULL  ENCODE RAW
	,username CHAR(8)   ENCODE lzo
	,firstname VARCHAR(30)   ENCODE lzo
	,lastname VARCHAR(30)   ENCODE lzo
	,city VARCHAR(30)   ENCODE lzo
	,state CHAR(2)   ENCODE lzo
	,email VARCHAR(100)   ENCODE lzo
	,phone CHAR(14)   ENCODE lzo
	,likesports BOOLEAN   ENCODE RAW
	,liketheatre BOOLEAN   ENCODE RAW
	,likeconcerts BOOLEAN   ENCODE RAW
	,likejazz BOOLEAN   ENCODE RAW
	,likeclassical BOOLEAN   ENCODE RAW
	,likeopera BOOLEAN   ENCODE RAW
	,likerock BOOLEAN   ENCODE RAW
	,likevegas BOOLEAN   ENCODE RAW
	,likebroadway BOOLEAN   ENCODE RAW
	,likemusicals BOOLEAN   ENCODE RAW
)
DISTSTYLE KEY
 DISTKEY (userid)
 SORTKEY (
	userid
	)
;