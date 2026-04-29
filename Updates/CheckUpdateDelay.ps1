# Sjekk Quality Update deferral på cl1
Invoke-Command -ComputerName cl1.infrait.sec -ScriptBlock {
    $Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    
    if (Test-Path $Path) {
        Get-ItemProperty -Path $Path | Select-Object `
            DeferQualityUpdates,
        DeferQualityUpdatesPeriodInDays,
        DeferFeatureUpdates,
        DeferFeatureUpdatesPeriodInDays
    }
    else {
        Write-Warning "Windows Update policy path ikke funnet!"
    }
}