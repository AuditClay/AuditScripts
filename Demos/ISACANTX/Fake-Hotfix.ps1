$day1 = (Get-Date -hour 0 -Minute 0 -Second 0).AddDays(6-((Get-Date).DayOfWeek.value__) )
$day0 = $day1.AddDays(-364)
$patchPct = 0.75
$numServers = 100
$maxPatch = 5

for( $w=0; $w -lt 52; $w++)
{
    $d = $day0.AddDays(7*$w)

    for( $i = 1; $i -lt $numServers; ++$i )
    {
        $serverName = "Server" + $i
        if( (Get-Random -Minimum 0.0 -Maximum 1.0) -le $patchPct)
        {
            if( ($i % 13 -eq 0) -and ($w % 13 -ne 0) )
            {
                continue
            }
            $r = Get-Random -Minimum 1 -Maximum $maxPatch
            for( $p = 0; $p -lt $r; $p++ )
            {     
                $kb = Get-Random -Minimum 1000000 -Maximum 9999999
                $patchResult = [PSCustomObject]@{
                    Source = $serverName
                    InstalledOn = $d
                    HotFixID = "MSKB" + $kb
                    Description = "Security Update", "Update" | Get-Random
                    InstalledBy = "NT AUTHORITY\SYSTEM"
                }
                $patchResult
            }
        }
    }

}

#Source, Description, HotFixID, InstalledBy, InstalledOn