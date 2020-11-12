"Demo for ISACANTX Nov 13, 2020"

Set-Location .\Nessus
#We'll need a date for the import file for Grafana
Get-Date

#I usually save the date/time for daily measurements to midnight (UTC) if you have multiple time xones
Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0

#The date will need to be in Unix epoch format for import into Graphite
$epochTime = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0 -UFormat %s
$epochTime

$d = import-csv -path .\Results_set_0.csv

$results = ($d | Where-Object risk -ne 'none' | Select-Object host, risk |Group-Object host,risk |select-object Name,Count)

$resultsFile = ".\vulnData.txt" 
if(Test-Path -Path $resultsFile ) {Remove-Item -Path $resultsFile -Force}

$time = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0 -UFormat %s
foreach( $res in $results )
{
  $graphitePath = "vuln." + ($res.Name -replace "\.","-" -replace ", ", ".")
  $vulnCount = $res.Count
  write-output "$graphitePath $vulnCount $time" | Out-File -FilePath $resultsFile -Encoding ascii -Append
}