# Tving Group Policy oppdatering på alle maskiner
$Computers = @('dc1', 'srv1', 'cl1')

foreach ($Computer in $Computers) {
    Write-Host "`nOppdaterer Group Policy på $Computer.infrait.sec..." -ForegroundColor Cyan
    
    Invoke-Command -ComputerName "$Computer.infrait.sec" -ScriptBlock {
        gpupdate /force
    } -ErrorAction Continue
}

Write-Host "`n⚠️  VIKTIG: Noen settings krever reboot for å tre i kraft!" -ForegroundColor Yellow
Write-Host "For PRODUKSJONSMILJØER: Planlegg en restart av maskiner i et maintenance vindu når det ikke påvirker mange brukere" -ForegroundColor Yellow