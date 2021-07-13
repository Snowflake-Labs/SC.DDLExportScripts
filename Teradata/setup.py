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

TERA_EXPORT_VERSION='0.0.10'

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
    'License :: OSI Approved :: MIT License',
]

DEPENDENCIES = []

setup(
    install_requires=DEPENDENCIES,
    name='snowconvert-export-tera',
    version=TERA_EXPORT_VERSION,
    description='Mobilize.Net Teradata Export Tool for SnowConvert',
    license='MIT',
    author='Mobilize.Net',
    author_email='mauricio.rojas@mobilize.net',
    url='https://github.com/mobilize/SnowConvertDDLExportScripts/Teradata',
    zip_safe=False,
    long_description=open('README.rst').read(),
    long_description_content_type = "text/x-rst",
    classifiers=CLASSIFIERS,
    include_package_data=True,
    scripts=[
        'sc-tera-export',
        'sc-tera-split-ddl'
    ],
    packages=[
        'teraexport',
        'split'
    ]
)