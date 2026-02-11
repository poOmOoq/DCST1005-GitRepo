while ($true) {
    . .\Monitoring\Performance\PerformanceMetrics.ps1

    Clear-Host
    Write-Host "=== Server Health Dashboard ===" -ForegroundColor Cyan
    Write-Host "Sist oppdatert: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host ""

    foreach ($server in $results) {
        $server = [PSCustomObject]$server
        Write-Host "`n=== $($server.ComputerName) ===" -ForegroundColor Cyan
    
        $cpuColor = if ($server.CPU -gt 80) { "Red" } elseif ($server.CPU -gt 60) { "Yellow" } else { "Green" }
        Write-Host "  CPU: $($server.CPU)%" -ForegroundColor $cpuColor
        
        $memColor = if ($server.MemPercent -gt 90) { "Red" } elseif ($server.MemPercent -gt 75) { "Yellow" } else { "Green" }
        Write-Host "  Memory Used: $($server.MemPercent)%" -ForegroundColor $memColor
        
        $storColor = ""

        if ($server.StorMB -lt 300 || $server.StorPercent -lt 10) { $storColor = "Red" }
        elseif ($server.StorPercent -lt 25) { $storColor = "Yellow" }
        else { $storColor = "Green" }
        
        Write-Host "  Storage free: $($server.StorMB) MB ($($server.StorPercent)%)" -ForegroundColor $storColor

        $networkUsage = $server.NetUsage
        $networkEnd = ""
        $networkColor = "Green"

        $allEnds = @("K", "M", "G")
        $netColors = @("White", "Yellow", "Red")
        for ($i = 0; $i -lt $allEnds.Count; $i++) {
            if ($networkUsage -gt 1000) {
                $networkUsage /= 1000
                $networkEnd = $allEnds.Get($i)
                $networkColor = $netColors.Get($i)

            }
        }

        Write-Host "  Network Usage: $([math]::Round($networkUsage, 2)) $($networkEnd)B" -ForegroundColor $networkColor
    }
    
    Start-Sleep -Seconds 5
}
