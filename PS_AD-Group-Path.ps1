<# Script will get the Distinguished name\path of an AD Group, 
   it's Group Scope, Category, & Description if there is one #>


cls

# Ensure the Active Directory module is loaded
Import-Module ActiveDirectory
# Prompt the user for the name of the security group
$groupName = Read-Host -Prompt "Enter the name of the security group"
# Get the security group details
$group = Get-ADGroup -Identity $groupName -ErrorAction SilentlyContinue
# Check if the group was found
if ($group) {
    # Display the requested information about the group
    Write-Output "Group Name: $($group.Name)"
    Write-Output "Description: $($group.Description)"
    Write-Output "Distinguished Name: $($group.DistinguishedName)"
    Write-Output "Group Scope: $($group.GroupScope)"
    Write-Output "Group Category: $($group.GroupCategory)"
} else {
    Write-Output "Security group '$groupName' not found."