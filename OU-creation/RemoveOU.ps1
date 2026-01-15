. .\OU-creation\ConfigOU.ps1

function Remove-CustomADOU {
    param (
        [string]$Identity
    )
    
    try {
        # Check if OU exists
        $ou = Get-ADOrganizationalUnit -Identity $Identity -ErrorAction SilentlyContinue
        
        if ($ou) {
            # Disable protection
            Set-ADOrganizationalUnit -Identity $Identity -ProtectedFromAccidentalDeletion $false
            
            # Remove OU
            Remove-ADOrganizationalUnit -Identity $Identity -Confirm:$false
            Write-Host "Successfully removed OU: $Identity" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "OU does not exist: $Identity" -ForegroundColor Yellow
            return $true
        }
    }
    catch {
        Write-Host "Failed to remove OU: $Identity" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        return $false
    }
}

function Remove-OUStructure {
    param (
        [hashtable]$Structure,
        [string]$DomainPath
    )
    
    # Remove child OUs first
    foreach ($parentOU in $Structure.Keys) {
        foreach ($childOU in $Structure[$parentOU]) {
            $childPath = "OU=$childOU,OU=$parentOU,$DomainPath"
            Remove-CustomADOU -Identity $childPath
        }
        
        # Then remove parent OU
        $parentPath = "OU=$parentOU,$DomainPath"
        Remove-CustomADOU -Identity $parentPath
    }
}

Remove-OUStructure -Structure $structure -DomainPath $domain_path
