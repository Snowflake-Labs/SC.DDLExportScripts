# Teradata Export Scripts Tests

# Teradata Export Scripts Tests

> [!WARNING]  
> This test folder should be run only on the teradata demo database [Teradata-Express](https://downloads.teradata.com/download/database/teradata-express/vmware), because it creates and removes new databases to test the extraction process.

## How to run the tests.
1 - Modify `scripts/config.sh` with your connection values, if you are using the demo Teradata-Express this values should be the same.

3 - Ensure your demo database is running in your local system. 

4 - Go to `./Tests/Teradata/scripts` and run the script `ssh_automatic_login_condiguration.sh`, this is necessary to automate the login process to the demo database. 

5 - Go to back to `./Tests/Teradata/` and run `python -m unittest`


## How to add a new tests with new database.
1 - Create a new folder in `./Tests/Teradata/source_code`, this folder must contain the following files. 
* `deploy_database.sh`, this script execute the necesary commands to deploy the example source code.
* `drop_database.sh`, this script execute the necesary commands to drop the example source code.in this file replaces the variables defined in `./Teradata/bin/create_ddls.sh`.
* The SQL source coide, the scripts that create tables, procedures, etc. 

2 - Create a python test class. As an example check the file `test_demo_database.py`. In addition, the folder name defined in the setUpClass method must be the same name as the created in the previos step, since the script `execute_extract_database_script.sh` looks for that folder in the directory `./Tests/Teradata/source_code`.

3 - The SQL files must be in UTF-8.