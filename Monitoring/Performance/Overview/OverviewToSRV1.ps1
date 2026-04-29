$htmlMainTemplate = @"
<html>
<head>
    <title>
        Server Health Dashboard: Overview
    </title>
</head>
<body>
    <h2>Last update: PLACEHOLDER_TIME</h2>
    PLACEHOLDER_SERVER
</body>
</html>
"@

$htmlServerTemplate = @"
    <br>
    <h3>=== PLACEHOLDER_SERVER_NAME ===</h3>
    <table border="1">
        <tr>
            <th>Counter</th>
            <th>Value</th>
        </tr>
        PLACEHOLDER_ROWS
    </table>
"@

$htmlRowTemplate = @"
        <tr>
            <th>PLACEHOLDER_COUNTER</th>
            <th>PLACEHOLDER_VALUE</th>
        </tr>
"@

#while ($true) {
. .\Monitoring\Performance\PerformanceMetrics.ps1

$htmlMainContent = $htmlMainTemplate -replace "PLACEHOLDER_TIME", "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$ignoredPropertiNames = @("Time", "Computer_Name", "PSComputerName", "RunspaceId", "PSShowComputerName")

foreach ($server in $results) {
    $htmlServerContent = $htmlServerTemplate -replace "PLACEHOLDER_SERVER_NAME", $server.Computer_Name
        
    foreach ($prop in $server.PSObject.Properties) {
        if ($ignoredPropertiNames.IndexOf($prop.Name) -gt -1) { continue }
        $htmlRowContent = $htmlRowTemplate -replace "PLACEHOLDER_COUNTER", $prop.Name -replace "PLACEHOLDER_VALUE", $prop.Value

        $htmlServerContent = $htmlServerContent.Insert($htmlServerContent.IndexOf("PLACEHOLDER_ROWS"), $htmlRowContent)
    }

    $htmlServerContent = $htmlServerContent -replace "PLACEHOLDER_ROWS", ""

    $htmlMainContent = $htmlMainContent.Insert($htmlMainContent.IndexOf("PLACEHOLDER_SERVER"), $htmlServerContent)
}

$htmlMainContent = $htmlMainContent -replace "PLACEHOLDER_SERVER", ""

$htmlPath = "C:\Users\adm_kevin\Documents\PowerShellThingy\DCST1005-GitRepo\Monitoring\Performance\Overview\performanceoverview.html"
$serverPath = "C:\inetpub\wwwroot\performanceoverview.html"
$htmlMainContent | Out-File -FilePath $htmlPath -Force

$session = New-PSSession -ComputerName srv1
Copy-Item $htmlPath -Destination $serverPath -ToSession $session
Remove-PSSession $session


#Start-Sleep -Seconds 5
#}