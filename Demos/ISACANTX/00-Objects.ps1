"Demo for ISACANTX Nov 13, 2020"
#Everything is passed as objects on the command line,
#even a simple list of integers.
#List the numbers 1-4 and, treating each as integer, multiply it by 50
# $_ is a default variable which represents the object currently in view
1,2,3,4 | ForEach-Object {$_ * 50}

#Convert each integer to a string, and then add another string to it
1,2,3,4 | ForEach-Object {$_.tostring() + " Hello"}

#PowerShell will try to determine what kind of object you need
#and do an implicit conversion
1,2,3,4 | ForEach-Object {"$_" + " Hello"}

#Also, there's an easier way to do a list
1..20 | ForEach-Object {$_.tostring() + " Hello"}

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

#Date special mentions - Unix epoch time format
#Ephoch == number of seconds since 1/1/1970 (beginning of the Unix unvierse)
Get-Date -UFormat %s

#Use the pipeline to pass objects from one command to another
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

