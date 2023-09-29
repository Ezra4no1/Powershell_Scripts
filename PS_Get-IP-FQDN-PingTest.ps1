cls

# PS_Get-IP-FQDN-PingTest.ps1

<# This script is used to Ping Test a Server node and get
its FQDN and then output the results to a CSV file. #>


$servers = Get-Content -Path "C:\PATH_TO_LOCATION\FILE_NAME.txt"
$results = @()

foreach ($server in $servers) {
    $serverName = $server
    $fqdn = ""
    $ipAddress = ""
    $pingResponse = ""

 

    # Get FQDN and IP address
    try {
        $fqdn = [System.Net.Dns]::GetHostEntry($server).HostName
        $ipAddress = [System.Net.Dns]::GetHostEntry($server).AddressList.IPAddressToString
    } catch {
        $fqdn = "Unknown"
        $ipAddress = "Unknown"
    }

 

    # Ping test
    $pingReply = Test-Connection -ComputerName $server -Count 1 -Quiet
    if ($pingReply) {
        $pingResponse = "Responded"
    } else {
        $pingResponse = "Not Responded"
    }

 

    # Create custom object with server details
    $serverDetails = [PSCustomObject]@{
        ServerName = $serverName
        FQDN = $fqdn
        IPAddress = $ipAddress
        PingResponse = $pingResponse
    }
    $results += $serverDetails

 

    # Display countdown on the console
    $serversLeft = $servers.Count - $results.Count
    Write-Host "Servers left to check: $serversLeft"
}

 

# Export results to CSV file
$results | Export-Csv "C:\PATH_TO_LOCATION\FILE_NAME.csv" -NoTypeInformation
