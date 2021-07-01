import sqlexport
import argparse
import sys
import os
import stat
from builtins import FileExistsError

args = sys.argv[1:]
parser = argparse.ArgumentParser(
        prog=u'sc-sqlserver-export',
        description=u'Mobilize.NET SQLServer Code Export Tools' +
        'Version' + sqlexport.__version__)

parser.add_argument(
        '--connection-string',
        dest='ConnectionString',
        help='Connection string of the server to script')

parser.add_argument(
        u'-S', u'--server',
        dest=u'Server',
        required=True,
        metavar=u'',
        help=u'Server Name')

parser.add_argument(
        u'-U', u'--user',
        dest=u'User',
        metavar=u'',
        required=True,
        help=u'User name')

parser.add_argument(
        u'-P', u'--password',
        dest=u'Password',
        required=True,
        metavar=u'',
        help=u'The password for the given user.') 

parameters = parser.parse_args(args)

