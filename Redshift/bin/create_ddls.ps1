
# GENERAL INSTRUCTIONS: This script is used to extract object DDL from your RedShift Cluster. Please adjust the variables with enclosed by <>
#                       below to match your environment. Once completed, your extracted DDL code will be stored in the object_extracts folder.

# Script version
$version = "0.1.1"

# ---- Variables to change ----

# General Variables
$OUTPUT_PATH="<C:\example>"

if ($OUTPUT_PATH -match '(?:\\|\/)*$')
{
    # Remove trailing slashes
    $OUTPUT_PATH = $OUTPUT_PATH -replace '(?:\\|\/)*$', ''
}

# AWS RedShift Variables
$RS_CLUSTER="<RS Cluster Identifier>"
$RS_DATABASE="<Database name>"
$RS_SECRET_ARN="<Secret ARN>"

# Script Variables
$SCHEMA_FILTER="lower(schemaname) LIKE '%'"
$MAX_ITERATIONS=60 #Every iteration waits 5 seconds. Must be > 0.
# ---- END: Variables to change ----


if($MAX_ITERATIONS -lt 0)
{
    $MAX_ITERATIONS = 60
    Write-Output "Detected iterations less than 0. Setting to 60."
}

function Check-Command($cmdname)
{
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

if (-not (Check-Command -cmdname "aws"))
{
     Write-Output "AWS Cli not found. Please check this link on how to install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
     exit
}

Write-Output "Creating output folders..."

$ddl_output = "$OUTPUT_PATH\object_extracts\DDL"
$log_output = "$OUTPUT_PATH\log"

## Create directories
New-Item -ItemType Directory -Force -Path $OUTPUT_PATH | Out-Null
New-Item -ItemType Directory -Force -Path $log_output | Out-Null
New-Item -ItemType Directory -Force -Path $OUTPUT_PATH\object_extracts | Out-Null
New-Item -ItemType Directory -Force -Path $ddl_output | Out-Null
New-Item -ItemType File -Force -Path $ddl_output\.sc_extracted | Out-Null

## Created log files and tracking variables
Out-File -FilePath $log_output\log.txt -InputObject "--------------" -Append
Out-File -FilePath $log_output\log.txt -InputObject "Starting new extraction" -Append
Out-File -FilePath $log_output\log.txt -InputObject "Variables:" -Append
Out-File -FilePath $log_output\log.txt -InputObject $OUTPUT_PATH -Append
Out-File -FilePath $log_output\log.txt -InputObject $SCHEMA_FILTER -Append

# Defined main variables
Write-Output "Getting queries from files..."
$queries = @{} # Hash to control queries execution
$files = (Get-ChildItem -Path ../scripts/* -Include *.sql).Name # Get list of queries

Write-Output "Sending queries to execute..."
foreach ( $file in $files)
{
    $query = Get-Content ..\scripts/$file -Raw
    $query = $query.replace('{schema_filter}', $SCHEMA_FILTER)
    # Execute queries on Resdshift
    $response = aws redshift-data execute-statement --cluster-identifier $RS_CLUSTER --database $RS_DATABASE --secret-arn $RS_SECRET_ARN --sql "$query" | ConvertFrom-Json
    $queries[$file] = $response.Id
}

Write-Output "Waiting 20 seconds for queries to finish..."
Start-Sleep -Seconds 20

Write-Output "Starting query validation and extraction iterations..."
$i = 0
while($i -ne $MAX_ITERATIONS)
{
    $i++
    if($queries.keys.count -ne 0)
    {
        # List to remove queries from Hash for next iteration when finished
        $to_remove = [System.Collections.Generic.List[string]]::new()
        foreach( $query in $queries.keys )
        {
            $id = $queries[$query]
            Write-Output "Validating completion for query $query..."
            # Get statement state
            $response = aws redshift-data describe-statement --id $id | ConvertFrom-Json
            if ($response.Status -eq "FINISHED")
            {
                Write-Output "Query finished, starting extraction..."
                # Get statement results when finished
                $results_response = aws redshift-data get-statement-result --id $id | ConvertFrom-Json
                $data = $results_response.Records
                # Add comment header to the file
                $currentDate = Get-Date -Format "MM/dd/yyyy"
                $headerComment = "-- <sc_extraction_script> Redshift code extracted using script version $VERSION on $currentDate <sc_extraction_script>"
                Out-File -FilePath $ddl_output\$query -InputObject $headerComment -Encoding utf8
                $strings_data = [System.Collections.Generic.List[string]]::new()
                $data | ForEach-Object { $strings_data.Add($PSItem.stringValue) }
                Out-File -FilePath $ddl_output\$query -InputObject $strings_data -Append -Encoding utf8
                $to_remove.Add($query)
            } elseif ($response.Status -eq "FAILED") {
                Write-Output "Query failed... Error message:"
                Write-Output $response.Error
                # Save error to log
                Out-File -FilePath $log_output\log.txt -InputObject "Failed query:" -Append
                Out-File -FilePath $log_output\log.txt -InputObject $query -Append
                Out-File -FilePath $log_output\log.txt -InputObject $id -Append
                Out-File -FilePath $log_output\log.txt -InputObject $response.Error -Append
                $to_remove.Add($query)
            } else {
                Write-Output "Query still pending. Validating again in some seconds."
            }
        }
        foreach($query in $to_remove)
        {
            $queries.Remove($query)
        }
    } else {
        break
    }
    # Wait before continuing with next iteration
    Start-Sleep -Seconds 5
}

if($queries.keys.count -gt 0)
{
    Write-Output "Not all queries have finished. Consider increasing iterations value to increase timeout."
} else
{
    Write-Output "Finished extracting RedShift DDL. Please check for output in the specified folder."
}







