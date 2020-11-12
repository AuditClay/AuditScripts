param( $fileName = "scan.csv" )

if( -not (Test-Path -Path $fileName))
{
    write-host "Please specify a valid input file"
    exit 1
}

$epochTime = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0 -UFormat %s

$d = import-csv -path $fileName

#Get just the vulnerabilities not scored as 'None' and group them so we can get a count per host, per risk level
$results = ($d | Where-Object risk -ne 'none' | Select-Object host, risk |Group-Object host,risk |select-object Name,Count)


foreach( $res in $results )
{
  $graphitePath = "scan." + ($res.Name -replace "\.","-" -replace ", ", ".")
  $vulnCount = $res.Count
  write-output "$graphitePath $vulnCount $epochTime" 
}
