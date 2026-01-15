$end_program = "Exiting program due to: "

$format_error = "Incorrect structure format"

$example_format = "F.ex.: `$structure = @( `"Folder1`", { `"Folder2`" = @(More folders...) } )"

. .\ConfigOU.ps1
. .\OU-creation\Flags.ps1

function createNewOU {
    param (
        [string]$Name,
        [string]$Path,
        [switch]$DisableProtection
    )
    
    try {
        # Check if OU exists - we need to handle the case where the search base doesn't exist
        try {
            $existingOU = Get-ADOrganizationalUnit -Filter "Name -eq '$Name'" -SearchBase $Path -ErrorAction Stop
        }
        catch {
            # If SearchBase doesn't exist, we know the OU doesn't exist
            $existingOU = $false
        }

        if ($existingOU) {
            # Create new OU
            Write-Host "OU already exists: $Name in $Path" -ForegroundColor Yellow
            return $true
        }

        $params = @{
            Name                            = $Name
            Path                            = $Path
            ProtectedFromAccidentalDeletion = -not $DisableProtection
        }

        New-ADOrganizationalUnit @params
        Write-Host "Successfully created OU: $Name in $Path" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Failed to create OU: $Name" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        return $false
    }
}

function showError {
    param (
        [Parameter(Mandatory)]
        [Alias("w")]
        [string]
        $what_is_wrong,

        [Alias("h")]
        [string]
        $hints,

        [Alias("p")]
        [string]
        $plain_text
    )

    if (-not $what_is_wrong) {
        throw "Required parameter cannot be null."
    }
    
    Write-Host $what_is_wrong -ForegroundColor Red
    if ($hints) {
        Write-Host $hints -ForegroundColor Yellow
    }
    if ($plain_text) {
        Write-Host $plain_text
    }
    throw "Exiting program: $what_is_wrong"
}

function validateStruct {
    param(
        [Parameter(Mandatory)]
        [Alias("a")]
        [array]
        $array,

        [Parameter(Mandatory)]
        [Alias("st")]
        [bool]
        $show_text,

        [int16]
        $n = 0
    )

    foreach ($parent in $array) {
        # Check for correct structure
        $type = $parent.GetType().Name
        if (-not @($hashtable_flag, $string_flag).Contains($type)) {
            showError -w $format_error -h "Folder must be a hashmap with an array with folders, or a string" -p $example_format
        }

        $tab = "`t" * $n

        # If there are no sub-OU
        if ($type -eq $string_flag) {
            if ($show_text) {
                Write-Host ($tab + $parent)
            }
            continue
        }
        
        $key = $parent.Keys[0]
        
        if ($show_text) {
            Write-Host ($tab + $key)
        }

        $parent[$key] | ForEach-Object {
            validateStruct -a $_ -st $show_text -n ($n + 1)
        }
    }
}

function validateStruct_container {
    param(
        [Parameter(Mandatory)]
        [Alias("structure")]
        [array]
        $struct,

        [Alias("st")]
        [bool]
        $show_text = $false
    )

    
    try {
        # Check for correct structure
        if ($struct.GetType().Name -cne $array_flag) {
            showError -w $format_error -h "Main structure must be an array" -p $example_format
        }
        validateStruct -a $struct -st $show_text
    }
    catch {
        return $false
    }
    return $true
}

function create_Complete_OU_From_Structure {
    param(
        [Parameter(Mandatory)]
        [string]
        $domainPath,

        [Parameter(Mandatory)]
        [hashtable]
        $ouStructure
    )
    foreach ($parentOU in $ouStructure.Keys) {
        # Create parent OU
        $parentPath = $domainPath
        Write-Host "`nCreating parent OU: $parentOU" -ForegroundColor Cyan
        $parentCreated = createNewOU -Name $parentOU -Path $parentPath
    
        if ($parentCreated) {
            # Verify parent OU exists before creating children
            $parentFullPath = "OU=$parentOU,$domainPath"
            $verifyParent = Get-ADOrganizationalUnit -Identity $parentFullPath -ErrorAction SilentlyContinue
        
            if ($verifyParent) {
                Write-Host "Verified parent OU exists, creating children..." -ForegroundColor Cyan
                # Create child OUs
                $ouStructure[$parentOU] | ForEach-Object {
                    $childPath = $parentFullPath

                    if ($_.GetType().Name -ceq $string_flag) {
                        createNewOU -Name $_ -Path $childPath
                    }
                    else {
                        create_Complete_OU_From_Structure -ouStructure $_ -domainPath $childPath
                    }
                }
            }
            else {
                Write-Host "Parent OU verification failed for: $parentOU" -ForegroundColor Red
                Write-Host "Cannot create child OUs" -ForegroundColor Red
            }
        }
    }
    
}

function BuildOU {
    Write-Host "Validating structure..." -ForegroundColor Blue

    $valid_structure = validateStruct_container -struct $structure # -st $true

    if (-not $valid_structure) {
        Write-Host ($end_program + $format_error) -ForegroundColor Magenta
        exit 0
    }

    Write-Host "Struture is correctly formated" -ForegroundColor Green
    Write-Host "Starting creation of Complete OU..." -ForegroundColor Blue
    create_Complete_OU_From_Structure -ouStructure $structure -domainPath $domain_path
}

BuildOU
