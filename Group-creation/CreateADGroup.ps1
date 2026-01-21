Clear-Host

. .\Group-creation\ConfigGroups.ps1 
function New-CustomADGroup {
    param (
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Path,
        [ValidateSet("Global", "Universal", "DomainLocal")]
        [string]$Scope = "Global",
        [ValidateSet("Security", "Distribution")]
        [string]$Category = "Security",
        [string]$Description
    )
    
    try {
        # Check if group exists
        $existingGroup = Get-ADGroup -Filter "Name -eq '$Name'" -ErrorAction SilentlyContinue
        
        if ($null -eq $existingGroup) {
            # Create new group
            $params = @{
                Name = $Name
                GroupScope = $Scope
                GroupCategory = $Category
                Path = $Path
            }
            
            if ($Description) {
                $params.Add("Description", $Description)
            }
            
            New-ADGroup @params
            Write-Host "Successfully created group: $Name" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Group already exists: $Name" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "Failed to create group: $Name" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        Write-Host $Path
        return $false
    }
}

foreach ($group in $groups) {
    if (New-CustomADGroup -Name $group.Name -Path $group.Path -Scope $group.Scope -Category $group.Category) {
        if ($group.Members) {
            Add-CustomADGroupMember -GroupName $group.Name -Members $group.Members
        }
    }
}

New-CustomADGroup
