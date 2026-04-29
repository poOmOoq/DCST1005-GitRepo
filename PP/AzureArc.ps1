$global:scriptPath = $myinvocation.mycommand.definition

function Restart-AsAdmin {
    $pwshCommand = "powershell"
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        $pwshCommand = "pwsh"
    }

    try {
        Write-Host "This script requires administrator permissions to install the Azure Connected Machine Agent. Attempting to restart script with elevated permissions..."
        $arguments = "-NoExit -Command `"& '$scriptPath'`""
        Start-Process $pwshCommand -Verb runAs -ArgumentList $arguments
        exit 0
    }
    catch {
        throw "Failed to elevate permissions. Please run this script as Administrator."
    }
}

try {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        if ([System.Environment]::UserInteractive) {
            Restart-AsAdmin
        }
        else {
            throw "This script requires administrator permissions to install the Azure Connected Machine Agent. Please run this script as Administrator."
        }
    }

    $env:SUBSCRIPTION_ID = "f33eb8f1-91ea-48f5-a632-d9cbfb3f58d8";
    $env:RESOURCE_GROUP = "kt04-rg-infraitsec-arc";
    $env:TENANT_ID = "07872396-b34f-4600-b15c-c98103a08062";
    $env:LOCATION = "norwayeast";
    $env:AUTH_TYPE = "token";
    $env:CORRELATION_ID = "57c80dfd-174e-49d0-b544-1189e330977b";
    $env:CLOUD = "AzureCloud";
    

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072;

    $azcmagentPath = Join-Path $env:SystemRoot "AzureConnectedMachineAgent"
    if (-Not (Test-Path -Path $azcmagentPath)) {
        New-Item -Path $azcmagentPath -ItemType Directory
        Write-Output "Directory '$azcmagentPath' created"
    }

    $tempPath = Join-Path $azcmagentPath "temp"
    if (-Not (Test-Path -Path $tempPath)) {
        New-Item -Path $tempPath -ItemType Directory
        Write-Output "Directory '$tempPath' created"
    }

    $installScriptPath = Join-Path $tempPath "install_windows_azcmagent.ps1"
    Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/azcmagent-windows" -TimeoutSec 30 -OutFile "$installScriptPath";
    & "$installScriptPath";
    if ($LASTEXITCODE -ne 0) { exit 1; }
    Start-Sleep -Seconds 5;
    & "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe" connect --resource-group "$env:RESOURCE_GROUP" --tenant-id "$env:TENANT_ID" --location "$env:LOCATION" --resource-name "DC1-kt04" --subscription-id "$env:SUBSCRIPTION_ID" --cloud "$env:CLOUD" --tags 'Datacenter=NTNU,City=Gjøvik,CountryOrRegion=Norway,Owner=kevinnt@stud.ntnu.no,Project=infrait-lab,CostCenter=lab' --correlation-id "$env:CORRELATION_ID";
}
catch {
    $logBody = @{subscriptionId = "$env:SUBSCRIPTION_ID"; resourceGroup = "$env:RESOURCE_GROUP"; tenantId = "$env:TENANT_ID"; location = "$env:LOCATION"; correlationId = "$env:CORRELATION_ID"; authType = "$env:AUTH_TYPE"; operation = "onboarding"; messageType = $_.FullyQualifiedErrorId; message = "$_"; };
    Invoke-WebRequest -UseBasicParsing -Uri "https://gbl.his.arc.azure.com/log" -Method "PUT" -Body ($logBody | ConvertTo-Json) | out-null;
    Write-Host  -ForegroundColor red $_.Exception;
}
