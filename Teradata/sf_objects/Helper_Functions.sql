/******************************************************/
/**************** INTERVAL UDFS ***********************/
/******************************************************/

----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.INTERVAL2MONTHS_UDF
(INPUT_VALUE VARCHAR())
RETURNS INTEGER 
AS
'
CASE WHEN SUBSTR(INPUT_VALUE,1,1) = ''-'' THEN
   12 * CAST(SUBSTR(INPUT_VALUE,1 , POSITION(''-'', INPUT_VALUE,2)-1) AS INTEGER)
   - CAST(SUBSTR(INPUT_VALUE,POSITION(''-'', INPUT_VALUE)+1) AS INTEGER)
ELSE
   12 * CAST(SUBSTR(INPUT_VALUE,1 , POSITION(''-'', INPUT_VALUE,2)-1) AS INTEGER)
   + CAST(SUBSTR(INPUT_VALUE,POSITION(''-'', INPUT_VALUE)+1) AS INTEGER)
END
';

----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.INTERVAL2SECONDS_UDF
(INPUT_PART VARCHAR(30), INPUT_VALUE VARCHAR())
RETURNS DECIMAL(20,6) 
AS
'
CASE WHEN SUBSTR(INPUT_VALUE,1,1) = ''-'' THEN
   DECODE(INPUT_PART,
           ''DAY'',              86400 * INPUT_VALUE, 
           ''DAY TO HOUR'',      86400 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION('' '', INPUT_VALUE)-1) AS DECIMAL(10,0)) 
                               - 3600 * CAST(SUBSTR(INPUT_VALUE, POSITION('' '', INPUT_VALUE)+1) AS DECIMAL(10,0)),
           ''DAY TO MINUTE'',    86400 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION('' '', INPUT_VALUE)-1) AS INTEGER) 
                               - 3600 * CAST(SUBSTR(INPUT_VALUE, POSITION('' '', INPUT_VALUE)+1, POSITION('':'', INPUT_VALUE)-POSITION('' '', INPUT_VALUE)-1) AS INTEGER) 
                               - 60 * CAST(SUBSTR(INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1) AS INTEGER),
           ''DAY TO SECOND'',    86400 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION('' '', INPUT_VALUE)-1) AS INTEGER) 
                               - 3600 * CAST(SUBSTR(INPUT_VALUE, POSITION('' '', INPUT_VALUE)+1, POSITION('':'', INPUT_VALUE)-POSITION('' '', INPUT_VALUE)-1) AS INTEGER)
                               - 60 * CAST(SUBSTR(INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1, POSITION('':'', INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1) - POSITION('':'', INPUT_VALUE) - 1) AS INTEGER)
                               - CAST(SUBSTR(INPUT_VALUE,POSITION('':'', INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1)+1) AS DECIMAL(10,6)),
           ''HOUR'',             3600 * INPUT_VALUE, 
           ''HOUR TO MINUTE'',   3600 * CAST(SUBSTR(INPUT_VALUE,1 , POSITION('':'', INPUT_VALUE)-1) AS INTEGER)
                               - 60 * CAST(SUBSTR(INPUT_VALUE,POSITION('':'', INPUT_VALUE)+1) AS INTEGER),
           ''HOUR TO SECOND'',   3600 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION('':'', INPUT_VALUE)-POSITION('' '', INPUT_VALUE)-1) AS INTEGER)
                               - 60 * CAST(SUBSTR(INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1, POSITION('':'', INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1) - POSITION('':'', INPUT_VALUE) - 1) AS INTEGER)
                               - CAST(SUBSTR(INPUT_VALUE,POSITION('':'', INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1)+1) AS DECIMAL(10,6)),  
           ''MINUTE'',           60 * INPUT_VALUE,     
           ''MINUTE TO SECOND'', 60 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION('':'', INPUT_VALUE)-POSITION('' '', INPUT_VALUE)-1) AS INTEGER)
                               - CAST(SUBSTR(INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1) AS DECIMAL(10,6)),
           ''SECOND'',           INPUT_VALUE                                    
            )
ELSE
   DECODE(INPUT_PART,
           ''DAY'',              86400 * INPUT_VALUE, 
           ''DAY TO HOUR'',      86400 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION('' '', INPUT_VALUE)-1) AS INTEGER) 
                               + 3600 * CAST(SUBSTR(INPUT_VALUE, POSITION('' '', INPUT_VALUE)+1) AS INTEGER),
           ''DAY TO MINUTE'',    86400 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION('' '', INPUT_VALUE)-1) AS INTEGER) 
                               + 3600 * CAST(SUBSTR(INPUT_VALUE, POSITION('' '', INPUT_VALUE)+1, POSITION('':'', INPUT_VALUE)-POSITION('' '', INPUT_VALUE)-1) AS INTEGER) 
                               + 60 * CAST(SUBSTR(INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1) AS INTEGER),
           ''DAY TO SECOND'',    86400 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION('' '', INPUT_VALUE)-1) AS INTEGER) 
                               + 3600 * CAST(SUBSTR(INPUT_VALUE, POSITION('' '', INPUT_VALUE)+1, POSITION('':'', INPUT_VALUE)-POSITION('' '', INPUT_VALUE)-1) AS INTEGER)
                               + 60 * CAST(SUBSTR(INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1, POSITION('':'', INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1) - POSITION('':'', INPUT_VALUE) - 1) AS INTEGER)
                               + CAST(SUBSTR(INPUT_VALUE,POSITION('':'', INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1)+1) AS DECIMAL(10,6)),
           ''HOUR'',             3600 * INPUT_VALUE, 
           ''HOUR TO MINUTE'',   3600 * CAST(SUBSTR(INPUT_VALUE,1 , POSITION('':'', INPUT_VALUE)-1) AS INTEGER)
                               + 60 * CAST(SUBSTR(INPUT_VALUE,POSITION('':'', INPUT_VALUE)+1) AS INTEGER),
           ''HOUR TO SECOND'',   3600 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION('':'', INPUT_VALUE)-POSITION('' '', INPUT_VALUE)-1) AS INTEGER)
                               + 60 * CAST(SUBSTR(INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1, POSITION('':'', INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1) - POSITION('':'', INPUT_VALUE) - 1) AS INTEGER)
                               + CAST(SUBSTR(INPUT_VALUE,POSITION('':'', INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1)+1) AS DECIMAL(10,6)),  
           ''MINUTE'',           60 * INPUT_VALUE,     
           ''MINUTE TO SECOND'', 60 * CAST(SUBSTR(INPUT_VALUE, 1, POSITION('':'', INPUT_VALUE)-POSITION('' '', INPUT_VALUE)-1) AS INTEGER)
                               + CAST(SUBSTR(INPUT_VALUE, POSITION('':'', INPUT_VALUE)+1) AS DECIMAL(10,6)), 
           ''SECOND'',           INPUT_VALUE                                    
        )
END
';

----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.MONTHS2INTERVAL_UDF
(INPUT_PART VARCHAR(30), INPUT_VALUE NUMBER)
RETURNS VARCHAR
AS
'
DECODE(INPUT_PART,
                ''YEAR'',                (INPUT_VALUE/(12))::varchar,
                ''YEAR TO MONTH'',       TRUNC(INPUT_VALUE / 12) ||''-''|| MOD(INPUT_VALUE, 12)::varchar,     
                ''MONTH'',               INPUT_VALUE::varchar
)
';

----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.SECONDS2INTERVAL_UDF
(INPUT_PART VARCHAR(30), INPUT_VALUE NUMBER)
RETURNS VARCHAR
AS
'
DECODE(INPUT_PART,
                ''DAY'',                TRUNC((INPUT_VALUE/(86400)))::varchar,
                ''DAY TO HOUR'',        TRUNC(INPUT_VALUE/(86400))::varchar || '' '' || 
                                            CASE 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) = 0 THEN ''00'' 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) < 10 THEN ''0'' ELSE '''' END || 
                                            ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600))::varchar,
                ''DAY TO MINUTE'',      TRUNC(INPUT_VALUE/(86400))::varchar || '' '' || 
                                            CASE 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) = 0 THEN ''00'' 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) < 10 THEN ''0'' ELSE '''' END || 
                                            ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600))::varchar || '':'' || 
                                                CASE 
                                                    WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) = 0 THEN ''00'' 
                                                    WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) < 10 THEN ''0'' ELSE '''' END || 
                                                ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60))::varchar,
                ''DAY TO SECOND'',      TRUNC(INPUT_VALUE/(86400))::varchar || '' '' || 
                                            CASE 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) = 0 THEN ''00'' 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600)) < 10 THEN ''0'' ELSE '''' END || 
                                            ABS(TRUNC(MOD(INPUT_VALUE,86400)/3600))::varchar || '':'' || 
                                                CASE 
                                                    WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) = 0 THEN ''00'' 
                                                    WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) < 10 THEN ''0'' ELSE '''' END || 
                                               ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) || '':'' ||
                                                    CASE 
                                                        WHEN ABS(MOD(INPUT_VALUE, 60)) = 0 THEN ''00'' 
                                                        WHEN ABS(MOD(INPUT_VALUE, 60)) > -10 AND ABS(MOD(INPUT_VALUE, 60)) < 10 THEN ''0'' ELSE '''' END || 
                                                    ABS(MOD(INPUT_VALUE, 60))::varchar,
                ''HOUR'',               TRUNC((INPUT_VALUE/3600))::varchar,     
                ''HOUR TO MINUTE'',     TRUNC(INPUT_VALUE/3600)::varchar || '':'' || 
                                            CASE 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) = 0 THEN ''00'' 
                                                WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) < 10 THEN ''0'' ELSE '''' END || 
                                             ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60))::varchar,
                ''HOUR TO SECOND'',     TRUNC(INPUT_VALUE/3600)::varchar || '':'' || 
                                            CASE WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) = 0 THEN ''00'' WHEN ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) > -10 AND ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) < 10 THEN ''0'' ELSE '''' END || ABS(TRUNC(MOD(INPUT_VALUE, 3600)/60)) || '':'' ||
                                                CASE WHEN ABS(MOD(INPUT_VALUE, 60)) = 0 THEN ''00'' WHEN ABS(MOD(INPUT_VALUE, 60)) > -10 AND ABS(MOD(INPUT_VALUE, 60)) < 10 THEN ''0'' ELSE '''' END || ABS(MOD(INPUT_VALUE, 60))::varchar,
                ''MINUTE'',             TRUNC((INPUT_VALUE/60))::varchar,                
                ''MINUTE TO SECOND'',   TRUNC(INPUT_VALUE/60)::varchar || '':'' || 
                                            CASE WHEN ABS(MOD(INPUT_VALUE, 60)) = 0 THEN ''00'' WHEN ABS(MOD(INPUT_VALUE, 60)) > -10 AND ABS(MOD(INPUT_VALUE, 60)) < 10 THEN ''0'' ELSE '''' END || ABS(MOD(INPUT_VALUE, 60))::varchar,
                ''SECOND'',             INPUT_VALUE::varchar
)
';
----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.INTERVAL_MULTIPLY_UDF
(INPUT_PART VARCHAR(30), INPUT_VALUE VARCHAR(), INPUT_MULT INTEGER)
RETURNS VARCHAR
AS
'
CASE WHEN INPUT_PART = ''YEAR TO MONTH''
THEN SNOWCONVERT.PUBLIC.MONTHS2INTERVAL_UDF(INPUT_PART, SNOWCONVERT.PUBLIC.INTERVAL2MONTHS_UDF(INPUT_VALUE) * INPUT_MULT)
ELSE SNOWCONVERT.PUBLIC.SECONDS2INTERVAL_UDF(INPUT_PART, SNOWCONVERT.PUBLIC.INTERVAL2SECONDS_UDF(INPUT_PART, INPUT_VALUE) * INPUT_MULT)
END
';

----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.INTERVAL_ADD_UDF
(INPUT_VALUE1 VARCHAR(), INPUT_PART1 VARCHAR(30), INPUT_VALUE2 VARCHAR(), INPUT_PART2 VARCHAR(30), OP CHAR, OUTPUT_PART VARCHAR())
RETURNS VARCHAR
AS
'
CASE 
    WHEN INPUT_PART1 = ''YEAR TO MONTH'' OR INPUT_PART2 = ''YEAR TO MONTH'' THEN
        CASE 
            WHEN OP = ''+'' THEN
                SNOWCONVERT.PUBLIC.SECONDS2INTERVAL_UDF(OUTPUT_PART, SNOWCONVERT.PUBLIC.INTERVAL2MONTHS_UDF(INPUT_VALUE1) + SNOWCONVERT.PUBLIC.INTERVAL2MONTHS_UDF(INPUT_VALUE2))
            WHEN OP = ''-'' THEN
                SNOWCONVERT.PUBLIC.SECONDS2INTERVAL_UDF(OUTPUT_PART, SNOWCONVERT.PUBLIC.INTERVAL2MONTHS_UDF(INPUT_VALUE1) - SNOWCONVERT.PUBLIC.INTERVAL2MONTHS_UDF(INPUT_VALUE2))
        END
    ELSE 
        CASE 
            WHEN OP = ''+'' THEN
                SNOWCONVERT.PUBLIC.SECONDS2INTERVAL_UDF(OUTPUT_PART, SNOWCONVERT.PUBLIC.INTERVAL2SECONDS_UDF(INPUT_PART1, INPUT_VALUE1) + SNOWCONVERT.PUBLIC.INTERVAL2SECONDS_UDF(INPUT_PART2, INPUT_VALUE2))
            WHEN OP = ''-'' THEN
                SNOWCONVERT.PUBLIC.SECONDS2INTERVAL_UDF(OUTPUT_PART, SNOWCONVERT.PUBLIC.INTERVAL2SECONDS_UDF(INPUT_PART1, INPUT_VALUE1) - SNOWCONVERT.PUBLIC.INTERVAL2SECONDS_UDF(INPUT_PART2, INPUT_VALUE2))
        END  
END
';


/******************************************************/
/****************** PERIOD UDFS ***********************/
/******************************************************/
----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.TIMESTAMP_TO_PERIOD_UDF(INPUT_VALUE TIMESTAMP)
RETURNS VARCHAR 
AS
'
''('' || INPUT_VALUE || '', '' || TO_VARCHAR(TIMESTAMPADD(''SECOND'', .00001, TO_TIMESTAMP(INPUT_VALUE))) || '')''
';


----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.DATE_TO_PERIOD_UDF(INPUT_VALUE DATE)
RETURNS VARCHAR 
AS
'
''('' || INPUT_VALUE || '', '' || TO_VARCHAR(TO_DATE(INPUT_VALUE) + 1) || '')''
';

----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.PERIOD_END_UDF(PERIOD_VAL VARCHAR(22))
RETURNS TIMESTAMP
AS
' CAST(SUBSTR(PERIOD_VAL,POSITION(''*'',PERIOD_VAL)+1) AS TIMESTAMP) '     
;

----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.PERIOD_BEGIN_UDF(PERIOD_VAL VARCHAR(22))
RETURNS TIMESTAMP
AS
' CAST(SUBSTR(PERIOD_VAL,1, POSITION(''*'',PERIOD_VAL)-1) AS TIMESTAMP) '     
;

----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.PERIOD_LDIFF_UDF(PERIOD_1 VARCHAR(50), PERIOD_2 VARCHAR(50))
RETURNS VARCHAR
AS
' CASE WHEN SNOWCONVERT.PUBLIC.PERIOD_OVERLAPS_UDF(PERIOD_2, PERIOD_1) = ''TRUE'' 
            AND SNOWCONVERT.PUBLIC.PERIOD_BEGIN_UDF(PERIOD_1) < SNOWCONVERT.PUBLIC.PERIOD_BEGIN_UDF(PERIOD_2) 
       THEN
        SUBSTR(PERIOD_1,1, POSITION(''*'',PERIOD_1)-1) || ''*'' || SUBSTR(PERIOD_2,1, POSITION(''*'',PERIOD_2)-1)
       ELSE
         NULL
       END '     
;

----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.PERIOD_RDIFF_UDF(PERIOD_1 VARCHAR(50), PERIOD_2 VARCHAR(50))
RETURNS VARCHAR
AS
' CASE WHEN SNOWCONVERT.PUBLIC.PERIOD_OVERLAPS_UDF(PERIOD_2, PERIOD_1) = ''TRUE'' 
            AND SNOWCONVERT.PUBLIC.PERIOD_END_UDF(PERIOD_1) > SNOWCONVERT.PUBLIC.PERIOD_END_UDF(PERIOD_2) 
       THEN
        SUBSTR(PERIOD_2,POSITION(''*'',PERIOD_2)+1) || ''*'' || SUBSTR(PERIOD_1,POSITION(''*'',PERIOD_1)+1)
       ELSE
         NULL
       END '     
;

----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.PERIOD_OVERLAPS_UDF(PERIOD_1 VARCHAR(22), PERIOD_2 VARCHAR(22))
RETURNS BOOLEAN 
AS
' CASE WHEN 
    (SNOWCONVERT.PUBLIC.PERIOD_END_UDF(PERIOD_1) >= SNOWCONVERT.PUBLIC.PERIOD_BEGIN_UDF(PERIOD_2) AND
     SNOWCONVERT.PUBLIC.PERIOD_BEGIN_UDF(PERIOD_1)  < SNOWCONVERT.PUBLIC.PERIOD_END_UDF(PERIOD_2))
    OR
    (SNOWCONVERT.PUBLIC.PERIOD_BEGIN_UDF(PERIOD_1) >= SNOWCONVERT.PUBLIC.PERIOD_BEGIN_UDF(PERIOD_2)AND
     SNOWCONVERT.PUBLIC.PERIOD_BEGIN_UDF(PERIOD_1) < SNOWCONVERT.PUBLIC.PERIOD_END_UDF(PERIOD_2)
    )
THEN
    TRUE
ELSE
    FALSE
END '
;


/******************************************************/
/******************* OTHER UDFS ***********************/
/******************************************************/

----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.MONTHS_BETWEEN_UDF(INPUT_1 TIMESTAMP_LTZ, INPUT_2 TIMESTAMP_LTZ)
RETURNS NUMBER(20,6)
AS
'
CASE WHEN DAY(INPUT_2) <= DAY(INPUT_1) 
           THEN TIMESTAMPDIFF(MONTH,INPUT_2,INPUT_1) 
            ELSE TIMESTAMPDIFF(MONTH,INPUT_2,INPUT_1) - 1 
END + 
(CASE 
    WHEN DAY(INPUT_2) = DAY(INPUT_1) THEN 0
    WHEN DAY(INPUT_2) < DAY(INPUT_1) AND TO_TIME(INPUT_2) > TO_TIME(INPUT_1) THEN DAY(INPUT_1) - DAY(INPUT_2) - 1
    WHEN DAY(INPUT_2) <= DAY(INPUT_1) THEN DAY(INPUT_1) - DAY(INPUT_2) 
    ELSE 31 - DAY(INPUT_2) + DAY(INPUT_1) 
 END / 31) +
(CASE 
    WHEN DAY(INPUT_2) = DAY(INPUT_1) THEN 0
    WHEN HOUR(INPUT_2) <= HOUR(INPUT_1) THEN HOUR(INPUT_1) - HOUR(INPUT_2) 
    ELSE 24 - HOUR(INPUT_2) + HOUR(INPUT_1) 
END / (24*31)) +   
(CASE 
     WHEN DAY(INPUT_2) = DAY(INPUT_1) THEN 0   
     WHEN MINUTE(INPUT_2) <= MINUTE(INPUT_1) THEN MINUTE(INPUT_1) - MINUTE(INPUT_2) 
     ELSE 24 - HOUR(INPUT_2) + MINUTE(INPUT_1) 
        END / (24*60*31)) +
(CASE 
     WHEN DAY(INPUT_2) = DAY(INPUT_1) THEN 0   
     WHEN MINUTE(INPUT_2) <= MINUTE(INPUT_1) THEN MINUTE(INPUT_1) - MINUTE(INPUT_2) 
     ELSE 24 - HOUR(INPUT_2) + MINUTE(INPUT_1) 
END / (24*60*60*31))
'
;

----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.TRUNC_DATE_UDF(INPUT TIMESTAMP_LTZ, FMT VARCHAR(5))
RETURNS DATE
AS
'
CAST(CASE 
WHEN FMT IN (''CC'',''SCC'') THEN DATE_FROM_PARTS(CAST(LEFT(CAST(YEAR(INPUT) as CHAR(4)),2) || ''00'' as INTEGER),1,1)
WHEN FMT IN (''SYYYY'',''YYYY'',''YEAR'',''SYEAR'',''YYY'',''YY'',''Y'') THEN DATE_FROM_PARTS(YEAR(INPUT),1,1)
WHEN FMT IN (''IYYY'',''IYY'',''IY'',''I'') THEN 
    CASE DAYOFWEEK(DATE_FROM_PARTS(YEAR(INPUT),1,1))
         WHEN 0 THEN DATEADD(DAY, 1, DATE_FROM_PARTS(YEAR(INPUT),1,1))
         WHEN 1 THEN DATEADD(DAY, 0, DATE_FROM_PARTS(YEAR(INPUT),1,1))
         WHEN 2 THEN DATEADD(DAY, -1, DATE_FROM_PARTS(YEAR(INPUT),1,1))
         WHEN 3 THEN DATEADD(DAY, -2, DATE_FROM_PARTS(YEAR(INPUT),1,1))
         WHEN 4 THEN DATEADD(DAY, -3, DATE_FROM_PARTS(YEAR(INPUT),1,1))
         WHEN 5 THEN DATEADD(DAY, 3, DATE_FROM_PARTS(YEAR(INPUT),1,1))
         WHEN 6 THEN DATEADD(DAY, 2, DATE_FROM_PARTS(YEAR(INPUT),1,1))
    END        
WHEN FMT IN (''MONTH'',''MON'',''MM'',''RM'') THEN DATE_FROM_PARTS(YEAR(INPUT),MONTH(INPUT),1)
WHEN FMT IN (''Q'') THEN DATE_FROM_PARTS(YEAR(INPUT),(QUARTER(INPUT)-1)*3+1,1)
WHEN FMT IN (''WW'') THEN DATEADD(DAY, 0-MOD(TIMESTAMPDIFF(DAY,DATE_FROM_PARTS(YEAR(INPUT),1,1),INPUT),7), INPUT)
WHEN FMT IN (''IW'') THEN DATEADD(DAY, 0-MOD(TIMESTAMPDIFF(DAY,(CASE DAYOFWEEK(DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                 WHEN 0 THEN DATEADD(DAY, 1, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                 WHEN 1 THEN DATEADD(DAY, 0, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                 WHEN 2 THEN DATEADD(DAY, -1, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                 WHEN 3 THEN DATEADD(DAY, -2, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                 WHEN 4 THEN DATEADD(DAY, -3, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                 WHEN 5 THEN DATEADD(DAY, 3, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                 WHEN 6 THEN DATEADD(DAY, 2, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                               END),      INPUT),7), INPUT)
WHEN FMT IN (''W'') THEN DATEADD(DAY, 0-MOD(TIMESTAMPDIFF(DAY,DATE_FROM_PARTS(YEAR(INPUT),MONTH(INPUT),1),INPUT),7), INPUT)                                                             
WHEN FMT IN (''DDD'', ''DD'',''J'') THEN INPUT
WHEN FMT IN (''DAY'', ''DY'',''D'') THEN DATEADD(DAY, 0-DAYOFWEEK(INPUT), INPUT)
WHEN FMT IN (''HH'', ''HH12'',''HH24'') THEN INPUT
WHEN FMT IN (''MI'') THEN INPUT
END AS DATE)
'
;

----------
CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.ROUND_DATE_UDF(INPUT TIMESTAMP_LTZ, FMT VARCHAR(5))
RETURNS DATE
AS
'
CAST(
CASE 
    WHEN FMT IN (''CC'',''SCC'') THEN 
        CASE 
            WHEN RIGHT(CAST(YEAR(INPUT) as CHAR(4)),2) >=51 
                THEN DATE_FROM_PARTS(CAST(LEFT(CAST(YEAR(INPUT) as CHAR(4)),2) || ''01'' as INTEGER) +100,1,1)
            ELSE DATE_FROM_PARTS(CAST(LEFT(CAST(YEAR(INPUT) as CHAR(4)),2) || ''01'' as INTEGER),1,1)
        END    
    WHEN FMT IN (''SYYYY'',''YYYY'',''YEAR'',''SYEAR'',''YYY'',''YY'',''Y'') THEN 
        CASE WHEN MONTH(INPUT) >= 7 THEN DATE_FROM_PARTS(YEAR(INPUT)+1,1,1)
             ELSE DATE_FROM_PARTS(YEAR(INPUT),1,1)
        END
    WHEN FMT IN (''IYYY'',''IYY'',''IY'',''I'') THEN 
        CASE WHEN MONTH(INPUT) >= 7 THEN CASE DAYOFWEEK(DATE_FROM_PARTS(YEAR(INPUT),12,31))
                                                                  WHEN 0 THEN DATEADD(DAY, 1, DATE_FROM_PARTS(YEAR(INPUT),12,31))
                                                                  WHEN 1 THEN DATEADD(DAY, 0, DATE_FROM_PARTS(YEAR(INPUT),12,31))
                                                                  WHEN 2 THEN DATEADD(DAY, -1, DATE_FROM_PARTS(YEAR(INPUT),12,31))
                                                                  WHEN 3 THEN DATEADD(DAY, -2, DATE_FROM_PARTS(YEAR(INPUT),12,31))
                                                                  WHEN 4 THEN DATEADD(DAY, -3, DATE_FROM_PARTS(YEAR(INPUT),12,31))
                                                                  WHEN 5 THEN DATEADD(DAY, 3, DATE_FROM_PARTS(YEAR(INPUT),12,31))
                                                                  WHEN 6 THEN DATEADD(DAY, 2, DATE_FROM_PARTS(YEAR(INPUT),12,31))
                                                              END
             ELSE CASE DAYOFWEEK(DATE_FROM_PARTS(YEAR(INPUT),1,1))
                      WHEN 0 THEN DATEADD(DAY, 1, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                      WHEN 1 THEN DATEADD(DAY, 0, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                      WHEN 2 THEN DATEADD(DAY, -1, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                      WHEN 3 THEN DATEADD(DAY, -2, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                      WHEN 4 THEN DATEADD(DAY, -3, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                      WHEN 5 THEN DATEADD(DAY, 3, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                      WHEN 6 THEN DATEADD(DAY, 2, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                  END  
        END
    WHEN FMT IN (''MONTH'',''MON'',''MM'',''RM'') THEN 
        CASE WHEN DAYOFMONTH(INPUT) >15 THEN TIMESTAMPADD(MONTH, 1, DATE_FROM_PARTS(YEAR(INPUT),MONTH(INPUT),1))
             ELSE DATE_FROM_PARTS(YEAR(INPUT),MONTH(INPUT),1)
        END
    WHEN FMT IN (''Q'') THEN 
        CASE WHEN (MOD(MONTH(INPUT),3)=2 AND DAYOFMONTH(INPUT) >15) OR MOD(MONTH(INPUT),3)=0 
                THEN TIMESTAMPADD(MONTH, 3, DATE_FROM_PARTS(YEAR(INPUT),(QUARTER(INPUT)-1)*3+1,1)) 
             ELSE DATE_FROM_PARTS(YEAR(INPUT),(QUARTER(INPUT)-1)*3+1,1)
        END
    WHEN FMT IN (''WW'') THEN 
        CASE WHEN MOD(TIMESTAMPDIFF(DAY,DATE_FROM_PARTS(YEAR(INPUT),1,1),INPUT),7) < 4 
                THEN DATEADD(DAY, 0-MOD(TIMESTAMPDIFF(DAY,DATE_FROM_PARTS(YEAR(INPUT),1,1),INPUT),7), INPUT)
             ELSE DATEADD(DAY, 7-MOD(TIMESTAMPDIFF(DAY,DATE_FROM_PARTS(YEAR(INPUT),1,1),INPUT),7), INPUT)
        END
    WHEN FMT IN (''IW'') THEN 
        CASE WHEN MOD(TIMESTAMPDIFF(DAY,(CASE DAYOFWEEK(DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                             WHEN 0 THEN DATEADD(DAY, 1, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                             WHEN 1 THEN DATEADD(DAY, 0, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                             WHEN 2 THEN DATEADD(DAY, -1, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                             WHEN 3 THEN DATEADD(DAY, -2, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                             WHEN 4 THEN DATEADD(DAY, -3, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                             WHEN 5 THEN DATEADD(DAY, 3, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                             WHEN 6 THEN DATEADD(DAY, 2, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                         END
                   ), INPUT),7) >=4 THEN DATEADD(DAY,7-MOD(TIMESTAMPDIFF(DAY,(CASE DAYOFWEEK(DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                                    WHEN 0 THEN DATEADD(DAY, 1, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                                    WHEN 1 THEN DATEADD(DAY, 0, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                                    WHEN 2 THEN DATEADD(DAY, -1, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                                    WHEN 3 THEN DATEADD(DAY, -2, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                                    WHEN 4 THEN DATEADD(DAY, -3, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                                    WHEN 5 THEN DATEADD(DAY, 3, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                                    WHEN 6 THEN DATEADD(DAY, 2, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                                                END), INPUT),7), INPUT)
             ELSE DATEADD(DAY,0-MOD(TIMESTAMPDIFF(DAY,(CASE DAYOFWEEK(DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                           WHEN 0 THEN DATEADD(DAY, 1, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                           WHEN 1 THEN DATEADD(DAY, 0, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                           WHEN 2 THEN DATEADD(DAY, -1, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                           WHEN 3 THEN DATEADD(DAY, -2, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                           WHEN 4 THEN DATEADD(DAY, -3, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                           WHEN 5 THEN DATEADD(DAY, 3, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                           WHEN 6 THEN DATEADD(DAY, 2, DATE_FROM_PARTS(YEAR(INPUT),1,1))
                                                       END), INPUT),7), INPUT)
        END
    WHEN FMT IN (''W'') THEN 
        CASE WHEN MOD(TIMESTAMPDIFF(DAY,DATE_FROM_PARTS(YEAR(INPUT),MONTH(INPUT),1),INPUT),7) < 4 
                THEN DATEADD(DAY, 0-MOD(TIMESTAMPDIFF(DAY,DATE_FROM_PARTS(YEAR(INPUT),MONTH(INPUT),1),INPUT),7), INPUT)
            ELSE DATEADD(DAY, 7-MOD(TIMESTAMPDIFF(DAY,DATE_FROM_PARTS(YEAR(INPUT),MONTH(INPUT),1),INPUT),7), INPUT)
        END
    WHEN FMT IN (''DDD'', ''DD'',''J'') THEN INPUT
    WHEN FMT IN (''DAY'', ''DY'',''D'') THEN 
        CASE WHEN DAYOFWEEK(INPUT) > 3 THEN DATEADD(DAY, 7-DAYOFWEEK(INPUT), INPUT)
             ELSE DATEADD(DAY, 0-DAYOFWEEK(INPUT), INPUT)
        END
    WHEN FMT IN (''HH'', ''HH12'',''HH24'') THEN INPUT
    WHEN FMT IN (''MI'') THEN INPUT
END AS DATE)
';

CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.DATE_TO_INT_UDF(INPUT_1 TIMESTAMP_LTZ)
RETURNS NUMBER(7,0)
AS
$$
(YEAR(INPUT_1) - 1900) * 10000 + 
MONTH(INPUT_1) * 100 + 
DAY(INPUT_1)
$$
;

CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.INT_TO_DATE_UDF(INPUT_1 INTEGER)
RETURNS DATE
AS
$$
TO_DATE(CAST(INPUT_1+19000000 AS CHAR(8)), 'YYYYMMDD')
$$
;

CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.TIMESTAMP_ADD_UDF(A TIMESTAMP_LTZ, B TIMESTAMP_LTZ)
RETURNS TIMESTAMP
AS
$$
TIMESTAMPADD(YEAR, YEAR(B), TIMESTAMPADD(MONTH, MONTH(B), TIMESTAMPADD(DAY, DAY(B), TIMESTAMPADD(SECOND, SECOND(B), TIMESTAMPADD(MINUTE, MINUTE(B), TIMESTAMPADD(HOUR, HOUR(B), A))))))
$$
;

CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.DATE_ADD_UDF(A DATE, B DATE)
RETURNS DATE
AS
$$
 DATEADD(YEAR, YEAR(B), DATEADD(MONTH, MONTH(B), DATEADD(DAY, DAY(B), A)))
$$
;

CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.DAY_OF_WEEK_LONG(VAL2 timestamp)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
AS
$$
    decode(dayname(val2)
    	 , 'Sun' ,'Sunday'
         , 'Mon' ,'Monday'
         , 'Tue' ,'Tuesday'
         , 'Wed' ,'Wednesday'
         , 'Thu' ,'Thursday'
         , 'Fri' ,'Friday'
         , 'Sat' ,'Saturday'
         ,'None')
$$
;

CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.MONTH_NAME_LONG(VAL2 timestamp)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
AS
$$
    decode(monthname(val2)
         , 'Jan' ,'January'
         , 'Feb' ,'February'
         , 'Mar' ,'March'
         , 'Apr' ,'April'
         , 'May' ,'May'
         , 'Jun' ,'June'
         , 'Jul' ,'July'
         , 'Aug' ,'August'
         , 'Sep' ,'September'
         , 'Oct' ,'October'
         , 'Nov' ,'November'
         , 'Dec' ,'December'
         ,'None')
$$
;

CREATE OR REPLACE FUNCTION SNOWCONVERT.PUBLIC.NULLIFZERO_UDF(VAL2 NUMBER)
RETURNS NUMBER
LANGUAGE SQL
AS
$$
    decode(val2)
         , 0 , NULL
         ,val2)
$$
;
