USE DATABASE ......;

CREATE SCHEMA SYS_CALENDAR;

CREATE TABLE Sys_Calendar.CALDATES (
cdate DATE /**** WARNING: FORMAT 'YY/MM/DD' NOT SUPPORTED ****/,
UNIQUE( cdate)
) ;

CREATE TABLE SYS_CALENDAR.TDBUSINESSCALENDARV(
  CALENDAR_TYPE VARCHAR(20),
  CALENDAR_DATE DATE,
  DAY_OF_WEEK INTEGER,
  DAY_OF_MONTH INTEGER,
  DAY_OF_YEAR INTEGER,
  DAY_OF_CALENDAR INTEGER,
  WEEKDAY_OF_MONTH INTEGER,
  WEEK_OF_MONTH INTEGER,
  WEEK_OF_QUARTER INTEGER,
  WEEK_OF_YEAR INTEGER,
  WEEK_OF_CALENDAR INTEGER,
  MONTH_OF_QUARTER INTEGER,
  MONTH_OF_YEAR INTEGER,
  MONTH_OF_CALENDAR INTEGER,
  QUARTER_OF_YEAR INTEGER,
  QUARTER_OF_CALENDAR INTEGER,
  YEAR_OF_CALENDAR INTEGER,

  WEEKBEGIN DATE,
  WEEKEND DATE,
  MONTHBEGIN DATE,
  MONTHEND DATE,
  QUARTERBEGIN DATE,
  QUARTEREND DATE,
  YEARBEGIN DATE,
  YEAREND DATE,
  ISBUSINESSDAY SMALLINT,

  BUSINESSWEEKBEGIN DATE,
  BUSINESSWEEKEND DATE,
  BUSINESSMONTHBEGIN DATE,
  BUSINESSMONTHEND DATE,
  BUSINESSQUARTERBEGIN DATE,
  BUSINESSQUARTEREND DATE,
  BUSINESSYEARBEGIN DATE,
  BUSINESSYEAREND DATE);

CREATE VIEW SYS_CALENDAR.BUSINESSCALENDAR 
  COMMENT = 'Table supports migrated default Teradata business calendar'
  AS
  SELECT * FROM 
  SYS_CALENDAR.TDBUSINESSCALENDARV 
  WHERE CALENDAR_TYPE = 'Teradata';

CREATE OR REPLACE VIEW SYS_CALENDAR.CALBASICS (
calendar_date,
day_of_calendar,
day_of_month,
day_of_year,
month_of_year,
year_of_calendar)
AS
   SELECT
   cdate,
   case
       when ((TRUNC((mod((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 10000)) / 100)) > 2) then TRUNC(
   (146097 * (TRUNC((TRUNC((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate)/10000) + 1900) / 100))) / 4)
   + TRUNC((1461 * ((TRUNC((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate)/10000) + 1900) - (TRUNC((TRUNC((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate)/10000) + 1900) / 100))*100) ) / 4)
   + TRUNC((153 * ((TRUNC((mod((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 10000))/100)) - 3) + 2) / 5)
   + mod((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100) - 693901
   else TRUNC(
   (146097 * (TRUNC(((TRUNC((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate)/10000) + 1900) - 1) / 100))) / 4)
   + TRUNC((1461 * (((TRUNC((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate)/10000) + 1900) - 1) - (TRUNC(((TRUNC((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate)/10000) + 1900) - 1) / 100))*100) ) / 4)
   + TRUNC((153 * ((TRUNC((mod((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 10000))/100)) + 9) + 2) / 5)
   + mod( (YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100) - 693901
   end,
   mod((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100),
   (case TRUNC( (mod((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 10000))/100)
   when 1  then mod( (YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100)
   when 2  then mod( (YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100) + 31
   when 3  then mod( (YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100) + 59
   when 4  then mod( (YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100) + 90
   when 5  then mod( (YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100) + 120
   when 6  then mod( (YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100) + 151
   when 7  then mod( (YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100) + 181
   when 8  then mod( (YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100) + 212
   when 9  then mod( (YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100) + 243
   when 10 then mod( (YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100) + 273
   when 11 then mod( (YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100) + 304
   when 12 then mod( (YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 100) + 334
   end)
   +
   (case
     when (((mod((TRUNC((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate) / 10000) + 1900), 4) = 0) AND (mod((TRUNC((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate) / 10000) + 1900), 100) <> 0)) OR
   (mod((TRUNC((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate) / 10000) + 1900), 400) = 0)) AND (TRUNC((mod((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 10000))/100) > 2) then
   1
 else
   0
end),TRUNC(
   (mod((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate), 10000))/100),TRUNC((YEAR(cdate) - 1900) * 10000 + MONTH(cdate) * 100 + DAY(cdate)/10000)
 FROM SYS_CALENDAR.CALDATES ;

CREATE OR REPLACE VIEW SYS_CALENDAR.CALENDARTMP (
calendar_date,
day_of_week,
day_of_month,
day_of_year,
day_of_calendar,
weekday_of_month,
week_of_month,
week_of_year,
week_of_calendar,
month_of_quarter,
month_of_year,
month_of_calendar,
quarter_of_year,
quarter_of_calendar,
year_of_calendar)
AS
   SELECT
   calendar_date,mod(
   (day_of_calendar + 0), 7) + 1,
   day_of_month,
   day_of_year,
   day_of_calendar,TRUNC(
   (day_of_month - 1) / 7) + 1,TRUNC(
   (day_of_month - mod( (day_of_calendar + 0), 7) + 6) / 7),TRUNC(
   (day_of_year - mod( (day_of_calendar + 0), 7) + 6) / 7),TRUNC(
   (day_of_calendar - mod( (day_of_calendar + 0), 7) + 6) / 7),mod(
   (month_of_year - 1), 3) + 1,
   month_of_year,
   month_of_year + 12 * year_of_calendar,TRUNC(
   (month_of_year + 2) / 3),TRUNC(
   (month_of_year + 2) / 3) + 4 * year_of_calendar,
   year_of_calendar + 1900
 FROM SYS_CALENDAR.CALBASICS;

CREATE OR REPLACE VIEW SYS_CALENDAR.CALENDAR_TD_ISO_COMPATIBLE (
calendar_date,
day_of_week,
day_of_month,
day_of_year,
day_of_calendar,
weekday_of_month,
--week_of_month,
week_of_year,
--week_of_calendar,
month_of_quarter,
month_of_year,
--month_of_calendar,
quarter_of_year,
--quarter_of_calendar,
year_of_calendar)
AS
  SELECT
  calendar_date,
  DAYOFWEEKISO(calendar_date),
  DAYOFMONTH(calendar_date),
  DAYOFYEAR(calendar_date),
  SNOWCONVERT.PUBLIC.DayNumber_Of_Calendar_UDF(calendar_date),
  TRUNC((DAYOFMONTH(calendar_date)/7))+1,
  --WeekNumber_Of_Month(calendar_date),
  extract(weekiso, calendar_date),
  --WeekNumber_Of_Calendar(calendar_date),
  MOD(MONTH(calendar_date),3),
  MONTH(calendar_date),
  --month_of_calendar,
  QUARTER(calendar_date),
  --quarter_of_calendar,
  YEAR(calendar_date)
FROM SYS_CALENDAR.CALENDARTMP;


CREATE OR REPLACE VIEW Sys_Calendar.CALENDAR(
  calendar_date,
  day_of_week,
  day_of_month,
  day_of_year,
  --day_of_calendar,
  weekday_of_month,
  --week_of_month,
  week_of_year,
  --week_of_calendar,
  month_of_quarter,
  month_of_year,
  --month_of_calendar,
  quarter_of_year,
  --quarter_of_calendar,
  year_of_calendar)
AS
SELECT
  calendar_date,
  DAYOFWEEKISO(calendar_date),
  DAYOFMONTH(calendar_date),
  DAYOFYEAR(calendar_date),
  --DayNumber_Of_Calendar(calendar_date),
  TRUNC((DAYOFMONTH(calendar_date)/7))+1,
  --WeekNumber_Of_Month(calendar_date),
  extract(weekiso, calendar_date),
  --WeekNumber_Of_Calendar(calendar_date),
  MOD(MONTH(calendar_date),3),
  Month(calendar_date),
  --month_of_calendar,
  Quarter(calendar_date),
  --quarter_of_calendar,
  Year(calendar_date)
FROM Sys_Calendar.CALENDARTMP;