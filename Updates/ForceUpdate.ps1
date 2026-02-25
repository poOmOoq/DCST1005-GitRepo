# Definer alle domene-maskiner
$Computers = @('cl1', 'dc1', 'srv1')

# Tvinge GPO-oppdatering på alle maskiner
foreach ($Computer in $Computers) {
    Write-Host "Oppdaterer Group Policy på $Computer.infrait.sec..." -ForegroundColor Cyan
    
    Invoke-Command -ComputerName "$Computer.infrait.sec" -ScriptBlock {
        gpupdate /force
    }
}