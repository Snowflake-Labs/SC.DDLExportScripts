#
#####Constants
ERROR='\033[0;31m' # Red
NC='\033[0m' # No Color


#####Parameters
logon_command="$1"
if [ ! "$logon_command" ];then
   echo "${ERROR}Logon command not provided${NC}"
   exit 1
fi

bteq << EOF
.logon $logon_command;
-- 500 MB, final size should be < 300 MB
DELETE DATABASE SC_EXAMPLE_DEMO ALL;
MODIFY DATABASE SC_EXAMPLE_DEMO AS DROP DEFAULT JOURNAL TABLE;

DROP DATABASE SC_EXAMPLE_DEMO;
EOF
