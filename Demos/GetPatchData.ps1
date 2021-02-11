Get-Content .\patchInput.csv |
  ConvertFrom-Csv |
  Select-Object Source, ` 
    @{N='InstalledOn';E={(Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays($_.DateOffset)}}, `
    Description, InstalledBy |Where-Object InstalledOn -lt (Get-Date) |
  Export-Csv -Force -NoTypeInformation -Path patches.csv

  Get-Content .\patchAgeInput.csv |
  ConvertFrom-Csv |
  Select-Object ServerName, ` 
    @{N='Date';E={(Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays($_.DateOffset)}}, `
    PatchAge |Where-Object Date -lt (Get-Date) |
  Export-Csv -Force -NoTypeInformation -Path patchAge.csv
  
 