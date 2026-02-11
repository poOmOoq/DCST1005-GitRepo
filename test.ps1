$scriptblock = {
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools
}

Invoke-Command -ComputerName srv1 -ScriptBlock $scriptblock