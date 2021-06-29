import teraexport
import argparse
import sys
import os
import stat

args = sys.argv[1:]
parser = argparse.ArgumentParser(
        prog=u'sc-tera-export',
        description=u'Mobilize.NET Teradata Code Export Tools' +
        'Version ' + teraexport.__version__)

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

try:
    input = raw_input
except NameError:
    pass

print("This tool will generate some bash shell and BTEQ scripts in the current folder ")
print("that will be used to export the Teradata Database Code that will be upgraded to Snowflake.")
answer = input("Please confirm to continue [y/n]?")
answer = answer.lower()

if answer and answer.startswith("y"):
    print("continue")
else:
    print()
    print("Bye. Teradata Export for SnowConvert Terminated")
    exit(1)

## Get python module directory
teraexportdir = os.path.dirname(os.path.realpath(__file__))

bindir =  os.path.realpath(os.path.join(teraexportdir,"bin"))
scriptsdir =  os.path.realpath(os.path.join(teraexportdir,"scripts"))

# current dir 
cwd = os.getcwd()

# Create Target Dirs
target_bindir = os.path.join(cwd, "bin")
target_scriptdir = os.path.join(cwd,"scripts")

try:
        os.mkdir(target_bindir)
except:
        #ignore error
        pass
try:
        os.mkdir(target_scriptdir)
except:
        #ignore error
        pass        

## read create_ddls
with open(os.path.join(bindir,"create_ddls.sh"),"r") as f:
    contents = f.read()
    contents = contents.replace("@@VERSION",teraexport.__version__)
    contents = contents.replace("@@SERVER",parameters.Server)
    contents = contents.replace("@@USER",parameters.UserId)
    contents = contents.replace("@@PASSWORD",parameters.Password)
    with open(os.path.join(target_bindir,"create_ddls.sh"),"w+") as fout:
        fout.write(contents)

# copy create_load_to_sf
os.system("cp " + os.path.join(bindir,"create_load_to_sf.sh") + " " + os.path.join(target_bindir, "create_load_to_sf.sh"))

# make the scripts executable
os.chmod(os.path.join(target_bindir, "create_ddls.sh"),(
        stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IWGRP | stat.S_IROTH | 
        stat.S_IXGRP | stat.S_IXUSR | stat.S_IXOTH))
os.chmod(os.path.join(target_bindir, "create_load_to_sf.sh"),(
        stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IWGRP | stat.S_IROTH | 
        stat.S_IXGRP | stat.S_IXUSR | stat.S_IXOTH))

# copy all bteq scripts
os.system("cp -rf " + scriptsdir + " " + target_scriptdir)

# open the script on an editor so the user can customize it
editor = os.getenv('EDITOR') or "vi"
if editor:
    os.system(editor + ' ' + os.path.join(target_bindir,"create_ddls.sh"))

os.system("cd " + target_bindir)
print("You can now execute get into the 'bin' directory and run the generated 'create_ddls.sh' script.")
print("IMPORTANT: Before running review it to make sure that the databases you want to include/exclude are properly set")