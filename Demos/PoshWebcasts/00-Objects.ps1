"Demo for PowerShellWebcast 1"
#Everything is passed as objects on the command line
#Objects have properties (data) and methods (functions)
#Launch a few instances of notepad so we can look at the process object
notepad;notepad;notepad

#Get-Process returns OBJECTS representing the running processes on the host
Get-Process -Name Notepad

#View a list of the methods and properties of the returned object
Get-Process -Name Notepad | Get-Member

#Get the Process ID for each instance (property)
#The parentheses tell PowerShell to treat each result of the command as an object
(Get-Process -Name Notepad).Id

#Get the amount of CPU time used by each (property)
(Get-Process -Name Notepad).CPU

#Access multiple properties by using the Select-Object command
Get-Process -Name Notepad | Select-Object -Property Name, Id, CPU

#Let's look at the methods of the process object
Get-Process -Name Notepad | Get-Member -MemberType Method

#Get each process to terminate (method)
(Get-Process -Name Notepad).Kill()

#Explore the object returned by the Get-Date cmdlet
Get-Date

#view all the members of the object returned
Get-Date | Get-Member

#Use a method to get a formatted date string
(Get-Date).ToShortDateString()

#Use an integer property in a calculation
(Get-Date).Year 

#Because the Year property is an integer, I can do integer things to it
(Get-Date).Year + 100

#Use the AddYears method to get a new date object and output that as a string
(get-date).AddYears(3).ToShortDateString()

#Date special mentions - Convert to UTC time
(Get-Date).ToUniversalTime()

Get-Date -AsUTC

#Date special mentions - Unix epoch time format
#Ephoch == number of seconds since 1/1/1970 (beginning of the Unix unvierse)
Get-Date -UFormat %s

################################

#Use the pipeline to pass OBJECTS from one command to another
#First, get a list of services on the system
Get-Service

#Get all of the members for the command
Get-Service | Get-Member

#use the pipeline to process the results
Get-Service | Select-Object Name, Status, StartType

Get-Service | Select-Object Name, Status, StartType | Sort-Object Status, StartType -Descending 

Get-Service | Select-Object Name, Status, StartType | Sort-Object Status, StartType -Descending | Format-List

Get-Service | Select-Object Name, Status, StartType | Sort-Object Status, StartType -Descending | Format-List | Out-File services.txt

Get-Content .\services.txt

#Determine the PowerShell version installed
$PSVersionTable
$PSVersionTable.PSVersion

#List available commands
Get-Command

#Count the number available
Get-Command | Measure-Object

#Aside - Measure-Object - the auditor's best friend!
1,2,3,4,5 | Measure-Object -Average
1,2,3,4,5 | Measure-Object -Average -Sum -Maximum -Minimum

#Limit the commands returned by get-command
Get-Command -Name Write*

#Equivalent to this command, because of "positional" parameters
Get-Command Write*

#PowerShell is not CaSe SensiTive
geT-ComMand wrIte-HoSt
