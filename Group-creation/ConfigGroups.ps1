. .\ConfigOU.ps1
. .\Flags.ps1

Write-Host "Running Config..." -ForegroundColor Blue

$target = "InfraIT_Groups"

$group_path = findPathToTarget -struct $structure -current_path $domain_path -targ $target

# Define your groups with their properties
$groups = @(
    @{
        Name     = "HR"
        Path     = $group_path
        Scope    = "Global"
        Category = "Security"
    },
    @{
        Name     = "IT"
        Path     = $group_path
        Scope    = "Global"
        Category = "Security"
    },
    @{
        Name     = "Sales"
        Path     = $group_path
        Scope    = "Global"
        Category = "Security"
    },
    @{
        Name     = "Finance"
        Path     = $group_path
        Scope    = "Global"
        Category = "Security"
    },
    @{
        Name     = "Consultants"
        Path     = $group_path
        Scope    = "Global"
        Category = "Security"
    }
)