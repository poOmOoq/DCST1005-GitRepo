while ($true) {
    . .\Monitoring\Performance\PerformanceMetrics.ps1

    Clear-Host
    Write-Host "=== Server Health Dashboard ===" -ForegroundColor Cyan
    Write-Host "Sist oppdatert: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host ""

    foreach ($server in $results) {
        $server = [PSCustomObject]$server
        Write-Host "`n=== $($server.ComputerName) ===" -ForegroundColor Cyan

        $cpuPerformance = $server.CPU[0]
        $cpuColor = if ($cpuPerformance -gt 80) { "Red" } elseif ($cpuPerformance -gt 60) { "Yellow" } else { "Green" }
        Write-Host "  CPU: $($cpuPerformance, $server.CPU[1])" -ForegroundColor $cpuColor
        
        $memoryPercent = $server.MemoryPercent[0]
        $memColor = if ($memoryPercent -gt 90) { "Red" } elseif ($memoryPercent -gt 75) { "Yellow" } else { "Green" }
        Write-Host "  Memory Used: $($memoryPercent, $server.MemoryPercent[1])" -ForegroundColor $memColor

        $storageMB = $server.StorageMB[0]
        $storagePercent = $server.StoragePercent[0]
        $storColor = ""

        if ($storageMB -lt 300 || $storagePercent -lt 10) { $storColor = "Red" }
        elseif ($storagePercent -lt 25) { $storColor = "Yellow" }
        else { $storColor = "Green" }

        Write-Host "  Storage free: $($storageMB, $server.StorageMB[1]) ($($storagePercent, $server.StoragePercent[1]))" -ForegroundColor $storColor

        $networkEnd = $server.NetUsage[1]
        $networkColor = if ($networkEnd -ceq "GB") { "Red" } elseif ($networkEnd -ceq "MB") { "Yellow" } elseif ($networkEnd -ceq "KB") { "White" } else { "Green" }

        Write-Host "  Network Usage: $($server.NetUsage[0], $networkEnd)" -ForegroundColor $networkColor
    }

    Start-Sleep -Seconds 5
}
