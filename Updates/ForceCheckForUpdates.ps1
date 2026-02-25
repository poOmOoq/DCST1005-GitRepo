$Computers = @('cl1', 'dc1', 'srv1')

foreach ($Computer in $Computers) {
    Write-Host "`nTvinger update scan på $Computer.infrait.sec..." -ForegroundColor Yellow
    
    Invoke-Command -ComputerName "$Computer.infrait.sec" -ScriptBlock {
        # Tving Windows Update scan via UsoClient (native tool)
        Write-Host "Starter update scan..." -ForegroundColor Cyan
        UsoClient StartScan
        
        # Vent litt for at scan skal starte
        Start-Sleep -Seconds 3
        
        Write-Host "Update scan startet. Sjekk status om 1-2 minutter med Get-WindowsUpdateStatus.ps1" -ForegroundColor Green
    }
}