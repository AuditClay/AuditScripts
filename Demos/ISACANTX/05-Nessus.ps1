cd .\Nessus\

#Take a look at the content of the result files
#Notice the multi-line cells which can cause a little trouble
more .\Results_set_1.csv

#Trying to use convertFrom-Csv will give a number of broken objects
Get-Content .\Results_set_1.csv | ConvertFrom-Csv | Select-Object -First 10

#Fortunately, import-csv handles these multi-line field correctly(ish)
import-csv .\Results_set_1.csv | Select-Object -First 10

#Let's take a look a the fields returned
import-csv .\Results_set_1.csv | Select-Object -First 1 | Get-Member | Format-List *

#Many of the results are informational, and have a risk of 'None'
import-csv .\Results_set_1.csv | Measure-Object
import-csv .\Results_set_1.csv | Where-Object risk -eq 'none' | Measure-Object

Get-ChildItem *.csv
Get-ChildItem *.csv | Select-Object -ExpandProperty FullName
import-csv -path (Get-ChildItem *.csv | Select-Object -ExpandProperty FullName)
import-csv -path (Get-ChildItem *.csv | Select-Object -ExpandProperty FullName) | Measure-Object

$d = import-csv -path (Get-ChildItem *.csv | Select-Object -ExpandProperty FullName)
$d | Measure-Object
$d.Host | Sort-Object -Unique
$d.Host | Sort-Object -Unique | Measure-Object
$d.risk | Select-Object -First 20
$d | Group-Object Risk

$d | Group-Object Risk | Where-Object Name -eq 'Critical'
$crit = ($d | Group-Object Risk | Where-Object Name -eq 'Critical').Count
$total = ($d |  Where-Object Risk -ne 'None').Count
"Critical Count:`t " + $crit
"Total Count:`t " + $total
$crit/$total

$excelFileName = ".\Vulns.xlsx"
if( Test-Path $excelFileName ) { Remove-Item $excelFileName }
$d | Where-Object Risk -ne 'None' |
  Select-Object Name,Host,Risk,@{N='SeeAlso';E={$_.'See Also' -replace "\n", " "}},Solution |
  Export-Excel -path $excelFilename -AutoFilter `
    -includePivotTable -PivotRows Host,Name,Solution,SeeAlso -PivotFilter Risk