cls

<#
This script will check multiple servers from a text file if
PowerShell Remoting is enabled.

Adjust your input and output files in the script to your needs.
#>


# Path to the text file containing server names
$serverListFile = "C:\Path\To\Your\ServerList.txt"

# Path to the CSV file where results will be saved
$outputCSV = "C:\Path\To\Your\Output.csv"

# Read server names from the file
$servers = Get-Content $serverListFile

# Total number of servers
$totalServers = $servers.Count

# Array to hold the results
$results = @()

foreach ($server in $servers) {
    try {
        # Test PowerShell remoting
        $testResult = Test-WSMan -ComputerName $server -ErrorAction Stop
        $remotingEnabled = $true
    } catch {
        $remotingEnabled = $false
    }

    # Add the result to the array
    $results += [PSCustomObject]@{
        ServerName       = $server
        PowerShellRemoting = $remotingEnabled
    }

    # Decrease the counter and display the remaining number of servers
    $totalServers--
    Write-Host "$totalServers servers left to check..."
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputCSV -NoTypeInformation

Write-Host "Check completed. Results have been saved to $outputCSV"
