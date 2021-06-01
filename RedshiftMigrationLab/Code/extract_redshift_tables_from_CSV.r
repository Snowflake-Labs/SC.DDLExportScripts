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

## Load packages
for(pkg in c("dplyr","data.table","stringr","readr")){
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
if(!file.exists("output",sep = "/")))
{dir.create(file.path("output"), showWarnings = FALSE)}
setwd("output")

for(filename in file_list){
  write.table(df %>% filter(tablename == filename) %>% select(ddl),
              file = paste(filename,".sql",sep=""),sep = "\n",
              col.names = FALSE,row.names = FALSE,quote = FALSE)
}

print("COMPLETED")
