<# This script will get CPU count, Cores Per CPU, and Total Core count from remote servers. 
If the script is unabled to connect to a server or get the data, it will output the server name
with Error on the console and in the csv file. #>
CLS

# Define the path to the text file containing server names
$serverListPath = "C:\Path\To\Your\ServerList.txt"

# Define the path to the output CSV file
$outputCsvPath = "C:\Path\To\Your\Output.csv"

# Read the list of server names from the text file
$servers = Get-Content $serverListPath

# Initialize an array to store the results
$results = @()

# Process each server
foreach ($server in $servers) {
    try {
        # Get the number of CPUs
        $cpuCount = (Get-WmiObject -ComputerName $server -Class Win32_ComputerSystem).NumberOfProcessors

        # Get information about the processors
        $processors = Get-WmiObject -ComputerName $server -Class Win32_Processor

        # Calculate the total number of cores
        $totalCores = ($processors | Measure-Object -Property NumberOfCores -Sum).Sum
        
        # Display the remaining number of servers
        $remainingServers = $servers.Count - $results.Count
        Write-Host "Servers remaining: $remainingServers"

        # Add the result to the array
        $result = [PSCustomObject]@{
            Server = $server
            CPUs = $cpuCount
            CoresPerCPU = $processors[0].NumberOfCores
            TotalCores = $totalCores
            Error = $null  # No error, set to null
        }
        $results += $result
    } catch {
        # If an error occurs, add an "Error" entry to the array
        Write-Host "Error checking server: $server"
        $result = [PSCustomObject]@{
            Server = $server
            CPUs = $null
            CoresPerCPU = $null
            TotalCores = $null
            Error = "Error"
        }
        $results += $result
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputCsvPath -NoTypeInformation

Write-Host "Script completed. Results exported to $outputCsvPath"
