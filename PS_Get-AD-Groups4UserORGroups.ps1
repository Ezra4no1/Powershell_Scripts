cls

# PowerShell Script to Get Group Memberships of a User in Active Directory
# Import the Active Directory Module
Import-Module ActiveDirectory

# Prompt for the username
$userName = Read-Host -Prompt "Enter the username"

# Get the user's group memberships
try {

    $groups = Get-ADPrincipalGroupMembership -Identity $userName
    if ($groups) {
        Write-Host "Groups for $userName"
        foreach ($group in $groups) {
            Write-Host $group.Name
        }
    } else {
        Write-Host "No groups found for user $userName"
    }
} catch {
    Write-Host "Error: $_"
}