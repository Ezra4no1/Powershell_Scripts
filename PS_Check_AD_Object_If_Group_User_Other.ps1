cls
<#
Script will check AD if Object is a UserAcc, Group, or other
Script uses Text for for input and Outputs to a CSV file
CSV file will list Name (ObjectName) ObjectType ( User, Group, Computer)
and DistnguishedName (AD Location of Object)
#> 


# Import the Active Directory module
Import-Module ActiveDirectory
 
# Path to the text file containing the AD group names
$groupFile = "C:\Temp\INPUT.txt"
 
# Path for the output CSV file
$outputCsv = "C:\Temp\Output.csv"
 
# Read the group names from the file
$groups = Get-Content $groupFile
 
# Initialize an array to hold the output data
$outputData = @()
 
# Initialize progress bar variables
$totalGroups = $groups.Count
$currentGroup = 0
 
# Iterate through each group in the text file
foreach ($group in $groups) {
    # Update the progress bar
    $currentGroup++
    Write-Progress -Activity "Processing Active Directory Groups" -Status "$currentGroup of $totalGroups" -PercentComplete (($currentGroup / $totalGroups) * 100)
 
    # Check if the group exists
    $groupExists = Get-ADGroup -Filter { Name -eq $group } -ErrorAction SilentlyContinue
    if ($groupExists) {
        try {
            # Use a paginated approach for large groups
            $users = Get-ADGroupMember -Identity $group -ErrorAction Stop | Where-Object { $_.objectClass -eq 'user' } | Get-ADUser
 
            # Check if the group has users and add them to the output data
            if ($users) {
                foreach ($user in $users) {
                    $outputData += New-Object PSObject -Property @{
                        GroupName = $group
                        UserName = $user.SamAccountName
                    }
                }
            } else {
                $outputData += New-Object PSObject -Property @{
                    GroupName = $group
                    UserName = "No users found in group"
                }
            }
        } catch {
            $outputData += New-Object PSObject -Property @{
                GroupName = $group
                UserName = "Error retrieving group members: " + $_.Exception.Message
            }
        }
    } else {
        $outputData += New-Object PSObject -Property @{
            GroupName = $group
            UserName = "Group not found"
        }
    }
}
 
# Export the data to a CSV file
$outputData | Export-Csv -Path $outputCsv -NoTypeInformation
 
# Complete the progress bar
Write-Progress -Activity "Processing Active Directory Groups" -Completed
 
Write-Host "Export completed. Check the output at $outputCsv"
has context menu