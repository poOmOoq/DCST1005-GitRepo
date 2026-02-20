$htmlMainTemplate = @"
<html>
<head>
    <title>
        Server Health Dashboard: Full CSV
    </title>
</head>
<body>
    <h2>Last update: PLACEHOLDER_TIME</h2>
    <table border="1">
        PLACEHOLDER_ROWS
    </table>
</body>
</html>
"@

. .\Monitoring\Performance\PerformanceMetrics.ps1

$htmlMainContent = $htmlMainTemplate -replace "PLACEHOLDER_TIME", "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

$CSV = Get-Content C:\Users\adm_kevin\Documents\PowerShellThingy\DCST1005-GitRepo\Monitoring\Performance\performance.csv
$CSV | ForEach-Object {
    $line = $_.Replace('"', "").Split(",")
    $row = "<tr>"
    $line | ForEach-Object {
        $row += "<th>" + $_ + "</th>"
    }
    $row += "</tr>"
    $htmlMainContent = $htmlMainContent.Insert($htmlMainContent.IndexOf("PLACEHOLDER_ROWS"), $row)
}

$htmlMainContent = $htmlMainContent -replace "PLACEHOLDER_ROWS", ""

$htmlPath = "C:\Users\adm_kevin\Documents\PowerShellThingy\DCST1005-GitRepo\Monitoring\Performance\FullCSV\performancemonitor.html"
$serverPath = "C:\inetpub\wwwroot\performancemonitor.html"
$htmlMainContent | Out-File -FilePath $htmlPath -Force

$session = New-PSSession -ComputerName srv1
Copy-Item $htmlPath -Destination $serverPath -ToSession $session
Remove-PSSession $session
