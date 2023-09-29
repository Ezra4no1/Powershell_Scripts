CLS

<# This script checks to see if RDS is enabled on remote servers #>

$serverListFile = "C:\PATH_TO_LOCATION\PS_CheckRDSenabled-INPUT.txt"
$outputCSV = "C:\PATH_TO_LOCATION\CheckRDSenabled-OUTPUT.csv"

 

# Read the server list from the text file
$servers = Get-Content $serverListFile
$totalServers = $servers.Count
$currentServer = 1

 

# Create an array to store the results
$results = @()

 

foreach ($server in $servers) {
    # Check if RDS is enabled on the remote server
    $rdsEnabled = Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue

    # Create an object with the server name and RDS status
    $result = [PSCustomObject]@{
        ServerName = $server
        RDSStatus = $rdsEnabled
    }

    # Add the result to the array
    $results += $result

    # Display the countdown on the screen
    Write-Host "Servers left to check: $($totalServers - $currentServer)"
    $currentServer++
}

 

# Export the results to a CSV file
$results | Export-Csv -Path $outputCSV -NoTypeInformation

 

Write-Host "Script execution completed."