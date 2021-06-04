import os
import os.path
import vertica_python
import snowflake.connector
import logging

class SFConvert:

    def __init__(self, logger):
        self.logger = logger
        self.binary = ["VARBINARY", "LONG VARBINARY", "BYTEA", "RAW", "BINARY"]
        self.char = ["CHAR", "LONG VARCHAR", "VARCHAR"]
        self.timestamp = ["DATETIME", "SMALLDATETIME"]
        self.interval = ["INTERVAL", "INTERVAL DAY TO SECOND", "INTERVAL YEAR TO MONTH"]
        self.numberic = ["INT8", "TINYINT"]

    def vertTableToSFTable(self, sfConfig,  tableRow, tableColumns):

        # Defaults
        ddlDrop = "FALSE"
        ddlExecute = "FALSE"

        # Find the vertica table schema in the schema mapping to determine the location (db, schema) to create the table
        mappingFound = False
        for mapping in sfConfig.schemaMapping:
            if mapping[0].upper() == tableRow['table_schema'].upper():
                mappingFound = True
                snowflakeDbSchema = mapping[1]

        # Abort if mapping is not found
        if mappingFound is False:
            self.logger.error("Unable to find mapping for Vertica schema: " + tableRow['table_schema'])
            sys.exit(99)

        # Obtain execution model and drop existing
        for exec in sfConfig.execution:
            if exec[0].upper() == "DDLEXECUTE":
                ddlExecute = exec[1]
            elif exec[0].upper == "DROPSAVE":
                ddlSave = exec[1]
                # Check the folder exists
                if not  os.path.isdir(ddlSave):
                    self.logger.error("Save DDL path (" + ddlSave + ") does not exists on your workstation")
                    sys.exit(99)
            elif exec[0].upper() == "DROPEXISTING":
                ddlDrop = exec[1]

        # Construct the table DDL
        if ddlDrop.upper() == "TRUE":
            sfTable = "Create or Replace Table "
        else:
            sfTable = "Create  Table "
        sfTable += snowflakeDbSchema + "." + tableRow['table_name'] + "\n"
        sfTable += "(\n"

        boolFirstCol = True
        for colIdx, col in tableColumns.iterrows():
            if boolFirstCol is True:
                sfTable += " " + col['column_name']
                boolFirstCol = False
            else:
                sfTable += "," + col['column_name']

            if col['data_type'].find("(") >-1:
                rawDataType = col['data_type'][0:col['data_type'].find("(")]
                typeLen = col['data_type'][col['data_type'].find("(")  + 1:col['data_type'].find(")")]
            else:
                rawDataType =  col['data_type']
                typeLen = "1"


            # Check datatype
            if rawDataType.upper() in self.binary:
                sfTable += " BINARY " + "(" + typeLen + ")"
            elif rawDataType.upper() in self.char:
                sfTable += " VARCHAR " + "(" + typeLen + ")"
            elif rawDataType.upper() in self.timestamp:
                sfTable += " TIMESTAMP "
            elif rawDataType.upper() == "TIME WITH TIMEZONE":
                sfTable += " TIME "
                self.logger.warn("Table: " + tableRow['table_schema'] + "." + tableRow['table_name'] + " TIME WITH TIMEZONE migrated to TIME")
            elif rawDataType.upper() == "TIMESTAMP":
                sfTable += " TIMESTAMP_NTZ "
            elif rawDataType.upper() == "TIMESTAMP WITH TIMEZONE":
                sfTable += " TIMESTAMP_TZ "
            elif rawDataType.upper() in self.interval:
                sfTable += " INT "
                self.logger.warn("Table: " + tableRow['table_schema'] + "." + tableRow['table_name'] + " INTERVAL migrated to INT")
            elif rawDataType.upper() in  self.numberic:
                sfTable += " NUMBER "
            elif rawDataType.upper() == "MONEY":
                sfTable += " NUMBER (18,4) "
            elif rawDataType.upper() == "GEOMETRY":
                sfTable += " BINARY "
                self.logger.warn("Table: " + tableRow['table_schema'] + "." + tableRow['table_name'] + " GEOMETRY migrated to BINARY ")
            elif rawDataType.upper() == "GEOGRAPHY":
                sfTable += " BINARY "
                self.logger.warn("Table: " + tableRow['table_schema'] + "." + tableRow['table_name'] + " GEOGRAPHY migrated to BINARY ")
            elif rawDataType.upper() == "UUID":
                sfTable += " INTEGER "
                self.logger.warn("Table: " + tableRow['table_schema'] + "." + tableRow['table_name'] + " Requires Identity Column ")
            else:
                sfTable += " " + col['data_type']

            # Add not null if needed
            if col['is_nullable'].upper() == "FALSE":
                sfTable += " NOT NULL"

            sfTable +=  "\n"

        sfTable += ")\n"



        return sfTable


    def buildView(self, sfConfig,  tableSchema, viewName, viewDefinition):

        # Find the vertica table schema in the schema mapping to determine the location (db, schema) to create the table
        mappingFound = False
        for mapping in sfConfig.schemaMapping:
            if mapping[0].upper() == tableSchema.upper():
                mappingFound = True
                snowflakeDbSchema = mapping[1]

        sfSQL = "Create or Replace View " + snowflakeDbSchema + "." + viewName + " AS " + viewDefinition

        # This view will reference tables that exist in Vertica.
        # The mappings can be used to modify these references
        for mapping in sfConfig.inviewMappings:
            sfSQL = sfSQL.replace(mapping[0] + ".", mapping[1] + ".")

        return sfSQL

    def executeSQL(self, dbConn, ddlString):

        try:
            self.logger.info("execute SQL Start")
            sfCursor = dbConn.cursor().execute(ddlString)
            sfCursor.close()
            self.logger.info("Success! ")

        except snowflake.connector.errors.ProgrammingError as sfExp:
            errorString = format("Error No: " + str(sfExp.errno) + "\n" + str(sfExp.sqlstate) + "\n" + str(sfExp.msg))
            self.logger.error(errorString)
