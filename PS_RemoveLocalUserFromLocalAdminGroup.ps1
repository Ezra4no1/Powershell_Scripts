<# This script will remove a user account from the local admin group on a group of servers #>

# Read the CSV file

$servers = Import-Csv -Path "C:\PATH_TO_LOCATION\PS_RemoveLocalUserFromLocalAdminGroup.csv"

 

# Function to remove user from local administrator group

function RemoveUserFromAdminGroup {

    param(

        [string]$serverName,

        [string]$userName

    )

   

    $group = [ADSI]"WinNT://$serverName/administrators,group"

    $group.Remove("WinNT://$serverName/$userName,user")

}

 

# Function to check if user is in local administrator group

function IsUserInAdminGroup {

    param(

        [string]$serverName,

        [string]$userName

    )

   

    $group = [ADSI]"WinNT://$serverName/administrators,group"

    $members = $group.Invoke("Members")

    $members | ForEach-Object {

        if ($_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) -eq $userName) {

            return $true

        }

    }

    return $false

}

 

# Process each server

foreach ($server in $servers) {

    $serverName = $server.Server

    $userName = $server.User

   

    Write-Host "Processing server $serverName..."

   

    RemoveUserFromAdminGroup -serverName $serverName -userName $userName

   

    $remainingServers = $servers | Where-Object { $_.Server -ne $serverName }

    $remainingCount = $remainingServers.Count

   

    Write-Host "$remainingCount servers left to check."

}

 

# Check if user is still in administrator group

$results = @()

foreach ($server in $servers) {

    $serverName = $server.Server

    $userName = $server.User

   

    $isUserInAdminGroup = IsUserInAdminGroup -serverName $serverName -userName $userName

   

    $result = [PSCustomObject]@{

        ServerName = $serverName

        UserName = $userName

        Result = if ($isUserInAdminGroup) { "Account NOT REMOVED" } else { "Account removed" }

    }

   

    $results += $result

}

 

# Write results to CSV

$results | Export-Csv -Path "C:\PATH_TO_LOCATION\PS_RemoveLocalUserFromLocalAdminGroup-OUTPUT.csv" -NoTypeInformation

 

Write-Host "Script completed. Results written to PS_RemoveLocalUserFromLocalAdminGroup-OUTPUT.csv."

 