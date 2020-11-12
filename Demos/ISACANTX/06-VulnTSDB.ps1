"Demo for ISACANTX Nov 13, 2020"
#This demo covers the process to import vulnerabilty scan data into Graphite periodically
#We'll need to build a text file in Graphite input format:
#metric.name value epcohTime
# e.g. patchage.Server53 4 1574208000
Set-Location .\Nessus
#We'll need a date for the import file for Grafana
Get-Date

#I usually save the date/time for daily measurements to midnight (UTC) if you have multiple time xones
Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0

#The date will need to be in Unix epoch format for import into Graphite
$epochTime = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0 -UFormat %s
$epochTime

#Grab the results from a single CSV into a variable
$d = import-csv -path .\Results_set_0.csv

#Get just the vulnerabilities not scored as 'None' and group them so we can get a count per host, per risk level
$results = ($d | Where-Object risk -ne 'none' | Select-Object host, risk |Group-Object host,risk |select-object Name,Count)

#View the results for this CSV
$results

#Setup the text file
$resultsFile = ".\vulnData.txt"
if(Test-Path -Path $resultsFile ) {Remove-Item -Path $resultsFile -Force}

#Run a loop to process all the results
foreach( $res in $results )
{
  $graphitePath = "vuln." + ($res.Name -replace "\.","-" -replace ", ", ".")
  $vulnCount = $res.Count
  write-output "$graphitePath $vulnCount $epochTime" 
}

#Let's save that to the file
foreach( $res in $results )
{
  $graphitePath = "vuln." + ($res.Name -replace "\.","-" -replace ", ", ".")
  $vulnCount = $res.Count
  write-output "$graphitePath $vulnCount $epochTime" | Out-File -FilePath $resultsFile -Encoding ascii -Append
}