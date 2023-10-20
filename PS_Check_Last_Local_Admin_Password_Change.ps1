CLS
<# Script will check the local Admin account of when the last time it's password was changed. #>
# Define the path to the text file containing server names
$serverListFile = "C:\PATH_TO_FILE_LOCATION\Chk-Local_Admin_Passw-Change-INPUT.txt"

# Define the path for the CSV file to store the results
$csvOutputFile = "C:\PATH_TO_FILE_LOCATION\Chk-Local_Admin_Passw-Change-OUTPUT.csv"

# Initialize a counter to keep track of servers
$serverCount = 0

# Initialize an array to store results
$results = @()

# Read the list of server names from the text file
$serverNames = Get-Content $serverListFile

# Loop through each server in the list
foreach ($serverName in $serverNames) {
    $serverCount++
    Write-Host "Checking Server $serverCount $serverName"

    # Use Invoke-Command to run the command on the remote server
    $passwordLastSet = Invoke-Command -ComputerName $serverName -ScriptBlock {
        Get-LocalUser Administrator | Select-Object -ExpandProperty PasswordLastSet
    }

    # Create an object with server name and password last set date
    $result = [PSCustomObject]@{
        "ServerName"      = $serverName
        "PasswordLastSet" = $passwordLastSet
    }

    # Add the result to the results array
    $results += $result
}

# Export the results to a CSV file
$results | Export-Csv -Path $csvOutputFile -NoTypeInformation

Write-Host "Completed checking servers. Results exported to $csvOutputFile."