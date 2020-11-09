"Demo for ISACANTX Nov 13, 2020"
#Get a list of the output processing commands
Get-Command Out*

#Out-Default is the output processor used if nothing is specified
Get-Process | Out-Default

#Out-Gridview opens a window with the command results in a grid
Get-Process | Out-GridView

#Out-Null silently drops the output
Get-Service | Out-Null

#Out-File saves to a file
Get-Acl -Path C:\Windows | Format-List * | Out-File .\acl.txt
Get-Content .\acl.txt

#Out-file is useful with the Convert* commands
Get-Command Convert*

Get-Acl | ConvertTo-Csv
Get-service | ConvertTo-Html | Out-File service.html
start .\service.html

#JSON
Get-Date | ConvertTo-Json
$j = Get-Date | ConvertTo-Json 
$j

$j | ConvertFrom-Json

#XML
Get-Service -name X* | ConvertTo-Xml 
(Get-Service -name X* | ConvertTo-Xml).InnerXml
(Get-Service -name X* | ConvertTo-Xml).InnerXml 
#NOTE - PoSh is missing a ConvertFrom-XML function. 
#There are third party modules to add this functionality


#Tee-Object redirects to a file, but still passes output to the pipeline
Get-Service | where status -eq "running" | 
  Tee-Object -FilePath service.txt | 
  Sort-Object DisplayName -Descending

Get-Content .\service.txt

#Use Select-Object to specify what part of the output to consume 
Get-WmiObject win32_NetworkAdapterConfiguration 
Get-WmiObject win32_NetworkAdapterConfiguration | Select-Object *

Get-WmiObject win32_NetworkAdapterConfiguration | 
  Select-Object Description, MACAddress, DHCPEnabled, IPAddress

#override the default format for the output
Get-WmiObject win32_NetworkAdapterConfiguration | 
  Select-Object Description, MACAddress, DHCPEnabled, IPAddress |
  Format-List

#Use Where-Object with the comparison statement format
Get-Service | Where-Object Status -eq 'stopped’

#Use the script block format
Get-Service | Where-Object { $_.Status -eq 'stopped’ }

#Comparison operators - commonly used with Where-Object or if statements
1 -lt 3
2 -gt 2
2 -ge 2
[Math]::Pi -gt 3

#Contains operators
1..10 -contains 4
1..10 -notcontains 12
1..1000 -notcontains 12

#In operators
3 -in 1..7
5 -notin 1..4

#Like operators - allows use of wildcards (not case-sensitive)
'AUD507' -like '*50*'
'AUD507' -like 'aud*'
'AUD507' -notlike 'aud*9'

#BONUS - Regular expressions - use the -match operator
# regex for AUD followed by 1 or more digits
'AUD507' -match 'AUD[0-9]+'

#regex for AUD followed by EXACTLY 4 digits
'AUD507' -match 'AUD[0-9]{4}'

"The End"