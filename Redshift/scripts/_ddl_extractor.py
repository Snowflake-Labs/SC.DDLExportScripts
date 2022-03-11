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
            while('NextToken' in resp):
                next_token = resp['NextToken']
                resp = client.get_statement_result(Id=self.query_id, NextToken=next_token)
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


def read_ddl_queries():
    queries = []
    for f in os.listdir('.'):
        if f.endswith(".sql") and '_manual_' not in f:
            object_type_regex = re.search(r'^DDL_(.*)\.sql', f, )
            with open(f, 'r') as file:
                object_type = object_type_regex.group(1)
                file_content = file.read()
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
args = parser.parse_args()

RS_CLUSTER = args.rs_cluster
RS_DATABASE = args.rs_database
RS_SECRET_ARN = args.rs_secret_arn
OUT_PATH = args.output_path
SCHEMA_FILTER = args.schema_filter

current_date = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
log_path = os.path.join(OUT_PATH, 'log', f'{current_date}.log')
logging.basicConfig(filename=log_path, level=logging.INFO)

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

    while i <= 60:
        print(f'>>> Query result retrieval attempt {i}/60')
        try:
            if q.get_code(RS_CLIENT):
                q.save_code()
                break
        except RuntimeError as e:
            print(f'WARNING: Failed to extract data for {q.object_type}. Please check the logs for full error message.')
            logging.exception(e)
            break
        time.sleep(5)
        i += 1

if __name__ == 'main':
    pass
