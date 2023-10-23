cls

<# This script will list all the HDDs of a server, if it's an SSD or a HDD, display total disk space,
free disk space, and the partition type. It will display this to the console, than it will ask you if you want
to check another server. #>
 
Write-Host "================================="
Write-Host "This script will list all the HDD"
Write-Host "of a server, the total Disk size, "
Write-Host "Free space, and Partition Type.  "
Write-Host "================================="
Write-Host ""
<# This scipt will list all the server's HDD's, Total space
and Free space, and the Partition Type (MBR, GPT) #>
 
do {
    # Prompt the user for the server name
    $serverName = Read-Host "Enter the server name"
    Write-Host "-----------------------"
 
 
    # Check if the server responds to ping
    if (Test-Connection -ComputerName $serverName -Count 1 -Quiet) {
        # Get the FQDN of the server
        $fqdn = [System.Net.Dns]::GetHostEntry($serverName).HostName
 
 
        # Get disk information on the remote server
        $disks = Get-WmiObject -ComputerName $serverName -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
 
 
        # Display server information
        Write-Host ""
        Write-Host "Server Name: $serverName"
        Write-Host "FQDN: $fqdn"
 
 
        # Display disk information
        foreach ($disk in $disks) {
            $diskType = if ($disk.MediaType -eq "Fixed hard disk media") { "HDD" } else { "SSD" }
            $partitionType = if ($disk.Partitions -eq 1) { "MBR" } else { "GPT" }
 
 
            Write-Host "Drive Letter: $($disk.DeviceID)"
            Write-Host "Total Size: $([math]::Round($disk.Size / 1GB, 2)) GB"
            Write-Host "Free Space: $([math]::Round($disk.FreeSpace / 1GB, 2)) GB"
            Write-Host "Drive Type: $diskType"
            Write-Host "Partition Type: $partitionType"
            Write-Host "-----------------------"
        }
    } else {
        Write-Host "Server '$serverName' is not responding to ping."
    }
 
 
    # Ask the user if they want to check another server
    $choice = Read-Host "Do you want to check another server? (Y/N)"
} while ($choice -eq "Y" -or $choice -eq "y")