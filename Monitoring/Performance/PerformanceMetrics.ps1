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

    [Ordered]@{
        ComputerName   = $env:COMPUTERNAME
        CPU            = @([math]::Round($cpu.CookedValue, 2), "%")
        MemoryPercent  = @([math]::Round($memPercent.CookedValue, 2), "%")
        StoragePercent = @([math]::Round($storPercent.CookedValue.Get(0), 2), "%")
        StorageMB      = @([math]::Round($storMB.CookedValue.Get(0), 2), "MB")
        NetUsage       = if ($networkUsage -gt $G) { @([math]::Round($networkUsage / $G), "GB") } elseif ($networkUsage -gt $M) { @([math]::Round($networkUsage / $M), "MB") } elseif ($networkUsage -gt $K) { @([math]::Round($networkUsage / $K), "KB") } else { @($networkUsage, "B") }
    }
}

$results = Invoke-Command -ComputerName dc1, srv1 -ScriptBlock $scriptblock -ErrorAction SilentlyContinue -ThrottleLimit 32
