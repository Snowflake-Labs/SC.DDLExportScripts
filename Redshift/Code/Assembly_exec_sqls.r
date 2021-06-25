###############################################################################
##  Date:           6/1/2021
##  Author:         Arturo Calvo.
##  Summary:        This script will assembly a snowsql call for each sql
##                  script generated at the route specified on line 22
##  Prerequisites:
##                  - R Studio.
##                  - stringr,readr,dplry,data.table packages already installed
##
##  Version:        1.0 - Created the script.
###############################################################################
## R < scriptName.R --no-save 
## Load packages
list.of.packages <- c("dplyr","data.table","stringr","readr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

for(pkg in list.of.packages){
  library(pkg, character.only = TRUE)
}

setwd("/workspace/SnowConvertDDLExportScripts/RedshiftMigrationLab/output_snowflake")
df <- data.table(list.files()) %>%
 mutate( command = paste("snowsql -a aws_cas2 -u acalvo_mobilize -r REDSHIFT_ROLE -w REDSHIFT_WH -d REDSHIFT -f",
 V1,sep=" ")) %>% select(command)


 write.table(df,file = "execute_queries.bash",col.names = FALSE, row.names = FALSE,quote = FALSE)
