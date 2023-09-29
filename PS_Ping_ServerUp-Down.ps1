cls

<# PS_Ping_ServerUp-Down.ps1
This script will ping servers from a text file and places its output
onto 2 separate text files, of servers that respond to the ping and
servers that do not respond to the ping. #>

$serverListFile = "C:\PATH_TO_LOCATION\SERVERS_TO_PING.txt"
$responsiveServersFile = "C:\PATH_TO_LOCATION\LIST_OF_SERVERS_THAT_RESPOND_TO_PINGs.txt"
$unresponsiveServersFile = "C:\PATH_TO_LOCATION\LIST_OF_SERVERS_THAT_DO NOT_RESPOND_TO_PINGs.txt"

# Read the server list from the text file
$servers = Get-Content $serverListFile
$totalServers = $servers.Count
Write-Host "Total number of servers: $totalServers"

# Initialize arrays to store responsive and unresponsive servers
$responsiveServers = @()
$unresponsiveServers = @()

# Loop through each server and ping it
foreach ($index in 0..($totalServers - 1)) {
   $server = $servers[$index]

   # Display countdown
   $countdown = $totalServers - $index
   Write-Host "Pinging server '$server'... ($countdown servers remaining)"
   if (Test-Connection -ComputerName $server -Count 1 -Quiet) {

       # Server responded to ping
       $responsiveServers += $server
   } else {

       # Server did not respond to ping
       $unresponsiveServers += $server
   }
}

# Output responsive servers to a text file
$responsiveServers | Out-File -FilePath $responsiveServersFile -Encoding UTF8

# Output unresponsive servers to a text file
$unresponsiveServers | Out-File -FilePath $unresponsiveServersFile -Encoding UTF8
Write-Host "Responsive servers written to: $responsiveServersFile"
Write-Host "Unresponsive servers written to: $unresponsiveServersFile"