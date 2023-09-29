<# This script will check the OS version of remote servers an output it to a CSV file. #>

CLS

# Define the path to the server names file and CSV output file
$serverNamesFile = "C:\PATH_TO_LOCATION\PS_Win-OS-Version-Check-Input.txt"
$outputCSV = "C:\PATH_TO_LOCATION\PS_Win-OS-Version-Check-output.csv"

 

# Read the server names from the text file
$serverNames = Get-Content $serverNamesFile
$totalServers = $serverNames.Count

 

# Initialize an empty array to store the results
$results = @()

 

# Loop through each server and check the Windows version
foreach ($server in $serverNames) {
    Write-Host "Checking server: $server"
    try {
        # Use Invoke-Command to run a remote command and get Windows version
        $winVersion = Invoke-Command -ComputerName $server -ScriptBlock { (Get-WmiObject Win32_OperatingSystem).Caption }
        $results += [PSCustomObject]@{
            ServerName = $server
            WindowsVersion = $winVersion
        }
    } catch {
        Write-Warning "Failed to connect to server: $server"
    }
    # Calculate how many servers are left to check and display the progress
    $totalServers--
    Write-Host "Servers left to check: $totalServers"
}

 

# Export the results to a CSV file
$results | Export-Csv -Path $outputCSV -NoTypeInformation

 

# Display the final message
Write-Host "Server check completed. Results saved to $outputCSV."