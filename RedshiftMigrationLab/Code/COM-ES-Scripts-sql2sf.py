#!/usr/bin/python3
# $Id: $

# Converts Oracle, SQL-Server, and other DDL to Snowflake DDL
# 2014-03-04  hersker   initial coding
# 2014-03-20  hersker   add integer and float types
# 2014-04-07  hersker   add SQL-Server types, support multiple translations per line,
#                       disable BIGINT translation
# 2014-04-11  hersker   add Redshift DISTKEY/SORTKEY, disable SMALLINT translation
# 2014-08-28  hersker   strip more Oracle attributes and statements
# 2014-09-03  hersker   remove Redshift clauses: ENCODE, multiline SORTKEY, DISTSTYLE
# 2015-05-04  hersker   rewrite Oracle function calls
# 2015-10-20  hersker   remove alter table ... add primary key
# 2016-03-08  hersker   option to suppress output changes as comments
# 2018-01-19  meyendorff    improve distkey and sortkey, 
#                           add interleaved sortkey, bpchar, undocumented identity syntax,
#                           character varying, now default
# 2018-02-14 meyendorff add aurora translations for float(n,m), double(n,m), bigint,tinyint,smallint,mediumint types, 
#                       incorrect default types, keys, unique keys, charset, longtext, binary default 
# 2018-03-05 meyendorff add some memsql stuff: inline index, collation, enum, json, blob, on update clause
# 2020-01-27  hersker   convert Redshift time-specification trunc() to DATE_TRUNC()
# 2020-02-19  hersker   change Oracle type CLOB => string
#                       remove Oracle clauses: STORAGE, PARTITION BY RANGE, LOB, CACHE, 
#                           PCTFREE, PCTUSED, INITRANS, MAXTRANS, TABLESPACE, LOGGING, NOCOMPRESS,
#                           USING90, USING10, COMPUTE STATISTICS
# 2020-02-20  hersker   finish implementing the --no_comments option to suppress output changes as comments
#                       (started this feature in March 2016, sigh...)
# 2020-02-22  hersker   mark changed code with "--//" to distinguish from other comments already in the source SQL
#                       (applicable if --no_comments = False)
# 2020-05-27  acalvo    altered code to add scenario to avoid the "IF NOT EXISTS" syntax when creating a table for redshift and capturing
#                       only the schema.table_name for migration. This change does not alter the scenario of having a create table 
#                       for redshift originally without the "IF NOT EXISTS"
#


def usage():
    print ("""\
# Usage: sql2sf.py input-file [output-file]
    """)

import sys
import os, glob, errno
import shutil
from io import StringIO
import string, re
import argparse


### General RegExes
comment_line_re = re.compile('^\s*--.*$', re.IGNORECASE)
whitespace_line_re = re.compile('^\s*$', re.IGNORECASE)
comma_line_re = re.compile('^\s*,\s*$', re.IGNORECASE)


### RegExes for mysql dialect that Snowflake doesn't support

engine_re = re.compile('(.*)(engine\s*=[a-zA-Z]*\s*(?:DEFAULT)?)(.*)', re.IGNORECASE)

### RegExes for Oracle dialect that Snowflake doesn't support

# VARCHAR2(n BYTE) => VARCHAR(n)
varchar2_re = re.compile('(.*)(VARCHAR2\((\d+)(\s+.+)?\))(.*)', re.IGNORECASE)

# CHAR(n BYTE) => CHAR(n)
char_re = re.compile('(.*)(CHAR\((\d+)(\s+.+)\))(.*)', re.IGNORECASE)

# DEFAULT SYSDATE => deleted (OK only because data loaded from table should already have date)
# Snowflake DEFAULT must be literal
default_sysdate_re = re.compile('(.*)\ (DEFAULT SYSDATE)\ (.*)', re.IGNORECASE)

# SYSDATE => CURRENT_TIMESTAMP()
#sysdate_re = re.compile('(.*)\ (SYSDATE)\ (.*)', re.IGNORECASE)
sysdate_re = re.compile('(.*[,\(\s])(SYSDATE)([,\)\s].*)', re.IGNORECASE)

# SEGMENT CREATION type => ignore
segment_creation_re = re.compile('(.*)\ (SEGMENT\s+CREATION\s+(?:IMMEDIATE|DEFERRED))(.*)', re.IGNORECASE)

# NOT NULL ENABLE => NOT NULL
not_null_enable_re = re.compile('(.*)(NOT\s+NULL\s+ENABLE)(.*)', re.IGNORECASE)

# find prior period, e.g. trunc(col,'MM')-1 => dateadd('MM', -1, trunc(col, 'MM'))
prior_period_re = re.compile('(.*)(TRUNC\(\s*(.+?),\s*(\'.+?\')\s*\)\s*(-?\s*\d+))(.*)', re.IGNORECASE)

# add months, e.g. add_months(trunc(col, 'MM'), -5) => dateadd(month, -5, col)
add_months_re = re.compile('(.*)(ADD_MONTHS\(\s*TRUNC\(\s*(.+?),\s*(\'.+?\')\s*\),\s*(-?\s*\d+))(.*)', re.IGNORECASE)

# STORAGE => ignore through end of clause
storage_multiline_re = re.compile('(^\s*)(STORAGE\s*\(\s*)(.*)', re.IGNORECASE)

# PARTITION BY RANGE => ignore through end of clause
partition_by_range_multiline_re = re.compile('(^\s*)(PARTITION BY RANGE\s*\(\s*)(.*)', re.IGNORECASE)

# PARTITION ... VALUES => ignore through end of clause
partition_values_multiline_re = re.compile('(^\s*)(PARTITION .* VALUES LESS THAN\s*\(.*\))(.*)', re.IGNORECASE)

# LOB ... STORE AS => ignore through end of clause
lob_multiline_re = re.compile('(^\s*)(LOB \(.*\) STORE AS )(.*)', re.IGNORECASE)

# PCTFREE n => ignore
pctfree_re = re.compile('(.*)(PCTFREE\s+\S+)(.*)', re.IGNORECASE)

# PCTIUSED n => ignore
pctused_re = re.compile('(.*)(PCTUSED\s+\S+)(.*)', re.IGNORECASE)

# INITRANS n => ignore
initrans_re = re.compile('(.*)(INITRANS\s+\S+)(.*)', re.IGNORECASE)

# MAXTRANS n => ignore
maxtrans_re = re.compile('(.*)(MAXTRANS\s+\S+)(.*)', re.IGNORECASE)

# TABLESPACE n => ignore
tablespace_re = re.compile('(.*)(TABLESPACE\s+\S+)(.*)', re.IGNORECASE)

# LOGGING => ignore
logging_re = re.compile('(.*)(LOGGING)(.*)', re.IGNORECASE)

# NOCOMPRESS => ignore
nocompress_re = re.compile('(.*)(NOCOMPRESS)(.*)', re.IGNORECASE)

# CACHE => ignore
cache_re = re.compile('(.*\s+)(CACHE\s+)(.*)', re.IGNORECASE)

# USINGnn => ignore (e.g. USING90, USING10)
usingnn_re = re.compile('(.*\s+)(USING\d\d\s+)(.*)', re.IGNORECASE)

# COMPUTE STATISTICS => ignore
compute_statistics_re = re.compile('(.*)(COMPUTE STATISTICS)(.*)', re.IGNORECASE)

# Empty Comma => ignore (dropping out clauses can leave an empty comma)
empty_comma_re = re.compile('(\s*)(,)\s+(--.*)', re.IGNORECASE)

### RegExes for SQL-Server dialect that Snowflake doesn't support

# NULL (explicit NULL constraint) -- ignore
null_constraint_re = re.compile('(.*)((?<!NOT)\s+NULL(?!::))(.*)', re.IGNORECASE)
is_null_condition_re = re.compile('.*IS NULL.*', re.IGNORECASE)

# NVARCHAR => VARCHAR
nvarchar_re = re.compile('(.*)\ (NVARCHAR)(.*)', re.IGNORECASE)

# NVARCHAR => VARCHAR
nchar_re = re.compile('(.*)\ (NCHAR)(.*)', re.IGNORECASE)

# TEXTIMAGE_ON PRIMARY => ignore
textimageon_primary_re = re.compile('(.*)\ (TEXTIMAGE_ON PRIMARY)(.*)', re.IGNORECASE)

# USE => USE DATABASE
use_re = re.compile('(.*)(USE\s)(.*)', re.IGNORECASE)

# CREATE TABLE => CREATE OR REPLACE TABLE
#createtable_re = re.compile('(.*)(CREATE\sTABLE\s)(.*)', re.IGNORECASE)
#createtable_re = re.compile('(.*)(CREATE\sTABLE\s)(IF\sNOT\sEXISTS)?(.*)', re.IGNORECASE)
createtable_re = re.compile('(.*)(CREATE(\sTEMP\s|\sTEMPORARY\s|\s)TABLE\s)(IF\sNOT\sEXISTS)?(.*)', re.IGNORECASE)


# ON PRIMARY => ignore
on_primary_re = re.compile('(.*)\ (ON PRIMARY)(.*)', re.IGNORECASE)

# DATETIME => TIMESTAMP
datetime_re = re.compile('(.*)\ (DATETIME)(.*)', re.IGNORECASE)

# BIT => BOOLEAN
bit_re = re.compile('(.*)\ (BIT)\s*(?:\([0-9]\))(.*)', re.IGNORECASE)

# Constraint Primary key => ignore
constraint_primarykey_re = re.compile('(.*)(CONSTRAINT\s+.*PRIMARY KEY)(.*)', re.IGNORECASE)

# Constraint Primary key => ignore
constraint_primarykey_end_re = re.compile('(.*)(WITH\s+.*PAD_INDEX\s+.*STATISTICS_NORECOMPUTE\s.*IGNORE_DUP_KEY\s.*ON)(.*)', re.IGNORECASE)

# Constraint UNIQUE key => ignore
constraint_unique_re = re.compile('(.*)(CONSTRAINT\s+.*UNIQUE)(.*)', re.IGNORECASE)

# END all constraints => ignore
constraint_end_re = re.compile('(.*)(WITH\s+.*PAD_INDEX\s+.*STATISTICS_NORECOMPUTE\s.*IGNORE_DUP_KEY\s.*ON)(.*)', re.IGNORECASE)

# ALTER TABLE...ADD CONSTRAINT => ignore
addconstraint_re = re.compile('(.*)(ALTER\s+TABLE\s+.*ADD\s+CONSTRAINT)(.*)', re.IGNORECASE)

uniqueidentifier_re = re.compile('(.*)(uniqueidentifier)(.*)', re.IGNORECASE)

go_re = re.compile('(.*)(^GO\s*$)(.*)')

nonclustered_re = re.compile('(.*)(NONCLUSTERED)(.*)', re.IGNORECASE)

max_re = re.compile('(.*)(\\(max\\))(.*)', re.IGNORECASE)

ASC_re = re.compile('(.*)(\s+ASC\s+)(.*)')

DESC_re = re.compile('(.*)(\s+DESC\s+)(.*)')


### RegExes for Redshift dialect that Snowflake doesn't support

# DISTKEY(col) => ignore
# DISTKEY => ignore
distkey_re = re.compile('(.*\s+)(DISTKEY\s*(?:\(.*?\))?)(.*)', re.IGNORECASE)

# SORTKEY(col) => ignore
# SORTKEY => ignore
sortkey_re = re.compile('(.*\s+)(SORTKEY\s*(?:\(.*?\))?)(,?.*)', re.IGNORECASE)

# SORTKEY => ignore through end of statement
sortkey_multiline_re = re.compile('(^\s*)(SORTKEY\s*\(?\s*$)(.*)', re.IGNORECASE)

# ENCODE type => ignore
encode_re = re.compile('(.*)(\sENCODE\s+.+?)((?:,|\s+|$).*)', re.IGNORECASE)

# DISTSTYLE type => ignore
diststyle_re = re.compile('(.*)(\s*DISTSTYLE\s+.+?)((?:,|\s+|$).*)', re.IGNORECASE)

# 'now'::character varying => current_timestamp
now_character_varying_re = re.compile('(.*)(\'now\'::(?:character varying|text))(.*)', re.IGNORECASE)

# bpchar => char
bpchar_re = re.compile('(.*)(bpchar)(.*)', re.IGNORECASE)

# character varying => varchar
character_varying_re = re.compile('(.*)(character varying)(.*)')

# interleaved => ignore
interleaved_re = re.compile('(.*)(interleaved)(.*)', re.IGNORECASE)

# identity(start, 0, ([0-9],[0-9])::text) => identity(start, 1)
identity_re = re.compile('(.*)\s*DEFAULT\s*"?identity"?\(([0-9]*),.*?(?:.*?::text)\)(.*)', re.IGNORECASE)

# trunc((CURRENT_TIMESTAMP)::timestamp) => date_trunc('DAY', CURRENT_TIMESTAMP)     # Redshift 'now' will have been resolved by now_character_varying_re to CURRENT_TIMESTAMP
trunc_re = re.compile('(.*)((?:trunc\(\()(.*)(?:\)::timestamp.*\)))(.*)', re.IGNORECASE)


### RegExes for Netezza dialect that Snowflake doesn't support

## casting syntax
# INT4(expr) => expr::INTEGER
int4_re = re.compile('(.*)\ (INT4\s*\((.*?)\))(.*)', re.IGNORECASE)

### RegExes for common/standard types that Snowflake doesn't support
# bigint_re = re.compile('(.*)\ ((?:BIGINT|TINYINT|SMALLINT)\s*\(.*\))(.*)', re.IGNORECASE)
#smallint_re = re.compile('(.*)\ (SMALLINT)(.*)', re.IGNORECASE)
floatN_re = re.compile('(.*)\ (FLOAT\d+)(.*)', re.IGNORECASE)

# CREATE [type] INDEX => ignore through end of statement
index_re = re.compile('(.*)(CREATE(?:\s+(?:UNIQUE|BITMAP))?\ INDEX)(.*)', re.IGNORECASE)

# ALTER TABLE ... ADD PRIMARY KEY => ignore
pk_re = re.compile('(.*)(ALTER\s+TABLE\s+.*ADD\s+PRIMARY\s+KEY)(.*)', re.IGNORECASE)

# SET ... TO => ignore
set_re = re.compile('(.*)(SET\s+.*TO)(.*)', re.IGNORECASE)

statement_term_re = re.compile('(.*);(.*)', re.IGNORECASE)
clause_term_re = re.compile('(.*)\)(.*)', re.IGNORECASE)

### Regexes for Aurora dialect that Snowflake doesn't support

otherint_re = re.compile('(.*)\ ((?:BIGINT|TINYINT|SMALLINT|MEDIUMINT)\s*\(.*\))(.*)', re.IGNORECASE)

key_re = re.compile('(.*)(,.*KEY.*\(.*\)\s*)(.*)', re.IGNORECASE)

unique_key_re = re.compile('(.*)(\s*UNIQUE KEY.*?(\(.*?\)))(.*)', re.IGNORECASE)

int_re = re.compile('(.*)\ (INT\s*\((?:.*?)\))(.*)', re.IGNORECASE)

charset_re = re.compile('(.*)((?:DEFAULT)?(?:CHARACTER SET|CHARSET)\s*=?\s*utf8)(.*)', re.IGNORECASE)

auto_increment_re = re.compile('(.*)(auto_increment)(.*)', re.IGNORECASE)

decimal_re = re.compile('(.*)(decimal\(([0-9]*),([0-9]*)\))(.*)', re.IGNORECASE)

float_double_re = re.compile('(.*)((float|double)\([0-9]*,[0-9]*\))(.*)', re.IGNORECASE)

text_types_re = re.compile('(.*)((?:LONG|MEDIUM)TEXT)(.*)', re.IGNORECASE)

uncommented_set_re = re.compile('(.*)(^SET)(.*)', re.IGNORECASE)

unsigned_re = re.compile('(.*)(unsigned)(.*)', re.IGNORECASE)

default_zero_re = re.compile('(.*)(default\s*\'0\')(.*)', re.IGNORECASE)

default_zero_date_re = re.compile('(.*)(default\s*\'0000-00-00\')(?:\s+|$)(.*)', re.IGNORECASE)

default_zero_ts_re = re.compile('(.*)(default\s*\'0000-00-00 00:00:00(?:\.0*)?\')(?:\s+|$)(.*)', re.IGNORECASE)

binary_default_re = re.compile('(.*)(BINARY.*?)(DEFAULT.*)', re.IGNORECASE)

### Regexes for Memsql dialect that Snowflake doesn't support
collate_re = re.compile('(.*)(COLLATE\s?=?\s?[a-zA-Z0-9_]*)(.*)', re.IGNORECASE)

inline_index_re = re.compile('(.*)(\s+INDEX\s*[a-zA-Z0-9_]*\s*(?:\(.*?\))?)(.*)', re.IGNORECASE)

enum_re = re.compile('(.*)(ENUM\(.*\))(.*)', re.IGNORECASE)

on_update_re = re.compile('(.*)(ON UPDATE CURRENT_TIMESTAMP)(.*)', re.IGNORECASE)

json_re = re.compile('(.*)(JSON)(.*)', re.IGNORECASE)

blob_re = re.compile('(.*)(BLOB)(.*)', re.IGNORECASE)
clob_re = re.compile('(.*)(CLOB)(.*)', re.IGNORECASE)

# Convert source SQL to Snowflake SQL
def make_snow(sqlin, sqlout, no_comments):
    ### processing mode
    comment_lines = None
    term_re = None

    for line in sqlin:
        ### state variables
        pre = None
        clause = None
        post = None
        comment = None

        sql = line.rstrip()
        sql = sql.replace('[', '').replace(']', '')
        sql = sql.replace('`', '')

        # print >> sys.stdout, 'input: ' + sql

        # if current line is already fully commented, don't bother with any matching
        result = comment_line_re.match(sql)
        if result:
            write_line(sqlout, sql, comment)
            continue
        
        # if current line is already all whitespace, don't bother with any matching
        result = whitespace_line_re.match(sql)
        if result:
            write_line(sqlout, sql, comment)
            continue

        # if we're commenting out multiple lines, check if this is the last
        if comment_lines:
            result = term_re.match(sql)
            if result:
                comment_lines = None
                term_re = None
            comment = append_comment(comment, sql, no_comments)
            sql = None
            write_line(sqlout, sql, comment)
            continue

        # ENGINE => ignore
        result = engine_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # VARCHAR2(n BYTE) => VARCHAR(n)
        result = varchar2_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)     # varchar2 clause
            cnt = result.group(3)
            discard = result.group(4)
            post = result.group(5)
            sql = '{0}{1}({2}){3}'.format(pre, clause[0:7], cnt, post)
            comment = append_comment(comment, clause, no_comments)

        # CHAR(n BYTE) => CHAR(n)
        result = char_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)     # char clause
            cnt = result.group(3)
            discard = result.group(4)
            post = result.group(5)
            sql = '{0}{1}({2}){3}'.format(pre, clause[0:4], cnt, post)
            comment = append_comment(comment, clause, no_comments)

        # DEFAULT SYSDATE => deleted (OK only because data loaded from table should already have date)
        result = default_sysdate_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # NVARCHAR => VARCHAR
        result = nvarchar_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} VARCHAR {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # NCHAR => CHAR
        result = nchar_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} CHAR {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # DATETIME => TIMESTAMP
        result = datetime_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} TIMESTAMP {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # BIGINT => INTEGER
        # result = bigint_re.match(sql)
        # if result:
        #    pre = result.group(1)
        #    clause = result.group(2)
        #    post = result.group(3)
        #    sql = '{0} INTEGER {1}\t\t-- {2}'.format(pre, post, clause)

        # SMALLINT => INTEGER
        #result = smallint_re.match(sql)
        #if result:
        #    pre = result.group(1)
        #    clause = result.group(2)
        #    post = result.group(3)
        #    sql = '{0} INTEGER {1}\t\t-- {2}'.format(pre, post, clause)

        # BIT => BOOLEAN
        result = bit_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} BOOLEAN {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # Primary Key Constraint => ignore through end of statement
        result = constraint_primarykey_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} {2} {1}'.format(pre, post, clause)

        # UNIQUE Key Constraint => ignore through end of statement
        result = constraint_unique_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}/* {2} {1}'.format(pre, post, clause)

        # End Key Constraint => ignore through end of statement
        result = constraint_primarykey_end_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = pre
            str = '{0} {1}'.format(clause, post)
            comment = append_comment(comment, str, no_comments)

        # End Key Constraint => ignore through end of statement
        result = constraint_end_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} {2} {1}*/'.format(pre, post, clause)

        # ALTER TABLE...ADD CONSTRAINT => ignore through end of statement
        result = addconstraint_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = pre
            str = '{0} {1}'.format(clause, post)
            comment = append_comment(comment, str, no_comments)
            comment_lines = 1
            term_re = statement_term_re

        # FLOAT8 => FLOAT
        result = floatN_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} FLOAT {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # # NULL (without NOT) => implicit nullable
        # result = null_constraint_re.match(sql)
        # if result and is_null_condition_re.match(sql):
        #     # we are in query or DML, so not looking at a constraint
        #     result = None
        # if result:
        #     pre = result.group(1)
        #     clause = result.group(2)
        #     post = result.group(3)
        #     sql = '{0}{1}\t\t-- {2}'.format(pre, post, clause)

        # TEXTIMAGEON PRIMARY => ignore
        result = textimageon_primary_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # USE => USE DATABASE
        result = use_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}USE DATABASE {1};'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # USE => USE DATABASE
        result = createtable_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(5)

            if clause.find("TEMP") > 0 or clause.find("#") > 0 :
                sql = '{0}CREATE OR REPLACE TEMPORARY TABLE {1}'.format(pre, post)
            else:
                sql = '{0}CREATE OR REPLACE TABLE {1}'.format(pre, post.replace("#",""))
                
            comment = append_comment(comment, clause, no_comments)

        # ON PRIMARY => ignore
        result = on_primary_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # DISTKEY(col) => ignore
        result = distkey_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # SORTKEY => ignore through end of statement
        result = sortkey_multiline_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = pre
            str = '{1} {0}'.format(post, clause)
            comment = append_comment(comment, str, no_comments)
            comment_lines = 1
            term_re = statement_term_re

        # SORTKEY(col) => ignore
        result = sortkey_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # KEY(col) => ignore
        result = key_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # UNIQUE KEY(col) => UNIQUE(col)
        result = unique_key_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            expression = result.group(3)
            post = result.group(4)
            sql = '{0} UNIQUE {2} {1}'.format(pre, post, expression)
            comment = append_comment(comment, clause, no_comments)

        #character set utf8 => ignore
        result = charset_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        #auto_increment => autoincrement
        result = auto_increment_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}AUTOINCREMENT{1}'.format(pre, post);
            comment = append_comment(comment, clause, no_comments)

        #unsigned => ignore
        result = unsigned_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        #default '0' => default 0
        result = default_zero_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}DEFAULT 0{1}'.format(pre, post, clause);
            comment = append_comment(comment, clause, no_comments)

        #default '0000-00-00' => default '0000-00-00'::date
        result = default_zero_date_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}::DATE{2}'.format(pre, clause, post);
            comment = append_comment(comment, clause, no_comments)

        #default '0000-00-00 00:00:00' => default '0000-00-00 00:00:00'::timestamp
        result = default_zero_ts_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}::TIMESTAMP{2}'.format(pre, clause, post);
            comment = append_comment(comment, clause, no_comments)

        # binary default => binary ignore default
        result = binary_default_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        #decimal(n>38,m) => decimal(38,m)
        result = decimal_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            precision = result.group(3)
            scale = result.group(4)
            post = result.group(5)
            if int(precision)>38:
                precision=38
                sql = '{0}DECIMAL({3},{4}){1}'.format(pre, post, precision, scale)
                comment = append_comment(comment, clause, no_comments)

        #float|double(n,m) => float|double
        result = float_double_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            coltype = result.group(3)
            post = result.group(4)
            sql = '{0}{1}{2}'.format(pre, coltype, post)
            comment = append_comment(comment, clause, no_comments)

        #smallint|bigint|tinyint => integer
        result = otherint_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} INTEGER {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        #uniqueidentifier => string
        result = uniqueidentifier_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} string {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        #uniqueidentifier => string
        result = nonclustered_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        #max => ignore
        result = max_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        #ASC => ignore
        result = ASC_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        #DESC => ignore
        result = DESC_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        #uniqueidentifier => string
        result = go_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # longtext => string
        result = text_types_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} STRING {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # SET ... = ; => ignore
        result = uncommented_set_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = pre
            str = '{1}{0}'.format(post, clause)
            comment = append_comment(comment, str, no_comments)

        # ENCODE type => ignore
        result = encode_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # DISTSTYLE type => ignore
        result = diststyle_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # 'now'::(character varying|text) => current_timestamp
        result = now_character_varying_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}CURRENT_TIMESTAMP{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # bpchar => char
        result = bpchar_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}char{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # character varying => varchar
        result = character_varying_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}varchar{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # interleaved => ignore
        result = interleaved_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # redshift identity syntax => identity
        result = identity_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} IDENTITY({1},1) {2}'.format(pre,clause,post)

        # redshift date trunc syntax => date_trunc
        result = trunc_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            timespec = result.group(3)
            post = result.group(4)
            sql = '{0}DATE_TRUNC(\'DAY\', {1}) {2}'.format(pre, timespec, post)
            comment = append_comment(comment, clause, no_comments)

        result = int_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0} INTEGER {1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # SEGMENT CREATION type => ignore
        result = segment_creation_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = pre
            str = '{0} {1}'.format(clause, post)
            comment = append_comment(comment, str, no_comments)
            # comment_lines = 1
            # term_re = statement_term_re

        # INDEX CREATION => ignore through end of statement
        result = index_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = pre
            str = '{0} {1}'.format(clause, post)
            comment = append_comment(comment, str, no_comments)
            comment_lines = 1
            term_re = statement_term_re
            write_line(sqlout, sql, comment)
            continue

        # ALTER TABLE ... ADD PRIMARY KEY => ignore
        result = pk_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = pre
            str = '{0} {1}'.format(clause, post)
            comment = append_comment(comment, str, no_comments)
            comment_lines = 1
            term_re = statement_term_re

        # SET ... TO => ignore
        result = set_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = pre
            str = '{0} {1}'.format(clause, post)
            comment = append_comment(comment, str, no_comments)
            comment_lines = 1
            term_re = statement_term_re

        # NOT NULL ENABLE => NOT NULL
        result = not_null_enable_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}NOT NULL{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # COLLATE => ignore
        result = collate_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # Inline INDEX => ignore
        result = inline_index_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # enum => string
        result = enum_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}STRING{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # on update => ignore
        result = on_update_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # json => variant
        result = json_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}VARIANT{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # blob => string
        result = blob_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}STRING{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # clob => string (should we treat differently than blob?)
        result = clob_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}STRING{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # STORAGE => ignore through end of clause
        result = storage_multiline_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = pre
            str = '{0}{1}'.format(clause, post)
            comment = append_comment(comment, str, no_comments)
            comment_lines = 1
            term_re = clause_term_re
            
        # PARTITION BY RANGE => ignore through end of clause
        result = partition_by_range_multiline_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = pre
            str = '{0}{1}'.format(clause, post)
            comment = append_comment(comment, str, no_comments)
            comment_lines = 1
            term_re = clause_term_re            

        # PARTITION ... VALUES => ignore through end of clause
        result = partition_values_multiline_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = pre
            str = '{0}{1}'.format(clause, post)
            comment = append_comment(comment, str, no_comments)
            comment_lines = 1
            term_re = clause_term_re

        # LOB ... STORE AS => ignore through end of clause
        result = lob_multiline_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = pre
            str = '{0}{1}'.format(clause, post)
            comment = append_comment(comment, str, no_comments)
            comment_lines = 1
            term_re = clause_term_re

        # PCTFREE n => ignore
        result = pctfree_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # PCTUSED n => ignore
        result = pctused_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # INITRANS n => ignore
        result = initrans_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # MAXTRANS n => ignore
        result = maxtrans_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # TABLESPACE n => ignore
        result = tablespace_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # LOGGING => ignore
        result = logging_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # NOCOMPRESS => ignore
        result = nocompress_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # CACHE => ignore
        result = cache_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # USINGnn => ignore
        result = usingnn_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # COMPUTE STATISTICS => ignore
        result = compute_statistics_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        # Empty Comma => ignore
        result = empty_comma_re.match(sql)
        if result:
            pre = result.group(1)
            clause = result.group(2)
            post = result.group(3)
            sql = '{0}{1}'.format(pre, post)
            comment = append_comment(comment, clause, no_comments)

        ## DML transformations that might appear multiple times per line
        dml_repeat = True
        while dml_repeat:
            dml_repeat = False

            # determine prior period
            # e.g. trunc(sysdate,'MM')-1
            result = prior_period_re.match(sql)
            if result:
                pre = result.group(1)
                clause = result.group(2)
                col = result.group(3)
                units = result.group(4)
                offset = result.group(5)
                post = result.group(6)
                sql = '{0}dateadd({4}, {5}, trunc({3}, {4}))'.format(pre, post, clause, col, units, offset)
                comment = append_comment(comment, clause, no_comments)
                dml_repeat = True

            # add_months
            # e.g. add_months(trunc(sysdate, 'MM'), -5) => dateadd('MM', -5, trunc(current_timestamp, 'MM'))
            result = add_months_re.match(sql)
            if result:
                print >> sys.stderr , "Snowflake now has add_months() function -- verify can use as-is"
                sys.exit(1)
                pre = result.group(1)
                clause = result.group(2)
                col = result.group(3)
                units = result.group(4)
                offset = result.group(5)
                post = result.group(6)
                sql = '{0}dateadd({4}, {5}, trunc({3}, {4}))'.format(pre, post, clause, col, units, offset)
                comment = append_comment(comment, clause, no_comments)
                dml_repeat = True

            # SYSDATE => CURRENT_TIMESTAMP()
            result = sysdate_re.match(sql)
            if result:
                pre = result.group(1)
                clause = result.group(2)
                post = result.group(3)
                sql = '{0} CURRENT_TIMESTAMP() {1}'.format(pre, post, clause)
                comment = append_comment(comment, clause, no_comments)
                dml_repeat = True

            # INT4(expr) => expr::INTEGER
            result = int4_re.match(sql)
            if result:
                pre = result.group(1)
                clause = result.group(2)
                col = result.group(3)
                post = result.group(4)
                sql = '{0} {3}::integer {1}'.format(pre, post, clause, col)
                comment = append_comment(comment, clause, no_comments)
                dml_repeat = True

        # write out possibly modified line
        result = whitespace_line_re.match(sql)
        if result:
            sql = None      # the mods have reduced this line to empty whitespace
        else:
            result = comma_line_re.match(sql)
            if result:
                sql = None  # the mods have reduced this line to a single vestigial comma
        write_line(sqlout, sql, comment)
        continue

def append_comment(old_comment, new_comment, no_comments):
    if no_comments:
        return None
    if old_comment and new_comment:
        return '{0} // {1}'.format(old_comment, new_comment)
    if not old_comment:
        return new_comment
    return old_comment

def write_line(sqlout, sql, comment):
    if sql is not None:
        sqlout.write(sql)
    if comment:
        sqlout.write('\t\t--// {0}'.format(comment))
    if sql is not None or comment:
        sqlout.write('\n')
    return

##### MAIN #####
parser = argparse.ArgumentParser(description='Convert SQL dialects to Snowflake.')
parser.add_argument('--no_comments', action='store_true',
    help='suppress comments with changes (default: show changes)')
parser.add_argument('inputfile', action='store', 
    help='input SQL file in other-vendor dialect (default: stdin) where the files to convert resides')
parser.add_argument('outputfile', action='store',
    help='output SQL file in Snowflake dialect (default: stdout) where the converted files are desired')
args=parser.parse_args();
print ("Python " + sys.version, file=sys.stderr)
print ("no_comments = " + str(args.no_comments), file=sys.stderr)
print ("input: " + str(args.inputfile), file=sys.stderr)
print ("output: " + str(args.outputfile), file=sys.stderr)

files = os.listdir(args.inputfile)

for f in files:
    #i_file = open(args.inputfile + "\\" + f ,"r")
    i_file = open(args.inputfile + "/" + f ,"r")
    #o_file = open(args.outputfile + "\\" + f ,"w")
    o_file = open(args.outputfile + "/" + f ,"w")
    make_snow(i_file.readlines(), o_file, args.no_comments)
    i_file.close()
    o_file.close()
    print ("done translating " + i_file.name, file=sys.stderr)
