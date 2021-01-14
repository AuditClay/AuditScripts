#Fake one year's worth of information for patches happening on Saturday morning
$day1 = (Get-Date -hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(6-((Get-Date).DayOfWeek.value__) )
$day0 = $day1.AddDays(-91)
$numDays = (New-TimeSpan -Start $day0 -End (get-date)).Days + 3

#Control the data to be output
$patchPct = 0.44
$newVulnPct = 0.22
$numServers = 50
$minVuln = 60
$maxVuln = 200
$minFixed = 1
$maxFixed = 10
$maxNewVuln = 60
$minNewVuln = 10

#Output filenames
$csvFile = "vulnDataInput.csv"

#Create the empty files
New-Item -Path . -Name $csvFile -ItemType "File" -Force
"`"ServerName`",`"DateOffset`",`"Risk`",`"Count`"" |  Out-File -FilePath $csvFile -Encoding ascii
Get-Content $csvFile

#set initial "patch age" for all servers to 0 - as if they were newly deployed
$vulnNone = New-Object int[] $numServers
$vulnLow = New-Object int[] $numServers
$vulnMed = New-Object int[] $numServers
$vulnHigh = New-Object int[] $numServers
$vulnCrit = New-Object int[] $numServers

#Seed the PRNG to ensure repeatable results
Get-Random -SetSeed 314159 | Out-Null

for( $s=0; $s -lt $numServers; ++$s )
{
    $totalVuln = Get-Random -Minimum $minVuln -Maximum $maxVuln
    $vulnNone[$s]= [int]($totalVuln * .50)
    $vulnLow[$s]= [int]($totalVuln * .15)
    $vulnMed[$s]= [int]($totalVuln * .20)
    $vulnHigh[$s]= [int]($totalVuln * .10)
    $vulnCrit[$s]= [int]($totalVuln * .05)
}

for( $i = -91; $i -lt 0; ++$i)
{
    write-host "Processing $i"
    for( $s=0; $s -lt $numServers; ++$s )
    {
        $serverName = "Server$s"
        $totalVuln = $vulnNone[$s] + $vulnLow[$s] + $vulnMed[$s] + $vulnHigh[$s] + $vulnCrit[$s]

        #Some vulns get fixed every day
        $r = Get-Random -Minimum 0.0 -Maximum 1.0 
        if( $r -lt $patchPct)
        {
            $fixedVuln = Get-Random -Minimum $minFixed  -Maximum $maxFixed
            $totalVuln -= $fixedVuln

        }

        #New vulns get found occasionally
        if( ($i % 7) -eq -1)
        {
            $r = Get-Random -Minimum 0.0 -Maximum 1.0
            if( $r -lt $newVulnPct)
            {
                $newVulnCount = Get-Random -Minimum $minNewVuln -Maximum $maxNewVuln
                $totalVuln += $newVulnCount
                "Adding $newVulnCount to $s"
            }
        }

        #Calculate new vuln total for this server
        if( $totalVuln -le 0 )
        {
            $totalVuln = 0
        }
        $vulnNone[$s]= [int]($totalVuln * .60)
        $vulnLow[$s]= [int]($totalVuln * .05)
        $vulnMed[$s]= [int]($totalVuln * .20)
        $vulnHigh[$s]= [int]($totalVuln * .10)
        $vulnCrit[$s]= [int]($totalVuln * .05)

        $vnone=$vulnNone[$s]
        "`"$serverName`",$i,`"none`",$vnone" |
          Out-File -FilePath $csvFile -Encoding ascii -Append

        $vlow = $vulnLow[$s]
        "`"$serverName`",$i,`"low`",$vlow" |
          Out-File -FilePath $csvFile -Encoding ascii -Append

        $vmed = $vulnMed[$s]
        "`"$serverName`",$i,`"medium`",$vmed" |
          Out-File -FilePath $csvFile -Encoding ascii -Append

        $vhigh = $vulnHigh[$s]
        "`"$serverName`",$i,`"high`",$vhigh" |
          Out-File -FilePath $csvFile -Encoding ascii -Append

        $vcrit = $vulnCrit[$s]
        "`"$serverName`",$i,`"critical`",$vcrit" |
          Out-File -FilePath $csvFile -Encoding ascii -Append

          $vcrit = $vulnCrit[$s]
          "`"$serverName`",$i,`"total`",$totalVuln" |
            Out-File -FilePath $csvFile -Encoding ascii -Append
        }
}