DBPASS=$1
if [ -z "$DBPASS" ]
then
    echo "Please provide password for the DB Instanace"
    read DBPASS
fi

docker run -itd --name mydb2 --privileged=true -p 50000:50000 -e LICENSE=accept -e DB2INST1_PASSWORD=$DBPASS -e DBNAME=testdb -v $CODESPACE_VSCODE_FOLDER/Tests/DB2/database:/database -v $CODESPACE_VSCODE_FOLDER/DB2:/DDLExportScripts/export ibmcom/db2
docker exec -ti mydb2 bash -c "su - db2inst1"

#if you get errors saying that the database did not start, you can try this out.
#a)   db2trc on -f db2trace.out
#b)   db2start
#c)   db2trc off