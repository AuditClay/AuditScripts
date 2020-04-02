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

#Number of days after which a user is considered "inactive" - used when analyzing last logon date and date of last password change.
$InactiveDays = 120

#Domain Demographics
$NetBIOSName = (Get-ADDomain | Select-Object NetBIOSName).NetBIOSName

$DNSRoot = (Get-ADDomain | Select-Object DNSRoot).DNSRoot
$Forest = (Get-ADDomain | Select-Object Forest).Forest
$ADFunctionalLevel = (Get-ADDomain | Select-Object DomainMode).DomainMode.ToString()

#AD User Information: Counts of enabled and disabled user accounts
$EnabledUsers = (Get-ADUser -Filter 'enabled -eq $true' | Measure-Object).Count

$DisabledUsersList = (Get-ADUser -Filter 'enabled -eq $false')
$DisabledUsers = ($DisabledUsersList | Measure-Object).Count

$TotalUsers = (Get-ADUser -filter * | Measure-Object).Count

#Users created more than 120 days ago with no password change in 120 days
$StalePasswordUsersList = (Get-ADUser -Filter 'enabled -eq $true' -Properties SAMAccountName,PasswordLastSet,WhenCreated | 
        Where-Object { ($_.WhenCreated -lt (Get-Date).AddDays( -$InactiveDays )) -and `
        ($_.passwordLastSet -lt (Get-Date).AddDays( -$InactiveDays )) } )
$StalePasswordUsers = ($StalePasswordUsersList | Measure-Object).Count

#Users who haven't authenticated in 120 days
$InactiveUsersList = (Get-ADUser -Filter 'enabled -eq $true' -Properties SAMAccountName,LastLogonDate,WhenCreated,PasswordLastSet |
        Where-Object { ($_.LastLogonDate -lt (Get-Date).AddDays( -$InactiveDays )) } )

$InactiveUsers = ($InactiveUsersList | Measure-Object).Count

#Users who have authenticated or changed their password within the last 120 days
$ActiveUsers = (Get-ADUser -Filter 'enabled -eq $true' -Properties SAMAccountName,LastLogonDate,WhenCreated,PasswordLastSet |
        Where-Object { ($_.LastLogonDate -gt (Get-Date).AddDays( -$InactiveDays )) `
        -or ($_.passwordLastSet -gt (Get-Date).AddDays( -$InactiveDays )) } | Measure-Object).Count

#Members of sensitive groups
$DomainAdminsList = (Get-ADGroupMember -Recursive -Identity "Domain Admins" )
$DomainAdmins = ($DomainAdminsList | Measure-Object).Count

$SchemaAdminsList = (Get-ADGroupMember -Recursive -Identity "Schema Admins" )
$SchemaAdmins = ($SchemaAdminsList | Measure-Object).Count

$EnterpriseAdminsList = (Get-ADGroupMember -Recursive -Identity "Enterprise Admins" )
$EnterpriseAdmins = ($EnterpriseAdminsList | Measure-Object).Count

#Enabled users with password which never expires
$PasswordNeverExpiresList = (Get-ADUser -filter {PasswordNeverExpires -eq $true -and Enabled -eq $true} )
$PasswordNeverExpires = ($PasswordNeverExpiresList| Measure-Object).Count

#Enabled users with password which was never set
$PasswordNeverSetList = (Get-ADUser -Filter 'enabled -eq $true' -Properties PasswordLastSet, Created |
        Where-Object { ($_.PasswordLastSet -eq $null) -and ($_.Created -lt (Get-Date).AddDays( -14 ))} )
$PasswordNeverSet = ($PasswordNeverSetList | Measure-Object).Count


#Enabled users with no password required
$PasswordNotRequiredList = (Get-ADUser -Filter 'enabled -eq $true -and PasswordNotRequired -eq $true' )
$PasswordNotRequired = ( $PasswordNotRequiredList | Measure-Object).Count


$adAuditResults = [PSCustomObject]@{
    NetBIOSName = $NetBIOSName
    DNSRoot = $DNSRoot
    Forest = $Forest
    ADFunctionalLevel = $ADFunctionalLevel
    EnabledUsers = $EnabledUsers
    DisabledUsers = $DisabledUsers
    TotalUsers = $TotalUsers
    StalePasswordUsers = $StalePasswordUsers
    InactiveUsers = $InactiveUsers
    ActiveUsers = $ActiveUsers
    DomainAdmins = $DomainAdmins     
    SchemaAdmins = $SchemaAdmins
    EnterpriseAdmins = $EnterpriseAdmins 
    PasswordNeverExpires = $PasswordNeverExpires
    PasswordNeverSet = $PasswordNeverSet     
    PasswordNotRequired = $PasswordNotRequired
}

#Output the object to the pipeline. The user might want to pipe these results through something like
#ConvertTo-CSV or ConvertTo-JSON
$adAuditResults

#For each of the measured objects, if it has >0 members, output it to a CSV in the original script directory
if($DisabledUsers -gt 0)
{
  $DisabledUsersList | ConvertTo-Csv | Out-File "$PSScriptRoot\DisabledUsers.csv"
}
if( $StalePasswordUsers -gt 0 )
{
  $StalePasswordUsersList | ConvertTo-Csv | Out-File "$PSScriptRoot\StalePasswordUsers.csv"
}
if( $InactiveUsers -gt 0 )
{
  $InactiveUsersList | ConvertTo-Csv | Out-File "$PSScriptRoot\InactiveUsers.csv"
}
if( $DomainAdmins -gt 0 )
{
  $DomainAdminsList | ConvertTo-Csv | Out-File "$PSScriptRoot\DomainAdmins.csv"
}
if( $SchemaAdmins -gt 0 )
{
  $SchemaAdminsList | ConvertTo-Csv | Out-File "$PSScriptRoot\SchemaAdmins.csv"
}
if( $EnterpriseAdmins -gt 0 )
{
  $EnterpriseAdminsList | ConvertTo-Csv | Out-File "$PSScriptRoot\EnterpriseAdmins.csv"
}
if( $PasswordNeverExpires -gt 0 )
{
  $PasswordNeverExpiresList | ConvertTo-Csv | Out-File "$PSScriptRoot\NonExpiringPwdUsers.csv"
}
if( $PasswordNeverSet -gt 0 )
{
  $PasswordNeverSetList | ConvertTo-Csv | Out-File "$PSScriptRoot\PwdNotSetUsers.csv"
}

#If the alternate connection was used, then get back to the original location and remove the PS drive
#before exiting
if( $Server -and $Credential )
{
  Pop-Location
  Remove-PSDrive -name "ADAudit"
}
