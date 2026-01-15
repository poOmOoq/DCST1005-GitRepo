. .\Group-creation\ConfigGroups.ps1

function creatreGroups {
    # Create each group
    foreach ($group in $groups) {
        New-ADGroup -Name $group.Name `
            -GroupScope $group.Scope `
            -GroupCategory $group.Category `
            -Path $group.Path
    }
}

creatreGroups
