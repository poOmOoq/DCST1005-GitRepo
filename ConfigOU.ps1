$domain_path = "DC=InfraIT,DC=sec"

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