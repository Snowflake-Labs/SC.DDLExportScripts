






for ( $i = 0; $i -lt $args.count; $i++ ) {
    if ($args[ $i ] -eq "-h" || $args[ $i ] -eq "--help" )              { $HELP="TRUE"}
    if ($args[ $i ] -eq "-C" || $args[ $i ] -eq "--connection-string" ) { $CONNSTR =$args[ $i+1 ]}
    if ($args[ $i ] -eq "-S" || $args[ $i ] -eq "--server" )            { $SERVER  =$args[ $i+1 ]}
    if ($args[ $i ] -eq "-D" || $args[ $i ] -eq "--database" )          { $DATABASE=$args[ $i+1 ]}
    if ($args[ $i ] -eq "-U" || $args[ $i ] -eq "--user" )              { $USER    =$args[ $i+1 ]}
    if ($args[ $i ] -eq "-P" || $args[ $i ] -eq "--password" )          { $PASSWORD=$args[ $i+1 ]}
}

if ($HELP = "TRUE") {
    Write-Host "    usage: sc-sqlserver-export [-h] [--connection-string CONNSTR] [-D|--database database] [-S|--server SERVER] [-U|--user USER] [-P|--password PASSWORD]"
    Write-Host ""
    Write-Host "    Mobilize.NET SQLServer Code Export ToolsVersion X.X.X"
    Write-Host ""
    Write-Host "    optional arguments:"
    Write-Host "    -h, --help        show this help message and exit"
    Write-Host "    -C , --connection-string"
    Write-Host "                      DB connection string"
    Write-Host "    -S , --server     Server address or name"
    Write-Host "    -D , --database   Database name"
    Write-Host "    -U , --user       Login ID for server"
    Write-Host "    -P , --password   The password for the given user."
}

if (!$CONNSTR && !$SERVER)
{
    echo ""
    echo "Please specify connection information using --connection-string or --server and/or --database --user."
}

if ($CONNSTR)
{
    mkdir -p ./output/DDL
    mssql-scripter --connection-string  --file-per-object -f ./output/DDL
    exit 0
}

if ($SERVER)
{
    Write-Host "SERVER  : $SERVER"
    Write-Host "DATABASE: $DATABASE"
    Write-Host "USER    : $DATABASE"
    mkdir -p ./output/DDL
    mssql-scripter -S $SERVER -U $USER -P $PASSWORD --file-per-object -f ./output/DDL
    exit 0
}


