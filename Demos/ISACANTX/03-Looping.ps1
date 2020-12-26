
#standard FOR loop - similar to other languages
for($x=20;$x -lt 30;$x++) {
  Invoke-Expression "ping -n 1 127.0.1.$x"
}

#For-each loop allows looping through items in a collection
ForEach( $svc in (Get-Service) ) {
  Write-Host ($svc.Name).ToUpper()
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

clear-host