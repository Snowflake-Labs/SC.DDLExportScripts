from _boto3_client import get_client
import os
import re
import sys
import time

'''
===========================
== Functions definitions ==
===========================
'''


class Query:

    def __init__(self, object_type, query_text, out_path, schema_filter):

        self.object_type = object_type
        self.query_text = query_text.format(**{'schema_filter': schema_filter})
        self.query_id = None
        self.query_response = None
        self.code = []
        self.out_path = out_path


    def is_query_valid(self, client):
        resp = client.describe_statement(Id=self.query_id)
        if 'Error' in resp:
            raise RuntimeError(resp['Error'])
            pass
        else:
            return resp['ResultRows'] >= 0

    def get_code(self, client):
        if self.is_query_valid(client):
            resp = client.get_statement_result(Id=self.query_id)
            for row in resp['Records']:
                self.code.append(row[0]['stringValue'] + '\n')
            return True
        else:
            return False

    def save_code(self):
        filename = self.get_output_path()
        print(f'Saving {self.object_type} DDL code to {filename}')
        with open(filename, 'w') as f:
            f.writelines(self.code)


    def get_output_path(self):
        object_type_title = self.object_type.title()
        return os.path.join(self.out_path, 'object_extracts','DDL', f'DDL_{object_type_title}.sql')

    def __str__(self):
        return self.object_type


class ProcedureQuery(Query):

    def __init__(self, object_type, query_text, out_path, schema_filter):
        super().__init__(object_type, query_text, out_path, schema_filter)

        self.batch_query_ids = []
        self.failed_statements = []
        self.finished_statements = []
        self.procedures_processed = 0
        self.statements_ids = None

    def validate_procedure_queries(self, client):
        statements_ids_temp = []
        for query_id in self.batch_query_ids:
            stmts_resp = client.describe_statement(Id=query_id)
            statements_ids_temp += stmts_resp['SubStatements']

        finished_statements_temp = []
        failed_statements_temp = []

        for statement in statements_ids_temp:
            statement_id = statement['Id']
            object_name_regex = re.search(r'SHOW PROCEDURE ((?:\w+\.)?\w+)', statement['QueryString'])
            if object_name_regex is not None:
                if statement['Status'] == 'FINISHED':
                    finished_statements_temp.append({'id': statement_id, 'object_name': object_name_regex.group(1)})
                elif statement['Status'] == 'FAILED':
                    failed_statements_temp.append({'id': statement_id, 'object_name': object_name_regex.group(1), 'Error': statement['Error']})
                else:
                    return False
            else:
                # Log something here
                pass

        self.finished_statements = finished_statements_temp
        self.failed_statements = failed_statements_temp

        return True

    def get_code(self, client):
        if self.is_query_valid(client):
            resp = client.get_statement_result(Id=self.query_id)
            queries = []
            current_proc = None
            show_proc_code = ''
            if len(resp['Records']) > 0:
                for row in resp['Records']:
                    object_name = row[0]['stringValue']
                    param = row[1]['stringValue']
                    if object_name != current_proc:
                        queries.append(f'SHOW PROCEDURE {show_proc_code}')
                        current_proc = f'{object_name}'
                        show_proc_code = f'{object_name} {param}'
                    else:
                        show_proc_code = f'{show_proc_code} {param}'
                queries.append(f'SHOW PROCEDURE {show_proc_code}')
                queries.pop(0)  # First element is always empty
                self.procedures_processed = len(queries)
                i = 0
                batch = 0
                batches = abs(self.procedures_processed / 40)
                while i < self.procedures_processed:
                    print(f'Sending batch {batch}/{batches}')
                    edge = i + 40 if i + 40 < self.procedures_processed else self.procedures_processed
                    batch_statement_response = client.batch_execute_statement(
                        ClusterIdentifier=RS_CLUSTER
                        , Database=RS_DATABASE
                        , SecretArn=RS_SECRET_ARN
                        , Sqls=queries[i:edge]
                        , StatementName=f'mobilize_ddl_extraction_{q.object_type}'
                    )
                    self.batch_query_ids.append(batch_statement_response['Id'])
                    i += 40
                    batch += 1
                    if i % 200:
                        time.sleep(BATCH_WAIT)
                return True
            else:
                # Log no procedures where found
                return True
        else:
            return False

    def save_code(self, client):
        print(f'Found {self.procedures_processed} procedures')
        i = 0
        for proc in self.finished_statements:
            if i % 10 == 0:
                print(f'Getting code for procedure {i}/{self.procedures_processed}')
            i += 1
            query_result = client.get_statement_result(Id=proc['id'])
            if 'Records' in query_result:
                proc_code = query_result['Records'][0][0]['stringValue']
                proc_name = proc['object_name']
                self.code.append(f'/* <sc-procedure> {proc_name} </sc-procedure> */\n\n{proc_code}\n')
        filename = self.get_output_path()
        print(f'Saving {self.object_type} DDL code to {filename}')
        with open(filename, 'w') as f:
            f.writelines(self.code)
        return True


def read_ddl_queries():
    queries = []
    for f in os.listdir('.'):
        if f.endswith(".sql"):
            object_type_regex = re.search(r'^(.*)_ddl\.sql', f, )
            with open(f, 'r') as file:
                object_type = object_type_regex.group(1)
                file_content = file.read()
                if object_type == 'procedure':
                    queries.append(ProcedureQuery(object_type, file_content, OUT_PATH, SCHEMA_FILTER))
                else:
                    queries.append(Query(object_type, file_content, OUT_PATH, SCHEMA_FILTER))

    return queries


def execute_ddl_queries():
    for q in QUERIES:
        resp = RS_CLIENT.execute_statement(
            ClusterIdentifier=RS_CLUSTER
            , Database=RS_DATABASE
            , SecretArn=RS_SECRET_ARN
            , Sql=q.query_text
            , StatementName=f'mobilize_ddl_extraction_{q.object_type}'
        )
        q.query_id = resp['Id']


'''
=================================
== Global variables definition ==
=================================
'''
abspath = os.path.abspath(__file__)
dir_name = os.path.dirname(abspath)
os.chdir(dir_name)

args = sys.argv

RS_CLUSTER = args[1]
RS_DATABASE = args[2]
RS_SECRET_ARN = args[3]
OUT_PATH = args[4]
SCHEMA_FILTER = args[5]
BATCH_WAIT = float(args[6])

RS_CLIENT = get_client()

QUERIES = read_ddl_queries()
execute_ddl_queries()
proc_query = None

for q in QUERIES:
    i = 0
    print(f'Validating query result for {q.object_type}')
    while i <= 60:
        print(f'>>> Query result validation number {i}/60')
        try:
            if q.get_code(RS_CLIENT):
                break
        except RuntimeError as e:
            print(f'Failed to extract data for {q.object_type}. Failed query with error message:')
            print(e)
            break
        time.sleep(5)
        i += 1
    if not isinstance(q, ProcedureQuery):
        q.save_code()
    else:
        proc_query = q

if proc_query is not None:
    print('Validating individual queries for procedures')
    elapsed_validation = None
    elapsed_saving = None
    while i < 60:
        start = time.time()
        if proc_query.validate_procedure_queries(RS_CLIENT):
            end = time.time()
            elapsed_validation = end - start
            print('Writing Extracted Procedure DDL code')
            start = time.time()
            proc_query.save_code(RS_CLIENT)
            end = time.time()
            elapsed_saving = end - start
            break
        time.sleep(5)
        i += 1

    print(f'Procedure validation elapsed seconds: {elapsed_validation}')
    print(f'Procedure extraction elapsed seconds: {elapsed_saving}')

if __name__ == 'main':
    pass
