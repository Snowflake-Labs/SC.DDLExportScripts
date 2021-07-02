import subprocess as sp
import sys
import platform
import os


# Determine the correct platform for the webdriver
system = platform.system()
arch, _ = platform.architecture()
if system == 'Linux':
    arrange_tool = 'bin/linux64/ExtractionCleanUp'
if system == 'Windows':
    arrange_tool = 'bin\\win64\\ExtractionCleanUp.exe'
if system == 'Darwin':
    arrange_tool = 'bin/mac64/ExtractionCleanUp'


stdlib_dir = os.path.dirname(__file__)
path = stdlib_dir
command = os.path.join(path,arrange_tool)
#if system == 'Linux' or system == 'Darwin':
#    os.chmod(os.path.join(path, arrange_tool),0o0755)
sp.call([command] + sys.argv[1:])