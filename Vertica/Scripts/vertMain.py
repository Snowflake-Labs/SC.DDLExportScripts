import sys
import getopt
import os
import os.path
import vertica_python
import snowflake.connector
import time
import logging
import sqlparse
from SFConfig import *
from VerticaConfig import *
from VerticaDBCalls import *
from SFConvert import *

def main(argv):
    
    sfSQL=""
    # Configure logging
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    fmt = logging.Formatter('%(asctime)s %(name)s %(levelname)s %(message)s')
    ch = logging.StreamHandler()
    ch.setFormatter(fmt)
    logger.addHandler(ch)

    logger.info("**************************************")
    logger.info("* Vertica to Snowflake DDL Converter *")
    logger.info("**************************************")

    logger.info("Gathering connection details - Start")
    snowflakeConnFile = ""
    verticaConnFile = ""
    sfConfig = SFConfig()
    verticaConfig = VerticaConfig()
    try:
        opts, args = getopt.getopt(argv, "s:v:", ["snowflake=", "vertica="])
    except getopt.GetOptError as e:
        print("Invalid Parameter(s): " + str(e))
        sys.exit(2)

    for opt, arg in opts:
        if opt == "-s":
            snowflakeConnFile = arg
        elif opt == "-v":
            verticaConnFile = arg


    # Both arguments provided. Check the files exist
    if not os.path.isfile(snowflakeConnFile):
        print ("Snowflake config file: " + snowflakeConnFile + " does not exist")
        sys.exit(2)
    else:
        sfConfig.readConfig(snowflakeConnFile)


    if not os.path.isfile(verticaConnFile):
        print("Vertica config file: " + verticaConnFile + " does not exist")
        sys.exit(2)
    else:
        verticaConfig.readConfig(verticaConnFile)

    if not sfConfig.validate:
        print("Error in Snowflake config file")
        sys.exit(2)

    if not verticaConfig.validate:
        print("Error in Vertica config file")
        sys.exit(2)

    logger.info("Gathering connection details - Complete")

    # All is well, start the process
    # Process is
    #   - Connet to SF and Vertica
    #   - For Each vertica schema and table
    #         Extract Vertica table definition
    #         Build SF DDL
    #         submit snowflake DDL to SF DB

    # Connect to SF
    try:
        logger.info("Connecting to Snowflake")
        sfConn = snowflake.connector.connect(
            user=sfConfig.sfUser,
            password=sfConfig.sfPassword,
            account=sfConfig.sfAccount,
            warehouse=sfConfig.sfWarehouse,
            role=sfConfig.sfRole
        )
        logger.info("Connecting to Snowflake - OK")
    except Exception as e:
        print(e)
        sys.exit(3)

    # Connect to Vertica

    try:
        logger.info("Connecting to Vertica")
        conn_info = {'host': verticaConfig.host,
                     'port': verticaConfig.port,
                     'user': verticaConfig.user,
                     'password': verticaConfig.password,
                     'database': verticaConfig.database,
                     'ssl': False}

        connVert = vertica_python.connect(**conn_info)
        logger.info("Connecting to Vertica - OK")

        # Get list of vertica Tables
        vertDBCalls = VerticaDBCalls(connVert)
        sfConvert = SFConvert(logger)

        # Get the options
        ddlExecute = "FALSE"
        ddlSave = "FALSE"

        for sfOpts in sfConfig.execution:
            if sfOpts[0].upper() == "DDLEXECUTE":
                ddlExecute = sfOpts[1]
            elif sfOpts[0].upper() == "PROCESSVIEWS":
                if sfOpts[1].upper() == "TRUE":
                    processViews = True
                else:
                    processViews = False
            elif sfOpts[0].upper() == "DDLSAVE":
                ddlSave = sfOpts[1]
                # Check the folder exists
                if not os.path.isdir(ddlSave):
                    logger.error("Save DDL path (" + ddlSave + ") does not exists on your workstation")
                    sys.exit(99)


        dfTableRows = vertDBCalls.getTablesInSchema(verticaConfig.schema)

        for index, row in dfTableRows.iterrows():
            logger.info("Processing table:  " + row['table_schema'] + "." + row['table_name'])

            tableCols = vertDBCalls.getColumnsInTable(verticaConfig.schema, row['table_name'] )
            sfSQL = sfConvert.vertTableToSFTable(sfConfig, row, tableCols)

            if ddlExecute.upper() == "TRUE":
                sfConvert.executeSQL(sfConn, sfSQL)

            if not ddlSave == "False":
                ddlFn = ddlSave + "/" + row['table_schema'] + "_" + row['table_name'] + ".sql"
                ddlFile = open(ddlFn, "w")
                ddlFile.write(sfSQL)
                ddlFile.close()  # to change file access modes

        if processViews is True:
            dfViewRows = vertDBCalls.getViewsInSchema(verticaConfig.schema)
            for index, row in dfViewRows.iterrows():
                logger.info("Processing view:  " + row['table_schema'] + "." + row['table_name'])

                sfSQL = sfConvert.buildView(sfConfig, row['table_schema'], row['table_name'], row['view_definition'])

                if ddlExecute.upper() == "TRUE":
                    sfConvert.executeSQL(sfConn, sfSQL)

                if not ddlSave == "False":
                    sfSQL = sqlparse.format(sfSQL, reindent=True)
                    ddlFn = ddlSave + "/" + row['table_schema'] + "_" + row['table_name'] + ".sql"
                    ddlFile = open(ddlFn, "w")
                    ddlFile.write(sfSQL)
                    ddlFile.close()  # to change file access modes

        logger.info("Closing DB connections")
        connVert.close()
        sfConn.close()

    except Exception as e:
        print(e)
        sys.exit(3)


if __name__ == '__main__':
    main(sys.argv[1:])