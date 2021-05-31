# Script Overview

        The script originally was intended to migrate DDL from a bunch of database engines but not specifically for Redshift.

## Scripts issues detected: 


### Syntax issue with CREATE OR REPLACE

        At first glance when it was executed we noticed that it migrated the create table syntax as: 
```sql
CREATE TABLE TEST IF NOT EXISTS...
```

        as on redshift the if not exists syntax is preferred rather than the "or replace syntax". The scripts was edited to ignore the IF NOT EXISTS syntax as it will always add the REPLACE syntax so when migrate this we will get the following result:

```sql
CREATE TABLE TEST IF NOT EXISTS...
```

to

```sql
CREATE OR REPLACE TABLE TEST...
```

        By getting the same results when the original script contains or not the IF NOT EXISTS syntax.

### Not considering the other types of redshift tables

On  redshift we have the following tables:

* Physical tables
* Temporary tables with different syntax
    * Temp syntax
    * Temp tables with # syntax
    * Temporary tables with Temporary syntax

The code was simply ignoring the syntax when migrating. So the script was altered to pick up these type of syntax and identify if needed to migrate with the temporary syntax in order to create a temporary table syntax on snowflake such as:


```sql
CREATE OR REPLACE TEMPORARY TABLE TEST....

```

## How to execute the script

```bash
python COM-ES-Scripts-sql2sf.py [input folder path] [output folder path]

```
* input folder:
  * Route of the folder that contains the scripts that needs to migrate from redshift to snowflake.
* output folder:
  * Where the scripts migrated will be after the script execution.

### Code changes on the script execution
        The script originally accepts three parameters, one of them was optional by indicating if comments have to be migrated,
        the first parameter was to indicate the script to migrate path and the destination path.


        The previously was changed in order to accept as first parameter the folder where the scripts that needs to be migrated from redshift to snowflake and a desired output folder where the script will create the migrated results from the input folder.

        This script will work on linux/Mac environment without any code change, on windows we need to change the route concatenation on line 1210 and 1211




# Redshift tables.

        With the help of the view provided by AWS Redfshift team we can obtain this information by querying the view.

```sql
--DROP VIEW admin.v_generate_tbl_ddl;
/**********************************************************************************************
Purpose: View to get the DDL for a table.  This will contain the distkey, sortkey, constraints,
         not null, defaults, etc.
Notes:   Default view ordering causes foreign keys to be created at the end.
         This is needed due to dependencies of the foreign key constraint and the tables it
         links.  Due to this one should not manually order the output if you are expecting to
         be able to replay the SQL directly from the VIEW query result. It is still possible to
         order if you filter out the FOREIGN KEYS and then apply them later.
         The following filters are useful:
           where ddl not like 'ALTER TABLE %'  -- do not return FOREIGN KEY CONSTRAINTS
           where ddl like 'ALTER TABLE %'      -- only get FOREIGN KEY CONSTRAINTS
           where tablename in ('t1', 't2')     -- only get DDL for specific tables
           where schemaname in ('s1', 's2')    -- only get DDL for specific schemas
         So for example if you want to order DDL on tablename and only want the tables 't1', 't2'
         and 't4' you can do so by using a query like:
           select ddl from (
             (
               select
                 *
               from admin.v_generate_tbl_ddl
               where ddl not like 'ALTER TABLE %'
               order by tablename
             )
             UNION ALL
             (
               select
                 *
               from admin.v_generate_tbl_ddl
               where ddl like 'ALTER TABLE %'
               order by tablename
             )
           ) where tablename in ('t1', 't2', 't4');
History:
2014-02-10 jjschmit Created
2015-05-18 ericfe Added support for Interleaved sortkey
2015-10-31 ericfe Added cast tp increase size of returning constraint name
2016-05-24 chriz-bigdata Added support for BACKUP NO tables
2017-05-03 pvbouwel Change table & schemaname of Foreign key constraints to allow for filters
2018-01-15 pvbouwel Add QUOTE_IDENT for identifiers (schema,table and column names)
2018-05-30 adedotua Add table_id column
2018-05-30 adedotua Added ENCODE RAW keyword for non compressed columns (Issue #308)
2018-10-12 dmenin Added table ownership to the script (as an alter table statment as the owner of the table is the issuer of the CREATE TABLE command)
2019-03-24 adedotua added filter for diststyle AUTO distribution style
2020-11-11 leisersohn Added COMMENT section
2021-25-03 venkat.yerneni Fixed Table COMMENTS and added Column COMMENTS
**********************************************************************************************/
CREATE OR REPLACE VIEW v_generate_tbl_ddl
AS
SELECT
 table_id
 ,REGEXP_REPLACE (schemaname, '^zzzzzzzz', '') AS schemaname
 ,REGEXP_REPLACE (tablename, '^zzzzzzzz', '') AS tablename
 ,seq
 ,ddl
FROM
 (
 SELECT
  table_id
  ,schemaname
  ,tablename
  ,seq
  ,ddl
 FROM
  (
  --DROP TABLE
  SELECT
   c.oid::bigint as table_id
   ,n.nspname AS schemaname
   ,c.relname AS tablename
   ,0 AS seq
   ,'--DROP TABLE ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relname) + ';' AS ddl
  FROM pg_namespace AS n
  INNER JOIN pg_class AS c ON n.oid = c.relnamespace
  WHERE c.relkind = 'r'
  --CREATE TABLE
  UNION SELECT
   c.oid::bigint as table_id
   ,n.nspname AS schemaname
   ,c.relname AS tablename
   ,2 AS seq
   ,'CREATE TABLE IF NOT EXISTS ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relname) + '' AS ddl
  FROM pg_namespace AS n
  INNER JOIN pg_class AS c ON n.oid = c.relnamespace
  WHERE c.relkind = 'r'
  --OPEN PAREN COLUMN LIST
  UNION SELECT c.oid::bigint as table_id,n.nspname AS schemaname, c.relname AS tablename, 5 AS seq, '(' AS ddl
  FROM pg_namespace AS n
  INNER JOIN pg_class AS c ON n.oid = c.relnamespace
  WHERE c.relkind = 'r'
  --COLUMN LIST
  UNION SELECT
   table_id
   ,schemaname
   ,tablename
   ,seq
   ,'\t' + col_delim + col_name + ' ' + col_datatype + ' ' + col_nullable + ' ' + col_default + ' ' + col_encoding AS ddl
  FROM
   (
   SELECT
    c.oid::bigint as table_id
   ,n.nspname AS schemaname
    ,c.relname AS tablename
    ,100000000 + a.attnum AS seq
    ,CASE WHEN a.attnum > 1 THEN ',' ELSE '' END AS col_delim
    ,QUOTE_IDENT(a.attname) AS col_name
    ,CASE WHEN STRPOS(UPPER(format_type(a.atttypid, a.atttypmod)), 'CHARACTER VARYING') > 0
      THEN REPLACE(UPPER(format_type(a.atttypid, a.atttypmod)), 'CHARACTER VARYING', 'VARCHAR')
     WHEN STRPOS(UPPER(format_type(a.atttypid, a.atttypmod)), 'CHARACTER') > 0
      THEN REPLACE(UPPER(format_type(a.atttypid, a.atttypmod)), 'CHARACTER', 'CHAR')
     ELSE UPPER(format_type(a.atttypid, a.atttypmod))
     END AS col_datatype
    ,CASE WHEN format_encoding((a.attencodingtype)::integer) = 'none'
     THEN 'ENCODE RAW'
     ELSE 'ENCODE ' + format_encoding((a.attencodingtype)::integer)
     END AS col_encoding
    ,CASE WHEN a.atthasdef IS TRUE THEN 'DEFAULT ' + adef.adsrc ELSE '' END AS col_default
    ,CASE WHEN a.attnotnull IS TRUE THEN 'NOT NULL' ELSE '' END AS col_nullable
   FROM pg_namespace AS n
   INNER JOIN pg_class AS c ON n.oid = c.relnamespace
   INNER JOIN pg_attribute AS a ON c.oid = a.attrelid
   LEFT OUTER JOIN pg_attrdef AS adef ON a.attrelid = adef.adrelid AND a.attnum = adef.adnum
   WHERE c.relkind = 'r'
     AND a.attnum > 0
   ORDER BY a.attnum
   )
  --CONSTRAINT LIST
  UNION (SELECT
   c.oid::bigint as table_id
   ,n.nspname AS schemaname
   ,c.relname AS tablename
   ,200000000 + CAST(con.oid AS INT) AS seq
   ,'\t,' + pg_get_constraintdef(con.oid) AS ddl
  FROM pg_constraint AS con
  INNER JOIN pg_class AS c ON c.relnamespace = con.connamespace AND c.oid = con.conrelid
  INNER JOIN pg_namespace AS n ON n.oid = c.relnamespace
  WHERE c.relkind = 'r' AND pg_get_constraintdef(con.oid) NOT LIKE 'FOREIGN KEY%'
  ORDER BY seq)
  --CLOSE PAREN COLUMN LIST
  UNION SELECT c.oid::bigint as table_id,n.nspname AS schemaname, c.relname AS tablename, 299999999 AS seq, ')' AS ddl
  FROM pg_namespace AS n
  INNER JOIN pg_class AS c ON n.oid = c.relnamespace
  WHERE c.relkind = 'r'
  --BACKUP
  UNION SELECT
  c.oid::bigint as table_id
   ,n.nspname AS schemaname
   ,c.relname AS tablename
   ,300000000 AS seq
   ,'BACKUP NO' as ddl
FROM pg_namespace AS n
  INNER JOIN pg_class AS c ON n.oid = c.relnamespace
  INNER JOIN (SELECT
    SPLIT_PART(key,'_',5) id
    FROM pg_conf
    WHERE key LIKE 'pg_class_backup_%'
    AND SPLIT_PART(key,'_',4) = (SELECT
      oid
      FROM pg_database
      WHERE datname = current_database())) t ON t.id=c.oid
  WHERE c.relkind = 'r'
  --BACKUP WARNING
  UNION SELECT
  c.oid::bigint as table_id
   ,n.nspname AS schemaname
   ,c.relname AS tablename
   ,1 AS seq
   ,'--WARNING: This DDL inherited the BACKUP NO property from the source table' as ddl
FROM pg_namespace AS n
  INNER JOIN pg_class AS c ON n.oid = c.relnamespace
  INNER JOIN (SELECT
    SPLIT_PART(key,'_',5) id
    FROM pg_conf
    WHERE key LIKE 'pg_class_backup_%'
    AND SPLIT_PART(key,'_',4) = (SELECT
      oid
      FROM pg_database
      WHERE datname = current_database())) t ON t.id=c.oid
  WHERE c.relkind = 'r'
  --DISTSTYLE
  UNION SELECT
   c.oid::bigint as table_id
   ,n.nspname AS schemaname
   ,c.relname AS tablename
   ,300000001 AS seq
   ,CASE WHEN c.reldiststyle = 0 THEN 'DISTSTYLE EVEN'
    WHEN c.reldiststyle = 1 THEN 'DISTSTYLE KEY'
    WHEN c.reldiststyle = 8 THEN 'DISTSTYLE ALL'
    WHEN c.reldiststyle = 9 THEN 'DISTSTYLE AUTO'
    ELSE '<<Error - UNKNOWN DISTSTYLE>>'
    END AS ddl
  FROM pg_namespace AS n
  INNER JOIN pg_class AS c ON n.oid = c.relnamespace
  WHERE c.relkind = 'r'
  --DISTKEY COLUMNS
  UNION SELECT
   c.oid::bigint as table_id
   ,n.nspname AS schemaname
   ,c.relname AS tablename
   ,400000000 + a.attnum AS seq
   ,' DISTKEY (' + QUOTE_IDENT(a.attname) + ')' AS ddl
  FROM pg_namespace AS n
  INNER JOIN pg_class AS c ON n.oid = c.relnamespace
  INNER JOIN pg_attribute AS a ON c.oid = a.attrelid
  WHERE c.relkind = 'r'
    AND a.attisdistkey IS TRUE
    AND a.attnum > 0
  --SORTKEY COLUMNS
  UNION select table_id,schemaname, tablename, seq,
       case when min_sort <0 then 'INTERLEAVED SORTKEY (' else ' SORTKEY (' end as ddl
from (SELECT
   c.oid::bigint as table_id
   ,n.nspname AS schemaname
   ,c.relname AS tablename
   ,499999999 AS seq
   ,min(attsortkeyord) min_sort FROM pg_namespace AS n
  INNER JOIN  pg_class AS c ON n.oid = c.relnamespace
  INNER JOIN pg_attribute AS a ON c.oid = a.attrelid
  WHERE c.relkind = 'r'
  AND abs(a.attsortkeyord) > 0
  AND a.attnum > 0
  group by 1,2,3,4 )
  UNION (SELECT
   c.oid::bigint as table_id
   ,n.nspname AS schemaname
   ,c.relname AS tablename
   ,500000000 + abs(a.attsortkeyord) AS seq
   ,CASE WHEN abs(a.attsortkeyord) = 1
    THEN '\t' + QUOTE_IDENT(a.attname)
    ELSE '\t, ' + QUOTE_IDENT(a.attname)
    END AS ddl
  FROM  pg_namespace AS n
  INNER JOIN pg_class AS c ON n.oid = c.relnamespace
  INNER JOIN pg_attribute AS a ON c.oid = a.attrelid
  WHERE c.relkind = 'r'
    AND abs(a.attsortkeyord) > 0
    AND a.attnum > 0
  ORDER BY abs(a.attsortkeyord))
  UNION SELECT
   c.oid::bigint as table_id
   ,n.nspname AS schemaname
   ,c.relname AS tablename
   ,599999999 AS seq
   ,'\t)' AS ddl
  FROM pg_namespace AS n
  INNER JOIN  pg_class AS c ON n.oid = c.relnamespace
  INNER JOIN  pg_attribute AS a ON c.oid = a.attrelid
  WHERE c.relkind = 'r'
    AND abs(a.attsortkeyord) > 0
    AND a.attnum > 0
  --END SEMICOLON
  UNION SELECT c.oid::bigint as table_id ,n.nspname AS schemaname, c.relname AS tablename, 600000000 AS seq, ';' AS ddl
  FROM  pg_namespace AS n
  INNER JOIN pg_class AS c ON n.oid = c.relnamespace
  WHERE c.relkind = 'r' 
  --COMMENT
  UNION
  SELECT c.oid::bigint AS table_id,
       n.nspname     AS schemaname,
       c.relname     AS tablename,
       600250000     AS seq,
       ('COMMENT ON '::text + nvl2(cl.column_name, 'column '::text, 'table '::text) + quote_ident(n.nspname::text) + '.'::text + quote_ident(c.relname::text) + nvl2(cl.column_name, '.'::text + cl.column_name::text, ''::text) + ' IS \''::text + quote_ident(des.description) + '\'; '::text)::character VARYING AS ddl
  FROM pg_description des
  JOIN pg_class c ON c.oid = des.objoid
  JOIN pg_namespace n ON n.oid = c.relnamespace
  LEFT JOIN information_schema."columns" cl
  ON cl.ordinal_position::integer = des.objsubid AND cl.table_name::NAME = c.relname
  WHERE c.relkind = 'r'

  UNION
  --TABLE OWNERSHIP AS AN ALTER TABLE STATMENT
  SELECT c.oid::bigint as table_id ,n.nspname AS schemaname, c.relname AS tablename, 600500000 AS seq, 
  'ALTER TABLE ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relname) + ' owner to '+  QUOTE_IDENT(u.usename) +';' AS ddl
  FROM  pg_namespace AS n
  INNER JOIN pg_class AS c ON n.oid = c.relnamespace
  INNER JOIN pg_user AS u ON c.relowner = u.usesysid
  WHERE c.relkind = 'r'
  
  )
  UNION (
    SELECT c.oid::bigint as table_id,'zzzzzzzz' || n.nspname AS schemaname,
       'zzzzzzzz' || c.relname AS tablename,
       700000000 + CAST(con.oid AS INT) AS seq,
       'ALTER TABLE ' + QUOTE_IDENT(n.nspname) + '.' + QUOTE_IDENT(c.relname) + ' ADD ' + pg_get_constraintdef(con.oid)::VARCHAR(1024) + ';' AS ddl
    FROM pg_constraint AS con
      INNER JOIN pg_class AS c
             ON c.relnamespace = con.connamespace
             AND c.oid = con.conrelid
      INNER JOIN pg_namespace AS n ON n.oid = c.relnamespace
    WHERE c.relkind = 'r'
    AND con.contype = 'f'
    ORDER BY seq
  )
 ORDER BY table_id,schemaname, tablename, seq
 )
;
```
obtained from: https://github.com/awslabs/amazon-redshift-utils/blob/master/src/AdminViews/v_generate_tbl_ddl.sql


        After creating the view we can query the view to get the information for each specific table:

```sql
select ddl from v_generate_tbl_ddl where tablename='[DESIRED TABLE NAME]';
```

        After obtained the resultset, click on "Export", as "TXT". Just take in consideration that the extracted DDL might get double quotes on the reserved words on redshift like Time,day,month.

        Currently there is not an automatic extracion DDL process in place.


