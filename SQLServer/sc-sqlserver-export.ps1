

Write-Object "    usage: sc-tera-export [-h] [--connection-string CONNSTR] [-D|--database database] [-S|--server SERVER] [-U|--user USER] [-P|--password PASSWORD]"
Write-Object ""
Write-Object "    Mobilize.NET SQLServer Code Export ToolsVersion X.X.X"
Write-Object ""
Write-Object "    optional arguments:"
Write-Object "    -h, --help        show this help message and exit"
Write-Object "    -C , --connection-string"
Write-Object "                      DB connection string"
Write-Object "    -S , --server     Server address or name"
Write-Object "    -D , --database   Database name"
Write-Object "    -U , --user       Login ID for server"
Write-Object "    -P , --password   The password for the given user."




for ( $i = 0; $i -lt $args.count; $i++ ) {
    if ($args[ $i ] -eq "-h" || $args[ $i ] -eq "--help" )              { $HELP="TRUE"}
    if ($args[ $i ] -eq "-C" || $args[ $i ] -eq "--connection-string" ) { $CONNSTR =$args[ $i+1 ]}
    if ($args[ $i ] -eq "-S" || $args[ $i ] -eq "--server" )            { $SERVER  =$args[ $i+1 ]}
    if ($args[ $i ] -eq "-D" || $args[ $i ] -eq "--database" )          { $DATABASE=$args[ $i+1 ]}
    if ($args[ $i ] -eq "-U" || $args[ $i ] -eq "--user" )              { $USER    =$args[ $i+1 ]}
    if ($args[ $i ] -eq "-P" || $args[ $i ] -eq "--password" )          { $PASSWORD=$args[ $i+1 ]}
}



if ([string]::IsNullOrWhiteSpace($CONNSTR) && [string]::IsNullOrWhiteSpace($SERVER))
{
    echo "Please specify connection information using --connection-string or --server and/or --database --user."
}

if (![string]::IsNullOrWhiteSpace($CONNSTR))
{
    mssql-scripter --connection-string  --file-by-object -f ./output    
}

if (![string]::IsNullOrWhiteSpace($CONNSTR))
{
    Write-Host "SERVER  : $SERVER"
    Write-Host "DATABASE: $DATABASE"
    Write-Host "USER    : $DATABASE"
    mssql-scripter -S $SERVER -U $USER -P $PASSWORD --file-by-object -f ./output
}


