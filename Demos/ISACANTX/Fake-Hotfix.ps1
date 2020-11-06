$day1 = (Get-Date -hour 0 -Minute 0 -Second 0).AddDays(6-((Get-Date).DayOfWeek.value__) )
$day0 = $friday.AddDays(-364)
$patchPct = 0.1
$numServers = 1000
$maxPatch = 10

for( $w=0; $w -lt 52; $w++)
{
    $d = $day0.AddDays(7*$w)

    for( $i = 1; $i -lt $numServers; ++$i )
    {
        $serverName = "Server" + $i
        if( (Get-Random -Minimum 0.0 -Maximum 1.0) -le $patchPct)
        {
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