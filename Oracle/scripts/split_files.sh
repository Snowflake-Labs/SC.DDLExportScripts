## ----- Function to move files
move_file() {
    local file=$1
    local FLNAME=$(grep -o -P "(?<=<${STERM}> )(.*?\..*?)(?= </${STERM}>)" $file | cut -d . -f 2)
    local DBNAME=$(grep -o -P "(?<=<${STERM}> )(.*?\..*?)(?= </${STERM}>)" $file | cut -d . -f 1)
    mkdir -p "${OUTPUT_PATH}/${DBNAME}/${SSUFF}"
    mv $file "${OUTPUT_PATH}/${DBNAME}/${SSUFF}/${FLNAME}.sql"
}
export -f move_file

## ---- Split array     
declare -a split_terms=(
[0]="sc-table"
[1]="sc-view"
[2]="sc-function"
[3]="sc-procedure" 
[4]="sc-package" 
[5]="sc-synonym" 
[6]="sc-type"
[7]="sc-index"
[8]="sc-trigger"
[9]="sc-sequence"
[10]="sc-dblink"
[11]="sc-queue_table" 
[12]="sc-olap_cube"
[13]="sc-materialized_view" 
[14]="sc-queue"
[15]="sc-analytic_view" 
[16]="sc-operator"
)

declare -a split_suffix=(
[0]="Tables"
[1]="Views"
[2]="Functions"
[3]="Procedures" 
[4]="Packages" 
[5]="Synonyms" 
[6]="Types"
[7]="Indexes"
[8]="Triggers"
[9]="Sequences"
[10]="DBlink"
[11]="QUEUE_TABLES" 
[12]="OLAP_CUBES"
[13]="MATERIALIZED_VIEWS" 
[14]="QUEUES"
[15]="ANALYTIC_VIEWS" 
[16]="OPERATORS"
)

## ---- Loop through and split
for ((i=0;i<=16;i++)); 
do 
    export STERM=${split_terms[$i]}
    export SSUFF=${split_suffix[$i]}

    export FILE="${OUTPUT_PATH}/object_extracts/DDL/DDL_${SSUFF}.sql"

    if [ -s "${FILE}" ]; then
        echo "Processing file ${FILE}"
        mkdir -p "${OUTPUT_PATH}/object_extracts/DDL/${SSUFF}"
        csplit -k ${FILE} -f "${OUTPUT_PATH}/object_extracts/DDL/${SSUFF}/${SSUFF}_" "/<${STERM}>/" {9999999} -b "%07d.sql" -s
        rm "${OUTPUT_PATH}/object_extracts/DDL/${SSUFF}/${SSUFF}_0000000.sql"
        DDL_PATH="${OUTPUT_PATH}/object_extracts/DDL"

        for FILES in "${OUTPUT_PATH}/object_extracts/DDL/${SSUFF}/*"; 
            do
                for FILE in $FILES;
                do 
                    FULLNAME=$(sed -n "s/\/\* \<${STERM}\>\(.*\)\<\/${STERM}\> \*\//\1/p" $FILE)
                    IFS="." read -ra nameParts <<< "$FULLNAME" 
                    SCHEMA_NAME=${nameParts[0]}
                    SCHEMA_NAME=$(echo $SCHEMA_NAME | tr -d ' ')
                    OBJECT_NAME=${nameParts[1]}
                    OBJECT_NAME=$(echo $OBJECT_NAME | tr -d ' ')

                    mkdir -p "${DDL_PATH}/${SCHEMA_NAME}"
                    FINAL_FOLDER="${DDL_PATH}/${SCHEMA_NAME}/${SSUFF}"
                    mkdir -p $FINAL_FOLDER
                    mv $FILE "${FINAL_FOLDER}/${OBJECT_NAME}.sql"

                done
        done

    else 
        echo "File ${FILE} is empty"
    fi
    rm -f "${OUTPUT_PATH}/object_extracts/DDL/DDL_${SSUFF}.sql"
    rmdir "${OUTPUT_PATH}/object_extracts/DDL/${SSUFF}"
done

for ((i=0;i<=16;i++)); 
do 
    export SSUFF=${split_suffix[$i]}
done

touch -- "${OUTPUT_PATH}/object_extracts/DDL/.scextracted"  