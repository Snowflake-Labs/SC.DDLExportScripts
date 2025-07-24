﻿# Netezza Exporter

We’re excited to introduce Netezza Exporter, a simple tool to help exporting your Netezza Code
so it can be migrated to Snowflake.

## Version
0.0.96

## Usage

1. Login to the NZ host server.

2. Set up the environment. Please refer to the Environment Setup section.

3.  The below command will extract the DDL for all the schemas in the STAGING database. (For help on nz_ddl see section below)

```
    nz_ddl -d STAGING -schemas ALL > output.sql
```

## Environment Setup 

Make sure to have the below environment variables setup.

export PATH="$PATH:/nz/support/bin"
export NZ_HOST=<Host details>
export NZ_PORT=5480
export NZ_USER=<User Name>
export NZ_PASSWORD=<Password>
export NPS_VERSION=<Netezza Version, ex: 7.2>


## Help Instrustions for NZ_DDL

```shell
[nz@netezza ~]$ nz_ddl -help
```

```
Usage:    nz_ddl     [ <database> [ -rename <new_database_name> ]]  [ -udxDir <dirname> ]

Purpose:  To dump out all of the SQL/DDL that defines this NPS system.

          This includes

               CREATE GROUP ...
               CREATE USER ...

               CREATE DATABASE / CREATE SCHEMA ...
                    CREATE TABLE ...
                    CREATE EXTERNAL TABLE ...
                    CREATE VIEW ...
                    CREATE MATERIALIZED VIEW ...
                    CREATE SEQUENCE ...
                    CREATE SYNONYM ...
                    CREATE FUNCTION ...
                    CREATE AGGREGATE ...
                    CREATE LIBRARY ...
                    CREATE PROCEDURE ...

          And also

               COMMENT ...  (to add COMMENTs to an object)
               GRANT ...    (to GRANT access privileges to users and groups)
               SET ...      (to SET the system default values)
               ALTER ...    (to ALTER the owner of an object)
               UPDATE ...   (to UPDATE the encrypted passwd column when creating users)

Access:   For the most part, the nz_ddl* scripts access generic system views in
          order to do their work.  If you have access to a given object, the script
          will be able to reproduce the DDL for it.  With the following caveats:

          4.6        No caveats

          4.5        nz_ddl_function  -- requires SELECT access to the system table _T_PROC
                     nz_ddl_aggregate -- requires SELECT access to the system table _T_AGGREGATE

          4.0, 4.5   Do you use quoted database names ... e.g., "My Database" (which is
                     rather atypical to begin with)?  If so, then various scripts will
                     want SELECT access to the system table _T_OBJECT in order to
                     identify whether or not a particular database name needs quoting.
                     Without such access the scripts will still function, but they won't
                     add quotes around any database name that would require quoting.

          nz_ddl_user
                     When dumping out the CREATE USER statements, each user's default
                     password is initially set to 'password'.  For this script to be
                     able to UPDATE the password (with the actual encrypted password)
                     that will require SELECT access to the system table _T_USER.
                     Otherwise, this script will not generate the additional SQL
                     statements to update the password.

          nz_ddl_function, nz_ddl_aggregate, nz_ddl_library
                     These scripts place a copy of the host+SPU object files into
                     the directory '/tmp/nz_udx_object_files'.  In order for the
                     copy operation to work successfully, the script must be run
                     as the linux user 'nz' so that it can access the original
                     files under /nz/data

          nz_ddl_sequence
                     The starting value for the sequence ("START WITH ...") will be
                     based upon the _VT_SEQUENCE.NEXT_CACHE_VAL value (which is not
                     necessarily the next sequence number -- but rather the next
                     cache number/value that would be doled out.  For more on this topic
                     see "Caching Sequences" in the "Database User's Guide".)

                     If you do not have access to that virtual table (and by default,
                     users do not) then the "START WITH ..." value will be based upon
                     whatever value was used when the sequence was originally created.

Inputs:   By default, everything about the NPS server will be dumped out.

          The <database> name is optional.

          If a database name is included, then only the specified database/schema
          will be processed.  The output will include a "CREATE DATABASE" statement
          (for the database), but there will be no "CREATE SCHEMA" statement ...
          which would have the effect of creating all of the objects in the default
          schema of the new database.

          The SQL/DDL will include all of the CREATE, COMMENT, GRANT and ALTER
          statements associated with the database/schema.

          Specify "-owner <name>" to limit the output to those database objects
          (tables, views, sequences, ...) owned by the specified user.  It will
          include CREATE and GRANT statements.  It will not include ALTER ... OWNER
          statements as all objects are owned by the same specified "-owner <name>".
          It will not include any COMMENT statements.

          -rename <new_database_name>

          in which case the <new_database_name> name will be substituted for you into
          the DDL that is generated by this script.

          If you want to quickly clone a database structure on the same NPS host
          (the DDL, not the data itself) you can do something like this:

               nz_ddl  INVENTORY  -rename  INVENTORY_COPY  |  nzsql

          Likewise, you could clone the structure to another NPS host by doing:

               nz_ddl  INVENTORY  -rename  INVENTORY_COPY  |  nzsql -host another_host

          Because groups and users are global in nature -- and not tied to
          a particular database -- no CREATE GROUP/CREATE USER statements
          will be included in this output.  However, any GRANT's -- to give
          groups and users the relevant access to the objects within this
          database -- will be included.

          -udxDir <dirname>

          Part of the definition of any FUNCTION/AGGREGATE/LIBRARY is a reference to
          two compiled object files -- one for the host and one for the SPU/SBlade.
          For your convenience, a copy of these object files will be put under the
          directory
               /tmp/nz_udx_object_files

          If you wish, you can use this switch to specify an alternative directory
          location for the files to be copied to.

          Should you want to use this DDL to create these same objects on another NPS
          box, these files must be made available there.

          Note:  The scripts 'nz_ddl_group' and 'nz_ddl_user' can be used
          separately to generate any desired CREATE GROUP or CREATE USER
          statements.

          Note:  Privileges can also be set globally -- within the 'SYSTEM'
          database -- and therefore be applicable to all databases.  When
          moving just a single database from one machine to another you
          should issue the following commands

               nz_ddl_grant_group  -sysobj  system
               nz_ddl_grant_user   -sysobj  system

          to retrieve and review those global privileges -- and see if there
          are any you wish to set on the new machine.

Outputs:  The SQL/DDL (with comments) will be sent to standard out.  This
          should be redirected to a disk file for future use.

          When you are ready to replay the SQL (on this, or another, system)
          you should do it as a user who has the appropriate privileges to
          issue all of the various SQL/DDL statements.

          When replaying the SQL, you might want to invoke it in a manner
          such as this
                   nzsql  < your_ddl.sql   &> your_ddl.out

          The output file can then be quickly scanned + checked for
          problems in a manner such as this

                   cat your_ddl.out | grep -F -v "*****" | sort | LC_COLLATE=C uniq -c

          The summarization that is produced would look something like this.
          The 'NOTICE's are ok -- they simply indicate that some of the
          CREATE TABLE statements had constraints associated with them.

          If there are any 'ERROR's listed, they warrant your attention.

                        10 ALTER DATABASE
                         2 ALTER GROUP
                         1 ALTER SEQUENCE
                         2 ALTER SYNONYM
                        21 ALTER TABLE
                        19 ALTER USER
                         9 ALTER VIEW
                        19 COMMENT
                        31 CREATE DATABASE
                        18 CREATE EXTERNAL TABLE
                        14 CREATE GROUP
                        13 CREATE MATERIALIZED VIEW
                        16 CREATE SEQUENCE
                        15 CREATE SYNONYM
                        89 CREATE TABLE
                        18 CREATE USER
                        17 CREATE VIEW
                       151 GRANT
                        55 NOTICE:  foreign key constraints not enforced
                        30 NOTICE:  primary key constraints not enforced
                        12 NOTICE:  unique key constraints not enforced
                         6 SET VARIABLE
                        31 UPDATE 1

================================================================================

General Information
-------------------
The scripts treat all command line options as case insensitive -- this applies to database
names and object names and any switches/arguments.  One exception to this rule is if you
have used delimited object names, in which case they are case sensitive.  And when specifying
them on the command line you would need to enter them as '"My Table"' ... e.g.,
     <single quote><double quote>The Name<double quote><single quote>

While these scripts were developed and tested on an NPS server, many (but not all) of
them should also be able to be run from a remote client running linux/unix.  Some scripts
will need to be run as the linux user "nz" (on the NPS host itself) as the script requires
access to certain privileged executables and files.  Some scripts will need to be run as
the database user "ADMIN" as the script accesses certain privileged tables and views (that
only the ADMIN user has access to, by default).  If you are having problems running a
particular script, first review the online help for the script to see if it mentions any
special requirements.  When in doubt, try running the script from the nz/ADMIN account.

Generic Command Line Options
----------------------------
The scripts support the following generic NPS options (which are similar to nzsql, nzload, etc...)

  -d  <dbname>           Specify database name to connect to   [NZ_DATABASE]
  -db <dbname>
  -schema <schemaname>   Specify schema name to connect to     [NZ_SCHEMA]
  -u  <username>         Specify database username             [NZ_USER]
  -w  <password>         Specify the database user password    [NZ_PASSWORD]
  -pw <password>
  -host <host>           Specify database server host          [NZ_HOST]
  -port <port>           Specify database server port          [NZ_PORT]
  -rev                   Show version information and exit

Schemas
-------
Additional command line options that these scripts support when using schemas

  -schemas ALL           Process ALL schemas in the database, rather than just one
                         schema.  This applies to all scripts (to include nz_db_size,
                         nz_ddl*, nz_groom, nz_genstats, nz_migrate, ...)

                         Alternatively, you can set up this environment variable
  export NZ_SCHEMAS=ALL
                         so that you don't have to keep specifying "-schemas ALL" on
                         the command line each time you invoke a script (if you like
                         working with all of the schemas all of the time).  Since
                         this is a different environment varable (than NZ_SCHEMA) it
                         will not interfere with the other nz*** cli tools.

  -schemas <...>         Specify a list (a subset) of the schemas to be processed

  -schema  default       Allows you to connect to a database's default schema
                         (without having to know/specify its actual name)

When processing multiple schemas, the objects in a database will be displayed using
their   SchemaName.ObjectName

When choosing "-schemas <...>", if you specify just a single schema name then only
that one schema will be processed.  But the objects will still be displayed using
their   SchemaName.ObjectName

Picking A Set Of Objects
------------------------
Previously, many of the scripts allowed you to process either a single object or all objects.
For example, "nz_ddl_table PROD" would produce the DDL for all tables in the database PROD,
whereas "nz_ddl_table PROD CUSTOMERS" would produce the DDL for just the one table, CUSTOMERS.

But what if you wanted something in-between, some subset of objects or tables or views or whatever.
More than one, but less than all.

Now you can do just that!  Rather than specifying just one object name when invoking a script,
you can INSTEAD use the following command line options to specify whatever subset of object names
you are interested in processing.

  -in        <string ...>
  -NOTin     <string ...>
  -like      <string ...>
  -NOTlike   <string ...>

They are patterned after the SQL constructs of IN, NOT IN, LIKE, NOT LIKE.  You can use any
combination of the above, and specify any number of strings.

For -in/-NOTin, the strings are case insensitive exact matches.  If you need a particular string
to be treated as case sensitive, specify it thusly:  '"My Objectname"'

For -like/-NOTlike, the strings are case insensitive wild card matches.  But you get to decide
where the wild cards go by adding the symbol % to each string (at the beginning, middle, and/or end).

Example:  nz_ddl_table PROD -like %fact% %dim% -notlike %_bu test% -in SALES INVENTORY -notin SALES_FACT

To experiment with these switches, and find out which objects will (or will not) be selected, try the
nz_get_***_names scripts (nz_get_table_names, nz_get_view_names, etc ...)

There is an additional option that allows you to limit the selection to only those objects owned
by the specified username.

  -owner     <username>

```


## Reporting issues and feedback

If you encounter any bugs with the tool please file an issue in the
[Issues](https://github.com/Snowflake-Labs/SC.DDLExportScripts/issues) section of our GitHub repo.

## License

Netezza Exporter is licensed under the [MIT license](https://github.com/Snowflake-Labs/SC.DDLExportScripts/blob/main/Netezza/License.txt).


