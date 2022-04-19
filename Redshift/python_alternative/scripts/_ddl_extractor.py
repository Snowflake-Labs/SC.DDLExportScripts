import argparse
import datetime as datetime
import logging
import os
import re
import sys
import time

from _boto3_client import get_client
from itertools import repeat
from multiprocessing import cpu_count
from multiprocessing.pool import ThreadPool as Pool


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
        print_and_log(f'Saving {self.object_type} DDL code to {filename}', logging.info)
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
                batch = 1
                batches = int(self.procedures_processed / 40) + 1
                while i <= self.procedures_processed:
                    print(f'Executing batch {batch}/{batches}')
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
                print_and_log('No procedures were found in the database and schema sepecified', logging.info)
                return True
        else:
            return False

    @staticmethod
    def get_procedure_code(proc, client):
        query_id = proc['id']
        proc_name = proc['object_name']
        try:
            query_result = client.get_statement_result(Id=query_id)
            if 'Records' in query_result:
                proc_code = query_result['Records'][0][0]['stringValue']
                return f'/* <sc-procedure> {proc_name} </sc-procedure> */\n\n{proc_code}\n'
        except Exception as ex:
            msg = f'Unable to get code for procedure {proc_name}.'
            print(f'{msg} Please check the logs for more details.')
            logging.exception(f'{msg} Query ID: {query_id}. Exception details:')
            return ''

    def save_code(self, client):
        print_and_log(f'Found {self.procedures_processed} procedures', logging.info)

        with Pool(4) as p:
            self.code = p.starmap(ProcedureQuery.get_procedure_code, zip(self.finished_statements, repeat(client)))

        print_and_log('Finished retrieving procedures.', logging.info)

        filename = self.get_output_path()
        print_and_log(f'Saving {self.object_type} DDL code to {filename}', logging.info)
        with open(filename, 'w') as f:
            f.writelines(self.code)


def read_ddl_queries():
    queries = []
    for f in os.listdir('.'):
        if f.endswith(".sql"):
            object_type_regex = re.search(r'^DDL_(.*)\.sql', f, )
            with open(f, 'r') as file:
                object_type = object_type_regex.group(1)
                file_content = file.read()
                if object_type == 'Procedure':
                    queries.append(ProcedureQuery("Procedure", file_content, OUT_PATH, SCHEMA_FILTER))
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


def print_and_log(msg, level):
    print(msg)
    level(msg)

'''
=================================
== Global variables definition ==
=================================
'''
abspath = os.path.abspath(__file__)
dir_name = os.path.dirname(abspath)
os.chdir(dir_name)

parser = argparse.ArgumentParser()
parser.add_argument('--rs-cluster',  help='Redshift Cluster Identifier')
parser.add_argument('--rs-database', help='Redshift Database Name')
parser.add_argument('--rs-secret-arn', help='SecretsManager secret ARN. This secret should contain the credentials to connect to the Redshift Cluster.')
parser.add_argument('--output-path', help='Output path where the code will be exported.')
parser.add_argument('--schema-filter', help='SQL statement to filter the schema.')
parser.add_argument('--batch-wait', default=0.2, help='When sending the queries for the procedures, this will be the time to wait (in seconds) between group of batches (every 200 queries)', type=float)
parser.add_argument('--threads', default=4, help='When extracting the code for the procedures, the amount of threads to use to make the queries to AWS Redshift-Data API. This will decrease the extraction times considerably.', type=int)
args = parser.parse_args()

RS_CLUSTER = args.rs_cluster
RS_DATABASE = args.rs_database
RS_SECRET_ARN = args.rs_secret_arn
OUT_PATH = args.output_path
SCHEMA_FILTER = args.schema_filter
BATCH_WAIT = args.batch_wait
THREADS = args.threads

current_date = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
log_path = os.path.join(OUT_PATH, 'log', f'{current_date}.log')
logging.basicConfig(filename=log_path, level=logging.INFO)

cpu_count = cpu_count()
if cpu_count < THREADS:
    print_and_log(f'Amount of threads specified exceeds maximum of current CPU. Current CPU count is {cpu_count}.', logging.error)
    exit(1)

try:
    import boto3
    import botocore.exceptions

    RS_CLIENT = get_client()
    QUERIES = read_ddl_queries()
    execute_ddl_queries()
    proc_query = None
    if len(QUERIES) == 0:
        print_and_log('No ddl queries detected. Please make sure to copy the complete repository folder.', logging.error)
        exit(1)
except ModuleNotFoundError:
    print_and_log('Boto3 library not installed. Please `run pip install boto3` for the script to work.', logging.error)
    exit(1)
except botocore.exceptions.NoCredentialsError:
    print_and_log('Unable to initialize connection to s3 with the credentials provided. Make sure your credentials are properly configured', logging.error)
    exit(1)

for q in QUERIES:
    i = 1
    print_and_log(f'Validating query result for {q.object_type}', logging.info)

    if isinstance(q, ProcedureQuery):
        proc_query = q

    while i <= 60:
        print(f'>>> Query result retrieval attempt {i}/60')
        try:
            if q.get_code(RS_CLIENT):
                if not isinstance(q, ProcedureQuery):
                    q.save_code()
                break
        except RuntimeError as e:
            print(f'WARNING: Failed to extract data for {q.object_type}. Please check the logs for full error message.')
            logging.exception(e)
            break
        time.sleep(5)
        i += 1


if proc_query is not None:
    print_and_log('Validating individual queries for procedures', logging.info)
    elapsed_validation = None
    elapsed_saving = None
    while i < 60:
        start = time.time()
        if proc_query.validate_procedure_queries(RS_CLIENT):
            end = time.time()
            elapsed_validation = end - start
            print_and_log('Writing Extracted Procedure DDL code', logging.info)
            start = time.time()
            proc_query.save_code(RS_CLIENT)
            end = time.time()
            elapsed_saving = end - start
            break
        time.sleep(5)
        i += 1

    print_and_log(f'Procedure validation elapsed seconds: {elapsed_validation}', logging.info)
    print_and_log(f'Procedure extraction elapsed seconds: {elapsed_saving}', logging.info)

if __name__ == 'main':
    pass