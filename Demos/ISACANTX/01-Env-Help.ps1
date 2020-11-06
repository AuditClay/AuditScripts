"Demo for ISACANTX Nov 13, 2020"
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

#List only cmdlets
Get-Command -CommandType Cmdlet
Get-Command -CommandType Cmdlet | Measure-Object
Get-Command -CommandType Cmdlet -Name *Job

#List only functions
Get-Command -CommandType Function
Get-Command -CommandType Function -Module Storage*

#Aliases

#ls to list files in directory
ls
#or dir
dir
#or Get-ChildITem
Get-ChildItem
#or gci
gci


Get-Command -CommandType Alias
Get-Alias
Get-Alias gsv

#Applications - PowersShell uses applications from your PATH
#Find the PATH environment variable
$env:Path

# Env: is a PSDrive representing your environment variables
Get-ChildItem Env:

Get-Command -CommandType Application 
Get-Command -CommandType Application | Measure-Object

#Use the positional paramter for Name
Get-Command -CommandType Application task*

#Cmdlets always use a Verb-Noun name format
Get-Verb
Get-Command -Noun "Service"

#Aside - PowerShell quotation marks
# Quotation marks are generally optional, unless using a string containing a space
# Convention is to use single quotes (') for most strings. Double Quotes (") are used for
# including a variable value in a string or for including a single quote in a string

Write-Host 'Hello'

#Put the PS version in a variable so we can see how quotation marks work with variables
$v = $PSVersionTable.PSVersion

#Single quotes treats strings as literals
Write-Host 'Your PowerShell version is $v'

#Double quotes will expand the contents of a variable
Write-Host "Your PowerShell version is $v"

#Double quotes can contain a string with a single quote in it
Write-Host "Hello Mr. O'Brien"

#Next line won't work - Can't enclose a single quote in a single quoted string
#Write-host 'Hello Mr. O'Brien'
#Instead, use a double single-quote to let PowerShell know you need a single quote included
Write-host 'Hello Mr. O''Brien'

#Grave accent (`) - under the ~ key on US keyboards - used as "escape character"
#print a tab character
write-host "Col 1`t`tCol 2"

#print an escaped newline character
write-host "line 1`nline 2"

#Getting Help
Get-Help Get-Service

#Man and the help function run get-help | more
#The more function does not work in the ISE, but it does in the console
Get-Alias Man
Get-Command help
man Get-Service

#Using the -online flag
Get-Help Get-Service -Online
Get-Help Get-ADComputer -Examples
Get-Help Get-ADComputer -Full
Get-Help Get-ADUser -Parameter F*
Get-Help Get-ADUser -ShowWindow

#update your help files to the most current version
#Run these in another shell, since they take a long time...
# Update-Help
# Remove-Item -Path ".\HelpFiles" -Recurse
# New-Item -Name HelpFiles -ItemType Directory -Path "."
# Save-Help -DestinationPath ".\HelpFiles" 
# Update-Help -SourcePath ".\HelpFiles"

#Get a GUI window to build a command
Show-Command Get-Acl

"The End"