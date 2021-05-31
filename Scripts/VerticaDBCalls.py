import os
import os.path
import vertica_python
import pandas as pd

class VerticaDBCalls:

    def __init__(self, dbConnection):
        self.dbConnection = dbConnection

    def getTablesInSchema(self, schema):
        sqlString =    "select table_schema" \
                              ",table_name " + \
                              ",case " + \
                              "   when is_temp_table is TRUE then 'TRUE'  " + \
                              "   else 'FALSE' " + \
                              "end as is_temp_table " + \
                              ",owner_name " + \
                        "from v_catalog.tables  " + \
                        "where upper(table_schema) = '" + schema.upper() + "'" #+ \
                        #"  and upper(TABLE_NAME) = 'MYTABLE1'"


        sqlQuery = pd.read_sql_query(sqlString, self.dbConnection)
        df = pd.DataFrame(sqlQuery, columns=['table_schema', 'table_name','is_temp_table','owner_name'])

        return df

    def getColumnsInTable(self, schema, table):
        sqlString =    "select table_name " + \
                              ",column_name " + \
                              ",data_type " + \
                              ",data_type_length " + \
                              ",character_maximum_length " + \
                              ",numeric_precision " + \
                              ",numeric_scale " + \
                              ",datetime_precision " + \
                              ",interval_precision " + \
                              ",ordinal_position " + \
                              ",case " + \
                              "   When is_nullable is TRUE Then 'TRUE' " + \
                              "   Else 'FALSE' " + \
                              "end as is_nullable " + \
                              ",column_default " + \
                              ",column_set_using " + \
                              ",case " + \
                              "   When is_identity IS TRUE THEN'TRUE' " + \
                              "   Else 'FALSE' " + \
                              "end as is_identity " + \
                       "from v_catalog.columns  " + \
                        "where upper(table_schema) = '" + schema.upper() + "'  " + \
                        "and upper(table_name) = '" + table.upper() + "' " + \
                        "order by ordinal_position "
        sqlQuery = pd.read_sql_query(sqlString, self.dbConnection)
        df = pd.DataFrame(sqlQuery, columns=['table_name', 'column_name', 'data_type', 'data_type_length',
                                             'character_maximum_length','numeric_precision','numeric_scale',
                                             'datetime_precision','interval_precision','ordinal_position',
                                             'is_nullable','column_default','is_identity'])



        return df

    def getViewsInSchema(self, schema):
        sqlString =    "select table_schema" \
                              ",table_name " + \
                              ", view_definition " + \
                              ",owner_name " + \
                        "from v_catalog.views  " + \
                        "where upper(table_schema) = '" + schema.upper() + "'" #+ \


        sqlQuery = pd.read_sql_query(sqlString, self.dbConnection)
        df = pd.DataFrame(sqlQuery, columns=['table_schema', 'table_name','view_definition','owner_name'])

        return df
