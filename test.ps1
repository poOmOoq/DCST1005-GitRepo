. .\Monitoring\Performance\PerformanceMetrics.ps1
foreach ($server in $results) {
    foreach ($key in $server.Keys) {
        if ($key -eq "ComputerName") { continue }
        Write-Host $key
    }
}