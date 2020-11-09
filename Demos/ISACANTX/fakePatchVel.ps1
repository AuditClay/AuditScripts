#Fake one year's worth of information for patches happening on Saturday morning
$day1 = (Get-Date -hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(6-((Get-Date).DayOfWeek.value__) )
$day0 = $day1.AddDays(-364)
$numDays = (New-TimeSpan -Start $day0 -End (get-date)).Days

#Control the data to be output
$patchPct = 0.33
$numServers = 10
$maxPatch = 8

#Output filenames
$patchFile = "patches.csv"
$graphiteFile = "patchData.txt"

#Create the empty files
New-Item -Path . -Name $patchFile -ItemType "File" -Force -Value "`"Source`",`"InstalledOn`",`"HotFixID`",`"Description`",`"InstalledBy`"`n"
New-Item -Path . -Name $graphiteFile -ItemType "File" -Force

$primes = @(2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 
59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 
139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 
229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 
331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 
439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 
563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 
661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 
797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 
919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997)

#set initial "patch age" for all servers to 0 - as if they were newly deployed
$patchAge = New-Object int[] $numServers
for( $s=0; $s -lt $numServers; ++$s )
{
    $patchAge[$s]=0
}
#Seed the PRNG to ensure repeatable results
Get-Random -SetSeed 314159

for( $i = 0; $i -lt $numDays; ++$i)
{
    write-host "Processing $d"
    #Increment to the next day in the series
    $d = $day0.AddDays($i)
    #Use the Unix epoch time format for Graphite
    $unixTime = get-date -Date $d -UFormat %s 

    #This organization patches on Friday night/Saturday morning
    if( $d.DayOfWeek.value__ -eq 6 )
    {
        for( $s=0; $s -lt $numServers; ++$s )
        {
            $serverName = "Server$s"
            #Decide whether this one got patches during this cycle
            if( (Get-Random  -Minimum 0.0 -Maximum 1.0) -le $patchPct)
            {
                #Set up a few servers which only get patched every 12 weeks
                if( ($s -in $primes) -and ($i % 84 -gt 7) )
                {
                    continue
                }
                else 
                {
                    #Write the day's patch count to the velocity file for Graphite
                    $numPatches = Get-Random  -Minimum 1 -Maximum $maxPatch
                    "patchvelocity.$serverName $numPatches $unixTime" | 
                        Out-File -FilePath $graphiteFile -Append -Encoding ascii
                    $patchAge[$s] = -1

                    #Write the patches installed out to the CSV for patches
                    $r = Get-Random  -Minimum 1 -Maximum $maxPatch
                    for( $p = 0; $p -lt $r; $p++ )
                    {     
                        $kb = Get-Random  -Minimum 1000000 -Maximum 9999999
                        $patchResult = [PSCustomObject]@{
                            Source = $serverName
                            InstalledOn = $d
                            HotFixID = "MSKB" + $kb
                            Description = "Security Update", "Update" | Get-Random
                            InstalledBy = "NT AUTHORITY\SYSTEM"
                        }
                        $patchResult | ConvertTo-Csv -NoTypeInformation | select-object -skip 1 | 
                            Out-File -Append -FilePath $patchFile -Encoding ascii
                    }

                }
            }
        }
    }
    for( $s=0; $s -lt $numServers; ++$s )
    {
        $serverName = "Server$s"
        ++$patchAge[$s]
        $p = $patchAge[$s]
        "patchage.$serverName $p $unixTime" | 
            Out-File -FilePath $graphiteFile -Append -Encoding ascii
    }
}