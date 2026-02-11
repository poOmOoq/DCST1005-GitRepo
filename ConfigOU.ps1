$domain_start = "InfraIT"

$domain_end = "sec"

$domain_path = "DC=$($domain_start),DC=$($domain_end)"

$all_departments = @(
    "Finance",
    "Sales",
    "IT",
    "Consultants",
    "HR"
)

$structure = @{
    "InfraIT_TestOU" = @(
        @{
            "InfraIT_Users" = $all_departments
        },
        @{
            "InfraIT_Computers" = 
            @(
                @{ "Workstations" = $all_departments },
                "Servers"
            )
        },
        "InfraIT_Groups"
    )
}

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