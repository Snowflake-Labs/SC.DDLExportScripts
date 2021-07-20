sc-sqlserver-export
===================
We’re excited to introduce `sc-sqlserver-export`, a simple tool to help exporting your SQLServer Code
so it can be migrated to Snowflake.


Installation
------------

.. code:: bash

    $ pip3 install snowconvert-export-sqlserver --upgrade

Please refer to the `installation guide`_ for detailed install instructions. 

Usage
-----

Please refer to the `usage guide`_ for details on options and example usage.

For general help content, pass in the ``-h`` parameter:

.. code:: bash

    $ sc-sqlserver-export -h

NOTE: if you have already exported the code, you might need to do a **"code arrange"** 
that is a process to clean up the DDLs for better conversion. 
To do that run the `sc-sqlserver-arrange` tool.
    

Reporting issues and feedback
-----------------------------

If you encounter any bugs with the tool please file an issue in the
`Issues`_ section of our GitHub repo.

License
-------

sc-sqlserver-export is licensed under the `MIT license`_.

.. _installation guide: https://github.com/MobilizeNet/SnowConvertDDLExportScripts/blob/main/SQLServer/doc/installation_guide.md
.. _usage guide: https://github.com/MobilizeNet/SnowConvertDDLExportScripts/blob/main/SQLServer/doc/usage_guide.md
.. _Issues: https://github.com/MobilizeNet/SnowConvertDDLExportScripts/issues
.. _MIT license: https://github.com/MobilizeNet/SnowConvertDDLExportScripts/blob/main/SQLServer/LICENSE.txt