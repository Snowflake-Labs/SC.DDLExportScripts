--DROP TABLE adventureworks2012_humanresources.jobcandidate;
CREATE TABLE IF NOT EXISTS adventureworks2012_humanresources.jobcandidate
(
	jobcandidateid INTEGER NOT NULL DEFAULT "identity"(144236, 0, '1,1'::text) ENCODE az64
	,businessentityid INTEGER   ENCODE RAW
	,resume VARCHAR(1300)   ENCODE zstd
	,modifieddate TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT ('now'::text)::timestamp without time zone ENCODE az64
	,PRIMARY KEY (jobcandidateid)
)
DISTSTYLE KEY
 DISTKEY (jobcandidateid)
 SORTKEY (
	businessentityid
	)
;
