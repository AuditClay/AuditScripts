"Demo for SEC557 Classes"
#Get-Member shows all the properties and methods associated with
#an object
Get-Service | Get-Member

#To show only properties, use the MemberType parameter
Get-Service | Get-Member -MemberType Property
Get-Service | Get-Member -MemberType Method

#Use Select-Object to specify what part of the output to consume 
Get-CimInstance win32_NetworkAdapterConfiguration 

#Select-Object * will show all properties for all objects returned
Get-CimInstance win32_NetworkAdapterConfiguration | Select-Object *

#Piping through format-list * (aliased to fl) will do the same
Get-CimInstance win32_NetworkAdapterConfiguration | fl *

#You can specify only the properties you need returned 
Get-CimInstance win32_NetworkAdapterConfiguration | Select-Object Description, MACAddress, DHCPEnabled, IPAddress

#override the default format for the output
Get-CimInstance win32_NetworkAdapterConfiguration | Select-Object Description, MACAddress, DHCPEnabled, IPAddress | Format-List

#Show only the first or last objects from a collection
Get-Process | Select-Object ProcessName -First 5
Get-Process | Select-Object ProcessName -Last 5

#Skip will skip the first objects in the pipeline before processing
Get-Process | Select-Object ProcessName -Skip 2 -First 5 

#Select-Object allows for "calculated properties".
#N and E are shorthand for 'name' and 'expression'
#This can be useful for changing the name of a property on the fly
1..5 | Select-Object @{Name='Original';Expression={$_}}, @{n='Double';e={$_ *2}}

#Use Where-Object with the comparison statement format
Get-Service | Where-Object Status -eq 'stopped'

#Use the script block format
Get-Service | Where-Object { $_.Status -eq 'stopped' }

#Sort-Object sorts the pipeline input in the way you specify
#Quotes render the parentheses safe in the property name
Get-Process | Sort-Object "WS(M)" -Descending | Select-Object -First 5

#Get-Unique returns unique items from a sorted list
#It is non-case-sensitive by default
5,5,4,7,2,5,6,1  | Sort-Object | Get-Unique

#Group-Object groups like objects together (works like the SQL 'Group By' clause)
#It returns a new object with Count, Name, and Group properties
Get-Service |Group-Object -Property StartType

#Comparison operators - commonly used with Where-Object or if statements
1 -lt 3
2 -gt 2
2 -ge 2
[Math]::Pi -gt 3

#Like operators - allows use of wildcards (not case-sensitive)
'SEC557' -like '*55*'
'SEC557' -like 'sec*'
'SEC557' -notlike 'sec*9'

#In operators
3 -in 1..7
5 -notin 1..4

#Contains operators
1..10 -contains 4
1..10 -notcontains 12
1..1000 -notcontains 12

# Other important operators to explore
## Is/IsNot
## Split
## Replace (like sed)

#BONUS - Regular expressions - use the -match operator
# regex for SEC followed by 1 or more digits
'SEC557' -match 'SEC[0-9]+'

#regex for SEC followed by EXACTLY 4 digits
#for case-sensitivity, use cmatch and cnotmatch
'SEC557' -match 'SEC[0-9]{4}'
'SEC557' -notmatch 'SEC[0-9]{4}'

#Select-string does regex matches against lines of text (think GREP)
(Get-NetIPAddress).IPAddress | Select-String "^10.*"

#Measure-Object is useful for counting lines and performing
#calculations on numeric fields
1,2,3,4,5 | Measure-Object -Average
1,2,3,4,5 | Measure-Object -Average -Sum -Maximum -Minimum

#Format-List puts output into one-property-per-line style
#Format-Table builds a one-object-per-line table
#Some cmdlets return different numbers of properties depending on how
#you format the output...
Get-Service | fl
Get-Service | ft

