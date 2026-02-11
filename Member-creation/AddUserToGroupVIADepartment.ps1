# Define department mappings
$departmentGroups = @{
    "Finance" = "g_all_finance"
    "Sales" = "g_all_sales"
    "IT" = "g_all_it"
    "Consultants" = "g_all_consultants"
    "HR" = "g_all_hr"
}

# Process each department
foreach ($dept in $departmentGroups.Keys) {
    $groupName = $departmentGroups[$dept]
    
    # Get users from department
    $users = Get-ADUser -Filter {department -eq $dept} -Properties department
    
    # Add users to corresponding group
    foreach ($user in $users) {
        try {
            Add-ADGroupMember -Identity $groupName -Members $user.SamAccountName
            Write-Host "Added $($user.Name) from $dept to $groupName"
        }
        catch {
            Write-Host "Error adding $($user.Name): $_" -ForegroundColor Red
        }
    }
}