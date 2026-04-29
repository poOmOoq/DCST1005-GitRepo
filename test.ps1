$t = Get-Content C:\Users\adm_kevin\Documents\PowerShellThingy\DCST1005-GitRepo\Monitoring\Performance\performance.csv
$t | ForEach-Object {
    $_ = $_.Replace('"', "").Split(",")
    $_ | ForEach-Object {
        Write-Host $_
    }
}