###############################################################################
##  Date:           6/1/2021
##  Author:         Arturo Calvo.
##  Summary:        This script will read the csv file and separate each table
##                  DDL into separate files and save it on a output folder
##                  right next to the csv file.
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

#dir <- choose.dir(default = "", caption = "Select folder")
#setwd(dir)

## Get the .csv file exported from redshift query
#     select tablename,ddl from v_generate_tbl_ddl 
#     order by tablename,seq;
df <- data.table(read.csv(list.files(pattern="*.csv")))
# File list
file_list <- distinct(df %>% select(tablename))$tablename

## Folder where the output of this script will reside.
setwd("../")
if(!file.exists("output",sep = "/"))
{dir.create(file.path("output"), showWarnings = FALSE)}
setwd("output")

for(filename in file_list){
  write.table(df %>% filter(tablename == filename) %>% 
                mutate(shouldF = ifelse(grepl("ALTER",ddl)>0,1,0)) %>%
                filter(shouldF == 0) %>% select(ddl),
              file = paste(filename,".sql",sep=""),sep = "\n",
              col.names = FALSE,row.names = FALSE,quote = FALSE)
}


schemas_script <- distinct(df %>% mutate(shouldF = ifelse(grepl("CREATE TABLE",ddl)>0,1,0)) %>% filter(shouldF == 1) %>% mutate(
  schemas = gsub("\\..*$","",gsub("CREATE TABLE IF NOT EXISTS","",ddl)),
  final_sql = paste("CREATE OR REPLACE SCHEMA",schemas,";",sep = " ")
) %>% select(final_sql))

write.table(schemas_script,file = "schemas.sql",col.names = FALSE, row.names = FALSE,quote = FALSE)


print("COMPLETED")
