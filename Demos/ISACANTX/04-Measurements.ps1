"Demo for ISACANTX Nov 13, 2020"

# Get a list of all the PSDrives on the system
Get-PSDrive

#On Windows PowerShell, this will include registry hives, the certificate store,
#PowerShell aliases and functions, the "Temp" filesystem, maybe Active Directory,
#and even disk drives :)

#Get a list of all the PowerShell aliases defined
Get-ChildItem alias:

#Create a drive mapped to Active Directory. First, we'll need a set of
#credentials, because this PC is not domain-joined
$cred=Get-Credential

#Use the credentitals to connect to our lab DC
New-PSDrive -name "AD" -PSProvider ActiveDirectory -Root "" -Server "10.50.7.10" -Credential $cred

#See the new PSDrive
Get-PSDrive

#Set the AD drive as out location
Set-Location AD:

#What's in there?
Get-ChildItem

#While we're in this location, we can query AD as if we were a member of the domain
Get-ADUser -Filter * | Measure-Object

#Grab a count of domain admins
Get-ADGroupMember -Recursive -Identity "Domain Admins"

#Quick visualize to discuss during our daily status meeting
Get-ADGroupMember -Recursive -Identity "Domain Admins" | Out-GridView

#Get out of the AD drive
Set-Location c:

#Remove the PS Drive for AD
Remove-PSDrive -Name "AD"
Get-PSDrive

#Required security settings are often in the registry, which is
#also avaialble as a drive in PowerShell
#Get a set of values from the registry
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

#test a few individual values
(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa").LimitBlankPasswordUse
(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa").NoLMHash
(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa").RestrictAnonymous

#assign results to a variable for further testing
$res = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa")
$res.LimitBlankPasswordUse

#build the check into an audit script as pass/fail
if( $res.LimitBlankPasswordUse -eq 1 -and $res.NoLMHash -eq 1) { Write-Host "Pass"}

#certificates are also in a drive
#set the location to the trusted root CAs for this machine
Set-Location Cert:\LocalMachine\AuthRoot

#Get a list of the subject names and thumbprints of all the CAs
Get-ChildItem | Select-Object Subject, Thumbprint | Format-List

#Get out of the certificate drive
set-location c:

#There are a host of native commandlet and WMI objects for measuring other
#settings/attributes of Windows systems. A few examples follow:
#
#Get a list of all hotfixes installed on the system
Get-HotFix

#Get a feel for "patching velocity" - how often has this machine been patched
Get-HotFix | Group-Object InstalledOn 

#Can be run against a remote system
Get-HotFix -ComputerName 10.50.7.10 -Credential $cred 

#grab a list of all installed software on a system (might take a few seconds)
Get-CimInstance Win32_Product

#Get just the name, version and install date for each
Get-CimInstance Win32_Product | Format-List Name, Version, InstallDate 

#This only shows software installed with the MSI subsystem. This machine has Firefox, 
#but it was installed with a package manager and it won't show up
Get-CimInstance Win32_Product | Where-Object Name -like "*firefox*"  

#A better trick is to iterate the registry looking for uninstall keys left behind
#by installation packages. 
.\InstalledSoftware.ps1
