import os
import subprocess
import sys
import time
from sys import stderr
from dotenv import load_dotenv
from sys import platform
import io
import snowflake.connector
import re

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'

    def disable(self):
        self.HEADER = ''
        self.OKBLUE = ''
        self.OKGREEN = ''
        self.WARNING = ''
        self.FAIL = ''
        self.ENDC = ''

def print_expanded(str):
    use_colors = os.getenv('USE_COLORS')
    if use_colors:
        import colorful as cf
        print('{c.magenta}{str}{c.reset}'.format(c=cf,str=str))
    else:
        print(str)

def print_nonexpanded(str):
    use_colors = os.getenv('USE_COLORS')
    if use_colors:
        import colorful as cf
        print('{c.cyan}{str}{c.reset}'.format(c=cf,str=str))
    else:
        print(str)


PYTHON = "python"

if platform == "darwin":
    # OS X
    PYTHON = "python3"

# current path will return the workspace
currentpath = os.getcwd()
currentdir = os.path.dirname(currentpath)

class ProcessResults:
    returncode = -1
    stdout = ""
    stderr = ""


def expandvars_abnitio(text):
    def replace_var(m):
        varname = m.group(1)
        return os.getenv("ABINITIO_" + varname, "<" + varname + ">")
    reVar =  r"\<(\w+)\>"
    return re.sub(reVar, replace_var, text)


prog = re.compile(r"\<(\w+)\>")

def fix_abinitio_vars(fullscript):
    fullscript_contents = open(fullscript,"r").read()

    if re.search(prog,fullscript_contents):
        # it has ab_initio vars
        fullscript_contents = expandvars_abnitio(fullscript_contents)
        with open(fullscript + ".abinitio.py","w") as f:
            f.write(fullscript_contents)
        return True, fullscript + ".abinitio.py"
    return False, None

def log_on(user=None, password=None, account=None, database=None,warehouse=None, login_timeout = 10):
        # exclude arguments passed inline to the script
        # args = [item for item  in sys.argv if not item.startswith("--param-")]
        user = user or os.getenv("SNOW_USER",None)
        password = password or os.getenv("SNOW_PASSWORD", None)
        account = account or os.getenv("SNOW_ACCOUNT", None)
        database = database or os.getenv("SNOW_DATABASE", None)
        warehouse = warehouse or os.getenv("SNOW_WAREHOUSE", None)
        print(f"login on {account}.{database} wh {warehouse} user {user}")
        c = None
        try:
            c = snowflake.connector.connect(
                user=user,
                password=password,
                account=account,
                database=database,
                warehouse = warehouse,
                login_timeout=login_timeout
            )
        except:
           return None
        return c

def expandvars(path, params, skip_escaped=False):
    """Expand environment variables of form $var and ${var}.
       If parameter 'skip_escaped' is True, all escaped variable references
       (i.e. preceded by backslashes) are skipped.
       Unknown variables are set to 'default'. If 'default' is None,
       they are left unchanged.
    """
    def replace_var(m):
        varname = m.group(3) or m.group(2)
        passvalue = params.get(varname, None)
        return os.getenv(varname, m.group(0) if passvalue is None else passvalue)
    reVar = (r'(?<!\)' if skip_escaped else '') + r'(\$|\&)(\w+|\{([^}]*)\})'
    return re.sub(reVar, replace_var, path)

def empty_comments(str):
    def replace_comment(m):
        comment = m.group(0)
        return re.sub('.',' ',comment)
    regex = r"\/\*([^*]|[\r\n]|(\*+([^*\/]|[\r\n])))*\*+\/"
    return re.sub(regex, replace_comment, str)

def run_sql(script, new_vars=None):
    load_dotenv()
    if not new_vars is None:
        for x in new_vars:
            os.environ[x] = new_vars[x]
    con = log_on()
    res = ProcessResults()
    res.stdout = ""
    res.stderr = ""
    if con is None:
       res.stderr = "No connection"
       res.returncode = 333
       return
    else:
        try:
            current_line = 1
            fullscript = script
            fullscript_contents = open(fullscript,"r").read()
            print("\nReading script file " + fullscript)
            fullscript_with_no_comments = empty_comments(fullscript_contents)
            scripts = re.split(r';\s*(--.*)?\n',fullscript_with_no_comments)
            for s in scripts:
                if s is None:
                    continue
                s = s+"\n"
                print(f"Executing at aprox line {current_line}")
                print("SQL===============================================")
                print_nonexpanded(s)
                try:
                    if ("$" in s):
                        expanded = expandvars(s.strip(),{})
                        expanded = expandvars_abnitio(expanded)
                        print("EXPANDED==========================================")
                        print_expanded(expanded)
                        con.execute_string(expanded)
                    else:
                        expanded = expandvars_abnitio(s.strip())
                        con.execute_string(expanded)
                except snowflake.connector.errors.ProgrammingError as pe:
                    if pe.errno == 900: # Empty SQL Statement
                        print (">>> EMPTY STATEMENT")
                    else:
                        raise pe
                current_line = current_line + s.count('\n')
            res.returncode = 0
        except:
            e = sys.exc_info()
            msg = "Error in File: {0}({1})\n".format(fullscript, current_line)
            msg = msg + "*** Failure running statement\n{0}\n".format(e)
            res.stderr = msg
            res.stdout = "Error on script execution"
            print(msg)
            res.returncode = 8
    return res    

def run(script, new_vars=None):
    if script.endswith(".sql"):
        print("Current Directory: " +  os.getcwd())
        return run_sql(script, new_vars)
    else:
        REPO_ROOT = os.environ['GITPOD_REPO_ROOT']
        COVERAGE_DIR = os.path.join(REPO_ROOT,".snowqm","coverage_data")
        # make sure dir exists
        os.makedirs(COVERAGE_DIR, exist_ok=True)
        os.environ['COVERAGE_PROCESS_START'] = os.path.join(REPO_ROOT,".coveragerc")
        load_dotenv()
        if not new_vars is None:
            for x in new_vars:
                os.environ[x] = new_vars[x]        
        capture = True
        script_env = os.environ.copy()
        # we create a coverage file for each run
        script_env['COVERAGE_FILE'] = os.path.join(COVERAGE_DIR, ".coverage." + script.replace(os.sep,"_")) 
        basepath = os.path.dirname(script)
        script_only = os.path.basename(script).replace(".py","")
        process = subprocess.run([PYTHON,"-m",script_only], env=script_env,cwd=basepath, capture_output=capture)
        print(f"{bcolors.OKGREEN}{(process.stdout or b'').decode('utf-8')}{bcolors.ENDC}")
        print(f"{bcolors.WARNING}{(process.stderr or b'').decode('utf-8')}{bcolors.ENDC}")  
        return process
