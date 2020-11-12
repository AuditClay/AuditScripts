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

#Next we would make a script to process the file and output the results in the Graphite import format
#Here's the script we wrote:
Get-Content processResults.ps1

#And here's the output when we run it against a file
.\processResults.ps1 -fileName .\Results_set_0.csv

#We could even run against all the CSVs to make one big import file
.\processResults.ps1 -fileName (Get-ChildItem *.csv)

#Setup the text file
$resultsFile = ".\vulnData.txt"
if(Test-Path -Path $resultsFile ) {Remove-Item -Path $resultsFile -Force}

#Run the script and save the results to a file, ready for import
.\processResults.ps1 -fileName (Get-ChildItem *.csv) | Out-File -FilePath vulnData.txt -Encoding ascii

#view the contents of the file
Get-Content .\vulnData.txt

#To import the file, we'll use the Unix netcat command to dump the file to Graphite Carbon intake daemon
Get-Content .\vulnData.txt | wsl nc -vv -N 10.50.7.50 2003

if(Test-Path -Path $resultsFile ) {Remove-Item -Path $resultsFile -Force}

Set-Location ..
