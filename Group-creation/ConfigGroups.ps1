. .\ConfigOU.ps1
. .\Flags.ps1

Write-Host "Running Config..." -ForegroundColor Blue

function findPathToTarget {
    param (
        [Parameter(Mandatory)]
        [hashtable]
        $struct,
        [Parameter(Mandatory)]
        [string]
        $current_path,
        [Parameter(Mandatory)]
        [string]
        $targ
    )
        
    $current_OU = $struct.Keys[0]
        
    $children_OU = $struct[$current_OU][0]
        
    if ($children_OU.Contains($targ)) {
        return "OU=$targ,OU=$current_OU,$current_path"
    }
    
    $current_path = "OU=$current_OU,$current_path"
    
    $children_OU | ForEach-Object {
        if ($_.GetType().Name -ceq $hashtable_flag) {
            return findPathToTarget -struct $_ -current_path $current_path -targ $targ
        }
    }
}

$target = "InfraIT_Groups"

$group_path = findPathToTarget -struct $structure -current_path $domain_path -targ $target

# Define your groups with their properties
$groups = @(
    @{
        Name     = "HR Team"
        Path     = $group_path
        Scope    = "Global"
        Category = "Security"
    },
    @{
        Name     = "IT Team"
        Path     = $group_path
        Scope    = "Global"
        Category = "Security"
    },
    @{
        Name     = "Sales Team"
        Path     = $group_path
        Scope    = "Global"
        Category = "Security"
    },
    @{
        Name     = "Finance Team"
        Path     = $group_path
        Scope    = "Global"
        Category = "Security"
    },
    @{
        Name     = "Consultants Team"
        Path     = $group_path
        Scope    = "Global"
        Category = "Security"
    }
)