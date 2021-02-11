#Script/function parameters
param ( 
  [int] $MaxHosts=10, 
  [string] $HostName, 
  $ServiceCount 
)

#Functions
Function Get-PID {
  param( $ProcessName = "PowerShell")
  (Get-Process -Name $ProcessName).Id
}

#standard FOR loop - similar to other languages
for($x=20;$x -lt 30;$x++) {
  Invoke-Expression "ping -n 1 127.0.1.$x"
}

#For-each loop allows looping through items in a collection
#Foreach is a language contruct (loop type) and also an alias for ForEach-Object
#Here it is as a loop...BTW the Write-Host is usually optional, too...
Foreach( $svc in (Get-Service) ) {
  Write-Host ($svc.Name).ToUpper()
}

#Here it is as an alias for ForEach-Object
Get-Service | Foreach { $_.Name.ToUpper() }

#Equivalent of this
Get-Service | Foreach-Object { $_.Name.ToUpper() }

#While-Object loops as long as a condition is true
$i=0
While( $i -lt 10){ 
  Write-Host $i
  $i++
  break;
}

#Do-While loops as long as a condition is true
$i=0
Do { $i++; $i } while ($i -lt 5) 

#Do-Until loops until a condition is true
$i=0
Do { $i++; $i } until ($i -ge 5) 

#Break causes a loop to exit immediately
#Print only the first number
1..10| ForEach-Object {
  $_
  break
}

#Continue returns to the top of the loop immediately
#Print only the first number
1..10| ForEach-Object {
  if ($_ -gt 1) {continue}
  $_
}

#If statements allow for conditional execution of commands
ForEach( $svc in (Get-Service) ) {
  if( $svc.Status -eq 'Running') {
    Write-Host -BackgroundColor white -ForegroundColor DarkGreen ($svc.Name).ToUpper()
  }
  else {
    Write-Host -BackgroundColor white -ForegroundColor Red ($svc.Name).ToLower()
  }
}

# If block runs code only if a condition is true
# Optional else block will be run if condition is not true
# Condition can be anything that evaluates to $true or $false 
#(built-in PowerShell variables for true and false values)

if( [Math]::PI -is [int]){
  Write-Host "Pi is an integer"
} else {
  Write-Host "Pi is not an integer"
}

if(-not $true){
  Write-Host "This always runs"
}else {
  Write-Host "This never runs"
}

$status = (Get-Service -Name BITS).Status
switch( $status ){
  "Stopped" { "BITS is stopped" }
  "Running" { "BITS is running" }
  "Stopped" { "Seriously, it's stopped..."}
  Default { "None of the above"}
}

clear-host