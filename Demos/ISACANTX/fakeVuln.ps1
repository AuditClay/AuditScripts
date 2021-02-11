#Fake one year's worth of information for patches happening on Saturday morning
$day1 = (Get-Date -hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(6-((Get-Date).DayOfWeek.value__) )
$day0 = $day1.AddDays(-364)
$numDays = (New-TimeSpan -Start $day0 -End (get-date)).Days + 3

#Control the data to be output
$patchPct = 0.33
$newVulnPct = 0.22
$numServers = 100
$minVuln = 60
$maxVuln = 200
$minFixed = 1
$maxFixed = 5
$maxNewVuln = 40

#Output filenames
$outputFile = "vulnDataInput.csv"

#Create the empty files
New-Item -Path . -Name $outputFile -ItemType "File" -Force

"ServerName,Criticality,Count,DateOffset" | 
            Out-File -FilePath $outputFile -Append -Encoding ascii

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

for( $i = 0-$numDays; $i -le 0; ++$i)
{
    write-host "Processing $d"
    #Increment to the next day in the series
    $d = $day1.AddDays($i)
    
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
        if( $d.DayOfWeek.value__ -eq 3)
        {
            $r = Get-Random -Minimum 0.0 -Maximum 1.0
            if( $r -lt $newVulnPct)
            {
                $newVulnCount = Get-Random -Minimum 0 -Maximum $maxNewVuln
                $totalVuln += $newVulnCount
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

        $v = $vulnNone[$s]
        "$serverName,none,$v,$i" | 
            Out-File -FilePath $outputFile -Append -Encoding ascii

        $v = $vulnLow[$s]
        "$serverName,low,$v,$i" | 
            Out-File -FilePath $outputFile -Append -Encoding ascii

        $v = $vulnMed[$s]
        "$serverName,med,$v,$i" | 
            Out-File -FilePath $outputFile -Append -Encoding ascii

        $v = $vulnHigh[$s]
        "$serverName,high,$v,$i" | 
            Out-File -FilePath $outputFile -Append -Encoding ascii

        $v = $vulnCrit[$s]
        "$serverName,crit,$v,$i" | 
            Out-File -FilePath $outputFile -Append -Encoding ascii
    
        $v = $totalVuln
        "$serverName,total,$v,$i" | 
            Out-File -FilePath $outputFile -Append -Encoding ascii
    
        }
}