
<# A simple script that checks servers from a text file if port 3389 is open for RDP access #>

$serversFile = "C:\PATH_TO_LOCATION\SERVER_TO_CHECK.txt"
$reportFile = "C:\PATH_TO_LOCATION\SERVER_TO_CHECK-OUTPUT.txt"

 

# Read server names from the text file
$servers = Get-Content -Path $serversFile

 

# Initialize an empty array to store the results
$results = @()

 

# Loop through each server and check if Remote Desktop is enabled
foreach ($server in $servers) {
    $rdpEnabled = $false

 

    # Try to establish a remote connection to the server
    try {
        $rdpEnabled = Test-NetConnection -ComputerName $server -Port 3389 -InformationLevel Quiet
    } catch {
        $rdpEnabled = $false
    }

 

    # Add the server name and RDP status to the results array
    $result = [PSCustomObject]@{
        ServerName = $server
        RdpEnabled = $rdpEnabled
    }
    $results += $result
}

 

# Export the results to a report file
$results | Export-Csv -Path $reportFile -NoTypeInformation