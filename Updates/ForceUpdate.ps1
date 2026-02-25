# Definer alle domene-maskiner
$Computers = @('cl1.infrait.sec', 'dc1.infrait.sec', 'srv1.infrait.sec', 'mgr-but-better.infrait.sec')

# Tvinge GPO-oppdatering på alle maskiner
foreach ($Computer in $Computers) {
    Write-Host "Oppdaterer Group Policy på $Computer.infrait.sec..." -ForegroundColor Cyan
    
    Invoke-Command -ComputerName "$Computer.infrait.sec" -ScriptBlock {
        gpupdate /force
    }
}