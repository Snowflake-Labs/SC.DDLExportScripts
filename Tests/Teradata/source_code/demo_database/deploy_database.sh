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
  .RUN FILE ./database_code/DDL_Databases.sql
  DATABASE SC_EXAMPLE_DEMO;
  GRANT ALL PRIVILEGES ON SC_EXAMPLE_DEMO
  TO DBC
  WITH GRANT OPTION;

  .RUN FILE ./database_code/DDL_SF_Schemas.sql
  .RUN FILE ./database_code/DDL_Tables.sql
  .RUN FILE ./database_code/DDL_Trigger.sql
  .RUN FILE ./database_code/DDL_Views.sql
  .RUN FILE ./database_code/DDL_CreateMacro.sql
  .RUN FILE ./database_code/DDL_JoinIndex.sql
  .COMPILE FILE = ./database_code/UPDATE_VEMPLOYEE.sql
  .COMPILE FILE = ./database_code/INSERT_VEMPLOYEE.sql
  .RUN FILE ./database_code/my_yyyymmdd_to_date2.sql
EOF
