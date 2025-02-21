<#
.SYNOPSIS
    This PowerShell script checks multiple servers for availability, DNS resolution, Active Directory location, and open ports using parallel execution.

.DESCRIPTION
    - Reads server names from an input text file.
    - Uses multi-threading to check up to 10 servers concurrently.
    - Tests if each server responds to a ping.
    - Performs an NSLookup to retrieve DNS information.
    - Queries Active Directory to get the Distinguished Name of the server.
    - Checks if ports 135 (WMI) and 22 (SSH) are open.
    - Exports the results to a CSV file.

.NOTES
    - Requires the Active Directory module.
    - Uses PowerShell Jobs for parallel execution.
    - Ensures efficient execution by limiting concurrent jobs.
    - Outputs results in a structured CSV format.

.INPUTS
    - A text file containing a list of server names.

.OUTPUTS
    - A CSV file with details about each server, including:
        - Ping status
        - IP address
        - FQDN
        - NSLookup results
        - AD location
        - Port status (135 and 22)

#>


# Define the input and output files
$inputFile = "C:\Windows\temp\INPUT.txt"
$outputFile = "C:\Windows\temp\\output.csv"
 
# Read server names
$servers = Get-Content -Path $inputFile
 
# Load the Active Directory module
Import-Module ActiveDirectory
 
# Function to test if a port is open
function Test-Port {
    param ([string]$computer, [int]$port)
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    try {
        $tcpClient.Connect($computer, $port)
        return $true
    } catch {
        return $false
    } finally {
        $tcpClient.Close()
    }
}
 
# Limit the number of concurrent jobs
$maxConcurrentJobs = 10
$results = @()
 
# Start Jobs for Parallel Execution
foreach ($server in $servers) {
    while ((Get-Job -State Running).Count -ge $maxConcurrentJobs) {
        Start-Sleep -Seconds 2
    }
 
    Start-Job -ScriptBlock {
        param ($server)
 
        # Initialize result object
        $result = [PSCustomObject]@{
            "ServerName"     = $server
            "RespondedToPing"= $false
            "IPAddress"      = $null
            "FQDN"           = $null
            "NSLookupName"   = $null
            "NSLookupIP"     = $null
            "ADLocation"     = $null
            "Port135"        = $false
            "Port22"         = $false
        }
 
        # Perform a test ping
        $pingResult = Test-Connection -ComputerName $server -Count 1 -ErrorAction SilentlyContinue
        if ($pingResult) {
            $result.RespondedToPing = $true
            $result.IPAddress = $pingResult.IPV4Address
            $result.FQDN = [System.Net.Dns]::GetHostEntry($server).HostName
        }
 
        # Perform an NSLookup
        $nslookupResult = Resolve-DnsName $server -ErrorAction SilentlyContinue
        if ($nslookupResult) {
            $result.NSLookupName = $nslookupResult.Name
            $result.NSLookupIP = $nslookupResult.IPAddress
        }
 
        # Get the AD location of the server
        try {
            $adComputer = Get-ADComputer -Identity $server -ErrorAction SilentlyContinue
            if ($adComputer) {
                $result.ADLocation = $adComputer.DistinguishedName
            }
        } catch {}
 
        # Test ports
        $result.Port135 = Test-Port -computer $server -port 135
        $result.Port22 = Test-Port -computer $server -port 22
 
        # Return result
        return $result
 
    } -ArgumentList $server -Name "Check-$server"
}
 
# Monitor Job Completion
do {
    $runningJobs = Get-Job -State Running
    $completedJobs = Get-Job -State Completed
    Write-Host "Running Jobs: $($runningJobs.Count) | Completed Jobs: $($completedJobs.Count)"
    Start-Sleep -Seconds 2
} while ($runningJobs.Count -gt 0)
 
# Collect Results
$completedJobs = Get-Job -State Completed
foreach ($job in $completedJobs) {
    $results += Receive-Job -Job $job
    Remove-Job -Job $job
}
 
# Export results
$results | Export-Csv -Path $outputFile -NoTypeInformation
 
Write-Host "Script completed. Results saved to $outputFile"