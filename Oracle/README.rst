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

Reporting issues and feedback
-----------------------------

If you encounter any bugs with the tool please file an issue in the
`Issues`_ section of our GitHub repo.

License
-------

`sc-oracle-export` is licensed under the `MIT license`_.

.. _Issues: https://github.com/MobilizeNet/SnowConvertDDLExportScripts/issues
.. _MIT license: https://github.com/MobilizeNet/SnowConvertDDLExportScripts/blob/main/Oracle/LICENSE.txt