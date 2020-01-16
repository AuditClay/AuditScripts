#Parameters for non-domain test machines
#If the machine running the script is not-joined, specifying these parameters
#will allow the script to authenticate to an LDAP server to run its queries.
#No special administrative privileges are required for the credentials used to connect.
param( $Server, $Credential)

#For obvious reasons, the ActiveDirectory module is required by this script
if ( -not (Get-Module -ListAvailable -Name ActiveDirectory))
{
    Write-Host "Active Directory module not found. Exiting."
    return
}
Import-Module ActiveDirectory


#Only use the alternative connection parameters if they were supplied
if( $Server -and $Credential )
{
  $ServerPort = $Server.ToString() + ":389"
  New-PSDrive -name "ADAudit" -PSProvider ActiveDirectory -Root "" -Server $ServerPort -Credential $Credential | Out-Null
  Push-Location ADAudit: | Out-Null
}

$computerList = (Get-ADComputer -filter *).dnsHostName
#If the alternate connection was used, then get back to the original location and remove the PS drive
#before exiting
if( $Server -and $Credential )
{
  Pop-Location
  Remove-PSDrive -name "ADAudit"
}

$filename = ".\SvcAccounts.csv"
if( test-path -Path $filename )
{
    Remove-Item $filename
}
foreach( $hostname in $computerList)
{
    Get-WmiObject win32_service -ComputerName $hostname -Credential $Credential -Property SystemName, Name, StartName | 
        Select-Object SystemName, Name, StartName | ConvertTo-Csv | 
        Tee-Object -Append -FilePath $filename
}



