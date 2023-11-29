<# Checks if a user is a member of an AD group on a local or remote computer #>

# Ask the user to specify local (L) or remote (R) computer
$locationChoice = Read-Host "Type 'L' to check the local computer or 'R' to check a remote computer:"

if ($locationChoice -eq 'L') {
    # Local computer
    $computerName = $env:COMPUTERNAME
} elseif ($locationChoice -eq 'R') {
    # Remote computer - ask for the computer name
    $computerName = Read-Host "Enter the name of the remote computer:"
} else {
    Write-Host "Invalid choice. Please type 'L' for local or 'R' for remote."
    exit
}

# Ask the user to input the group name
$groupName = Read-Host "Enter the AD group name:"

# Ask the user to input the username to check
$userToCheck = Read-Host "Enter the username to check:"

# Check if the user is a member of the specified AD group on the specified computer
$isMember = $null

if ($locationChoice -eq 'L') {
    $isMember = Get-LocalGroupMember -Group $groupName -ComputerName $computerName | Where-Object { $_.Name -eq $userToCheck }
} elseif ($locationChoice -eq 'R') {
    $isMember = Get-ADGroupMember -Identity $groupName -Server $computerName -Recursive | Where-Object { $_.SamAccountName -eq $userToCheck }
}

if ($isMember) {
    Write-Host "$userToCheck is a member of $groupName on $computerName"
} else {
    Write-Host "$userToCheck is not a member of $groupName on $computerName"
}
