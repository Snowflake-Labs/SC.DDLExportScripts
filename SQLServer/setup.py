#!/usr/bin/env python

# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.
# --------------------------------------------------------------------------------------------

import io
import os
import platform as _platform
import sys

from setuptools import setup
from setuptools.command.install import install

# Determine the correct platform for the webdriver
system = _platform.system()
arch, _ = _platform.architecture()
if system == 'Linux':
    arrange_tool = 'bin/linux64/ExtractionCleanUp'
if system == 'Windows':
    arrange_tool = 'bin\\win64\\ExtractionCleanUp.exe'
if system == 'Darwin':
    arrange_tool = 'bin/mac64/ExtractionCleanUp'

SQL_EXPORT_VERSION = '0.0.7'

CLASSIFIERS = [
    'Development Status :: 3 - Alpha',
    'Intended Audience :: Developers',
    'Intended Audience :: System Administrators',
    'Programming Language :: Python',
    'Programming Language :: Python :: 2',
    'Programming Language :: Python :: 2.7',
    'Programming Language :: Python :: 3',
    'Programming Language :: Python :: 3.4',
    'Programming Language :: Python :: 3.5',
    'Programming Language :: Python :: 3.6',
    'License :: OSI Approved :: MIT License'
]

DEPENDENCIES = [
    "mssql-scripter",
    'future>=0.16.0',
    'wheel>=0.29.0'    
]

setup(
    install_requires=DEPENDENCIES,
    name='snowconvert-export-sqlserver',
    version=SQL_EXPORT_VERSION,
    description='Mobilize.Net SQLServer Export Tool for SnowConvert',
    license='MIT',
    author='Mobilize.Net',
    author_email='mauricio.rojas@mobilize.net',
    url='https://github.com/mobilize/SnowConvertDDLExportScripts/SQLServer',
    zip_safe=True,
    long_description=open('README.rst').read(),
    long_description_content_type = "text/x-rst",
    classifiers=CLASSIFIERS,
    include_package_data=True,
    scripts=[
        'sc-sqlserver-export',
        'sc-sqlserver-export.ps1',
        'sc-sqlserver-arrange',
        'sc-sqlserver-arrange.bat'
    ],
    packages=[
        "sqlarrange"
    ]
)