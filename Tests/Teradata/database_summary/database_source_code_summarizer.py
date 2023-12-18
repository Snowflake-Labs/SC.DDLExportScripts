import os
import re
from .database_source_code_summary import DatabaseSourceCodeSummary
from .top_level_object_type import TopLevelObjectType

def sumarize_database_source_code(path: str) -> DatabaseSourceCodeSummary:
    database_summary = DatabaseSourceCodeSummary()

    for dirpath, dirnames, filenames in os.walk(path):  
        for filename in filenames: 
            if not re.match(r'.*\.sql$', filename, flags=re.IGNORECASE):
                continue
            file_path = os.path.join(dirpath, filename) 
            database_summary.add_sql_file(file_path)
            sql_statements = read_sql_statements_from_file(file_path)
            analyze_sql_statements(sql_statements, database_summary)
    return database_summary

def analyze_sql_statements(sql_statements: "list[str]", database_summary: DatabaseSourceCodeSummary):
    for sql_statement in sql_statements:
        type = get_sql_statement_type(sql_statement)
        database_summary.get_top_level_object_to_int_map()[type] += 1

def get_sql_statement_type(sql_statement: str) -> TopLevelObjectType:
    if is_statement_of_type(sql_statement, TopLevelObjectType.PROCEDURE.name):
        return TopLevelObjectType.PROCEDURE
    elif is_statement_of_type(sql_statement, TopLevelObjectType.TRIGGER.name):
        return TopLevelObjectType.TRIGGER
    elif is_statement_of_type(sql_statement, TopLevelObjectType.TABLE.name):
        return TopLevelObjectType.TABLE
    elif is_statement_of_type(sql_statement, TopLevelObjectType.DATABASE.name):
        return TopLevelObjectType.DATABASE
    elif is_statement_of_type(sql_statement, TopLevelObjectType.VIEW.name):
        return TopLevelObjectType.VIEW
    else:
        return TopLevelObjectType.UNDEFINED_TYPE
    
def is_statement_of_type(statement: str, type_name: str) -> bool:
    regex = r'^(?:/\*.*\*/|)\s*CREATE(?:\s*\w*\s*){0,2}' + type_name+ r'\s'
    result = re.search(regex, statement, flags=re.IGNORECASE|re.MULTILINE)
    return result

def read_sql_statements_from_file(file_path: str) ->"list[str]":
    with open(file_path) as my_file:
        sql_statements = my_file.read().split(';')
        return sql_statements
    



