"Demo for ISACANTX Nov 13, 2020"
############################################################################
#NOTE TO CLAY: Run this from your laptop, not the VM, because it uses Excel#
############################################################################
#How many vulnerabilities exist in the environment?
#How many servers are we analyzing?

#NOTE: This demo uses the Import-Excel module by Doug Finke
#To install it, you can run "Install-Module Import-Excel" from an elevated PowerShell prompt
cd .\Nessus\

#What files were we given?
Get-ChildItem

#Take a look at the content of the result files
#Notice the multi-line cells which can cause a little trouble
more .\Results_set_1.csv

#Trying to use convertFrom-Csv will give a number of broken objects
#It turns out the file has some embedded CR characters which break some field names
Get-Content .\Results_set_1.csv | ConvertFrom-Csv | Select-Object -First 3

#Fortunately, import-csv handles these multi-line field correctly(ish)
import-csv .\Results_set_1.csv | Select-Object -First 10

#Let's take a look a the fields returned
#Host and Risk should be helpful for a quick look at how bad the problem is
import-csv .\Results_set_1.csv | Select-Object -First 1 | Get-Member | Format-List *

#How many results are there in one of the files?
import-csv .\Results_set_1.csv | Measure-Object

#Many of the results are informational, and have a risk of 'None'
import-csv .\Results_set_1.csv | Where-Object risk -eq 'none' | Measure-Object

#Take a look at the csv files we were given - there seem to be about 80 of them
Get-ChildItem *.csv

#Cool trick to get the full path of all of the CSV files to pass into import-csv to process all at once
Get-ChildItem *.csv | Select-Object -ExpandProperty FullName

#Take a quick look to see if the import is working
import-csv -path (Get-ChildItem *.csv | Select-Object -ExpandProperty FullName) | Select-Object -First 5

#How many total results are there in all the files combined?
import-csv -path (Get-ChildItem *.csv | Select-Object -ExpandProperty FullName) | Measure-Object

#It takes a while to do the import, so let's run it once and save into a variable for faster processing
$d = import-csv -path (Get-ChildItem *.csv | Select-Object -ExpandProperty FullName)

#Make sure the count of results is still coherent
$d | Measure-Object

#Which unique hosts are we dealing with?
$d.Host | Sort-Object -Unique

#How many hosts is that?
$d.Host | Sort-Object -Unique | Measure-Object

#What sort of risks are there in the results?
$d.risk | Select-Object -First 20

#How prevalent is each category of risk in these files?
$d | Group-Object Risk

#Let's see if we can determine what percentage of actual risks (ignoring 'none' findings) are scored as critical
#First, get the critical results into an object to make counting them easier
$d | Group-Object Risk | Where-Object Name -eq 'Critical'

#Then pull the count and save it into a variable
$crit = ($d | Group-Object Risk | Where-Object Name -eq 'Critical').Count

#Get a count of all risks not scored as none (this will be the denominator for the percentage)
$total = ($d |  Where-Object Risk -ne 'None').Count

#Take a look at the numbers
"Critical Count:`t " + $crit + "`nTotal Count:`t " + $total

#Check the percentage
$crit/$total

#Now, let's put the results into an excel file for tactical use by server admins trying to remediate
#Define the filename and make sure there's not an old one lying around
$excelFileName = ".\Vulns.xlsx"
if( Test-Path $excelFileName ) { Remove-Item $excelFileName }

#Build the spreadsheet, using the properties from the scan that will be helpful for the admins
# "See Also" contains a list of URLs which might be helpful to the adminis doing the work,
# create a new field called "SeeAlso" with those links on a single line (change the embedded newlines to spaces)
$d | Where-Object Risk -ne 'None' | Select-Object Name,Host,Risk,@{N='SeeAlso';E={$_.'See Also' -replace "\n", " "}},Solution | Export-Excel -path $excelFilename -AutoFilter 

#Open the spreadsheet
Invoke-Item $excelFileName

#We could use conditional formatting in Excel to highlight the Critical vulnerabilities
if( Test-Path $excelFileName ) { Remove-Item $excelFileName }

#Color the critical vulns with a red background and black text
$critFormat = New-ConditionalText "Critical" -Range "C:C" -ForeGroundColor Black -BackgroundColor Red
$d | Where-Object Risk -ne 'None' | Select-Object Name,Host,Risk,@{N='SeeAlso';E={$_.'See Also' -replace "\n", " "}},Solution | Export-Excel -path $excelFilename -AutoFilter -ConditionalFormat $critFormat

#Open the spreadsheet
Invoke-Item $excelFileName

if( Test-Path $excelFileName ) { Remove-Item $excelFileName }

#Let's also color the High vulns as orange, and the medium as yellow
$highFormat = New-ConditionalText "High" -Range "C:C" -ForeGroundColor Black -BackgroundColor orange
$medFormat = New-ConditionalText "Medium" -Range "C:C" -ForeGroundColor Black -BackgroundColor yellow

$d | Where-Object Risk -ne 'None' | 
  Select-Object Name,Host,Risk,@{N='SeeAlso';E={$_.'See Also' -replace "\n", " "}},Solution | 
  Export-Excel -path $excelFilename -WorksheetName "VulnScan" -AutoFilter -ConditionalFormat $critFormat, $highFormat, $medFormat

#Open the spreadsheet
Invoke-Item $excelFileName

if( Test-Path $excelFileName ) { Remove-Item $excelFileName }
#Build the spreadsheet, adding a pivot table for findings by host
$d | Where-Object Risk -ne 'None' | 
  Select-Object Name,Host,Risk,@{N='SeeAlso';E={$_.'See Also' -replace "\n", " "}},Solution | 
  Export-Excel -path $excelFilename -AutoFilter -includePivotTable -PivotRows Host,Name,Solution,SeeAlso -PivotFilter Risk


$critFormat = New-ConditionalText "Critical" -Range "C:C" -ForeGroundColor Black -BackgroundColor Red
$highFormat = New-ConditionalText "High" -Range "C:C" -ForeGroundColor Black -BackgroundColor orange
$medFormat = New-ConditionalText "Medium" -Range "C:C" -ForeGroundColor Black -BackgroundColor yellow

if( Test-Path $excelFileName ) { Remove-Item $excelFileName }

$xl = $d | Where-Object Risk -ne 'None' | 
  Select-Object Name,Host,Risk,@{N='SeeAlso';E={$_.'See Also' -replace "\n", " "}},Solution | 
  Export-Excel -path $excelFilename -WorksheetName "VulnScan" -AutoFilter -PassThru -ConditionalFormat $critFormat, $highFormat, $medFormat

$pt1 = New-PivotTableDefinition -PivotTableName "ByHost" -PivotRows Host,Name,Solution,SeeAlso -PivotFilter Risk
$pt2 = New-PivotTableDefinition -PivotTableName "ByVuln" -PivotRows Name,Host,Solution,SeeAlso -PivotFilter Risk

$xl = Export-Excel -ExcelPackage $xl -WorksheetName "VulnScan" -PivotTableDefinition $pt1 -PassThru
Export-Excel -ExcelPackage $xl -WorksheetName "VulnScan" -PivotTableDefinition $pt2 -Show




#Open the spreadsheet
Invoke-Item $excelFileName

Set-Location .. 
