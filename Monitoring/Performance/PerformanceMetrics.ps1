$scriptblock = { 
    $cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples
    $memPercent = (Get-Counter '\Memory\% Committed Bytes In Use').CounterSamples
    $storPercent = (Get-Counter '\LogicalDisk(*)\% Free Space').CounterSamples
    $storMB = (Get-Counter '\LogicalDisk(*)\Free Megabytes').CounterSamples
    $networkUsage = (Get-Counter '\Network Interface(*)\Bytes Total/sec').CounterSamples
    
    [Ordered]@{
        ComputerName = $env:COMPUTERNAME
        CPU          = [math]::Round($cpu.CookedValue, 2)
        MemPercent   = [math]::Round($memPercent.CookedValue, 2)
        StorPercent  = [math]::Round($storPercent.CookedValue.Get(0), 2)
        StorMB       = [math]::Round($storMB.CookedValue.Get(0), 2)
        NetUsage     = [math]::Round($networkUsage.CookedValue, 2)
    }
}

$results = Invoke-Command -ComputerName dc1, srv1 -ScriptBlock $scriptblock -ErrorAction SilentlyContinue -ThrottleLimit 32
