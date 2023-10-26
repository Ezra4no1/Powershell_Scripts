cls

<# This script was design to check if a server is up witha ping test, than to get it's FQDN,
and it's IP addressn than to get registered DNS name and IP through an NSLookup. 

The information may seem redundant, but came about from a large and old server  
environment where it was believed there were old DNS entrys and re-used IPs which 
didn't reflect the current state of the network. #>

# Define the input text file containing server names or IP addresses (one per line)
$inputFile = "c:\Path to file\server_list-INPUT.txt"

# Define the output CSV file
$outputFile = "c:\Path to file\server_info-OUTPUT.csv"

# Initialize an array to store the results
$results = @()

# Read the server list from the input file
$servers = Get-Content -Path $inputFile

# Loop through each server in the list
foreach ($server in $servers) {
    $result = [PSCustomObject]@{
        "ServerName" = $server
        "RespondedToPing" = $false
        "IPAddress" = $null
        "FQDN" = $null
        "NSLookupName" = $null
        "NSLookupIP" = $null
    }

    # Perform a test ping to the server
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

    # Add the result to the results array
    $results += $result

    # Display progress on the console
    Write-Host "Processed: $($result.ServerName)"
    Write-Host "Servers left: $($servers.Count - 1)"
    $servers = $servers | Where-Object { $_ -ne $server }
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "Script completed. Results saved to $outputFile"
