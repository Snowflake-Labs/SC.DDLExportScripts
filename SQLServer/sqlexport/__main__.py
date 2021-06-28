import teraexport
import argparse
import sys
import os
import stat
from builtins import FileExistsError

args = sys.argv[1:]
parser = argparse.ArgumentParser(
        prog=u'sc-sqlserver-export',
        description=u'Mobilize.NET SQLServer Code Export Tools' +
        'Version {}'.format(teraexport.__version__))

parser.add_argument(
        u'-S', u'--server',
        dest=u'Server',
        required=True,
        metavar=u'',
        help=u'Server address. For example: 127.0.0.1')

parser.add_argument(
        u'-U', u'--user',
        dest=u'UserId',
        metavar=u'',
        required=True,
        help=u'Login ID for server. Usually it will be the DBC user')

parser.add_argument(
        u'-P', u'--password',
        dest=u'Password',
        required=True,
        metavar=u'',
        help=u'The password for the given user.') 

parameters = parser.parse_args(args)

// TODO in progress