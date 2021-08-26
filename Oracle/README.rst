sc-oracle-export
================

We’re excited to introduce `sc-oracle-export`, a simple tool to help exporting your Oracle Code
so it can be migrated to Snowflake.


Installation
------------

.. code:: bash

    $ pip3 install snowconvert-export-oracle --upgrade

This command may need to run as sudo if you are installing to the system site packages. snowconvert-export-oracle can be 
installed using the --user option, which does not require sudo.

.. code:: bash

    $ pip3 install snowconvert-export-oracle --upgrade --user 


Usage
-----

For general help content, pass in the ``-h`` parameter:

.. code:: bash

    $ sc-oracle-export -h


Example
-------

For example, lets assume you are running this script on a machine to access to the Oracle Server

Then you will follow these steps from the command line:


1. First install the tool:

.. code:: bash

    $ pip3 install snowconvert-export-oracle --upgrade


2. Second create a folder for your extraction

.. code:: bash

    $ mkdir OracleExport
    $ cd OracleExport

3. Run the tool

.. code:: bash

    $ ./sc-oracle-export -S <service-name> -HO <host> -U <user> -P <password>

    You need to replace the placeholder above for your system settings. For example for a test environment they will
    be something like `orcl` instead of *service-name*, `localhost:1521` instead of *host*, `system` instead of *user*
    and manager instead of *password*.
    The tool will ask to install the SQLCL and the JDK. If you do not have sqlplus or sqlcl installed it is better to follow this step if no type no.
    You will then be asked for: `INCLUDE_OPERATOR`,`INCLUDE_CONDITION`, `EXCLUDE_OPERATOR`, `EXCLUDE_CONDITION`
    These values are used to customize which schemas are included or not.

    An example of the output of the tool will be:

::

    This script will install the Oracle SQLCL tool and JDK to enable connection to your database
    Install tools to connect to Oracle (yes/no/cancel)
    no
    Creating the scripts to export object DDLs
    Updating DDL export scripts....
    1. Enter value for the 'INCLUDE_OPERATOR' (e.g. LIKE, IN, =, NOT IN, NOT LIKE): LIKE
    2. Enter value for the 'INCLUDE_CONDITION': (OWNER1, ONWER2)
    3. Enter value for the 'EXCLUDE_OPERATOR' (e.g. LIKE, IN): IN
    4. Enter value for the 'EXCLUDE_CONDITION': ('SCHEMA3', 'SCHEMA4')
    If nothing was entered, we will be using these default values: 1=LIKE 2=(OWNER1, ONWER2) 3=IN 4=('SCHEMA3', 'SCHEMA4')
    
    NOTE: Run this script with your oracle tools. For example sqlplus USER/PASSWORD@HOST/SERVICE @./scripts/create_ddls.sql
    Cleaning up empty output files
    
    You can now run the script ./scripts/create_ddls.sql to export your Oracle DDLs
    The tool will ask before writing the scripts.

4. After running the tool a new folder `scripts` gets created with the customized `create_ddls.sql`. You can open it on an editor an customized even further.

5. When the script is done, the `output` folder will contain all the DDLs for the migration. 
   
You can then compress this folder to use with `SnowConvert`_

.. code:: bash

    $ zip -r output.zip ./output


Reporting issues and feedback
-----------------------------

If you encounter any bugs with the tool please file an issue in the
`Issues`_ section of our GitHub repo.

License
-------

`sc-oracle-export` is licensed under the `MIT license`_.

.. _SnowConvert: https://www.mobilize.net/products/database-migrations/snowconvert
.. _Issues: https://github.com/MobilizeNet/SnowConvertDDLExportScripts/issues
.. _MIT license: https://github.com/MobilizeNet/SnowConvertDDLExportScripts/blob/main/Oracle/LICENSE.txt