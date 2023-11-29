<# Checks if an AD Group has access to a Server #>

# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt user to enter the Active Directory group name
$groupName = Read-Host "Enter the Active Directory group name"
 
# Prompt user to enter the server name
$serverName = Read-Host "Enter the server name"
 
# Function to check if a user has access to the server
function Test-ServerAccess {
     param (
         [string]$server,
         [string]$user
     )
     
     # Perform your logic to check if the user has access to the server
     # This can include checking group memberships, permissions, etc.
     # Replace this logic with your specific requirements
     
     # For demonstration purposes, we'll just print a message
     Write-Host "$user has access to $server"
 }
 
 # Get members of the specified Active Directory group, including nested groups
 $groupMembers = Get-ADGroupMember -Identity $groupName -Recursive
 
 # Check if any member has access to the server
 $hasAccess = $false
 foreach ($member in $groupMembers) {
    # Check if the member is a user (not a group)
    if ($member.objectClass -eq "user") {
        # Perform logic to check if the user has access to the server
        # For demonstration purposes, let's assume all users have access
        Test-ServerAccess -server $serverName -user $member.SamAccountName
        $hasAccess = $true
        break  # Exit loop once access is found for any user
    }
    # If the member is a group, you may choose to recursively check its members as well
    # else {
    #     $nestedGroupMembers = Get-ADGroupMember -Identity $member.SamAccountName -Recursive
    #     foreach ($nestedMember in $nestedGroupMembers) {
    #         # Perform logic to check if the nested group member has access to the server
    #         # Test-ServerAccess -server $serverName -user $nestedMember.SamAccountName
    #         # Implement your specific logic here
    #     }
    # }
}
 
# Check if any member of the group has access to the server
if ($hasAccess) {
     Write-Host "The group $groupName has access to $serverName."
} else {
     Write-Host "No member of the group $groupName has access to $serverName."
}
 