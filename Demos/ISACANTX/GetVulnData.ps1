Get-Content .\vulnDataInput.csv |
  ConvertFrom-Csv |
  Select-Object ServerName, 
    @{n='DateRun';E={(Get-Date).AddDays($_.DateOffset).ToShortDateString()}},
    None,Low,Medium,High,Critical,Total |
  Export-Csv -Force -NoTypeInformation -Path vulnData.csv

