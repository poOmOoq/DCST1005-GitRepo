$scriptblock = { 
    $cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples
    $memPercent = (Get-Counter '\Memory\% Committed Bytes In Use').CounterSamples
    $storPercent = (Get-Counter '\LogicalDisk(*)\% Free Space').CounterSamples
    $storMB = (Get-Counter '\LogicalDisk(*)\Free Megabytes').CounterSamples
    $networkUsage = (Get-Counter '\Network Interface(*)\Bytes Total/sec').CounterSamples
    
    $networkUsage = [math]::Round($networkUsage.CookedValue, 2)
    
    $G = 1e9
    $M = 1e6
    $K = 1e3

    [PSCustomObject]@{
        Time                 = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Computer_Name        = $env:COMPUTERNAME
        CPU_Usage            = "$([math]::Round($cpu.CookedValue, 2)) %"
        Memory_Usage         = "$([math]::Round($memPercent.CookedValue, 2)) %"
        Storage_Percent_Free = "$([math]::Round($storPercent.CookedValue.Get(0), 2)) %"
        Storage_MB_Free      = "$([math]::Round($storMB.CookedValue.Get(0), 2)) MB"
        Net_Usage            = if ($networkUsage -gt $G) { "$([math]::Round($networkUsage / $G)) GB" } elseif ($networkUsage -gt $M) { "$([math]::Round($networkUsage / $M)) MB" } elseif ($networkUsage -gt $K) { "$([math]::Round($networkUsage / $K)) KB" } else { "$($networkUsage) B" }
    }
}

$results = Invoke-Command -ComputerName dc1, srv1 -ScriptBlock $scriptblock -ErrorAction SilentlyContinue -ThrottleLimit 32

$pathToCSV = ".\Monitoring\Performance\performance.csv"

$results |
Select-Object Time, Computer_Name, CPU_Usage, Memory_Usage, Storage_Percent_Free, Storage_MB_Free, Net_Usage |
Export-Csv $pathToCSV -NoTypeInformation -Append
