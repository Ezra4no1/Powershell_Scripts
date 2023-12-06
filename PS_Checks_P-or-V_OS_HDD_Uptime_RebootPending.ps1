cls
<#
my Powershell Scripts
This script came about from several smaller scripts I have.
I created Script Blocks out of those smaller ones and combined all of them
into this one script, allowing me to choose what part of the script I want
to run. 
I may add more blocks to this script as time goes on and I find it benifical.

This script is designed for you to check any of the following:
* Physical or Virtual - Checks If a server is a Physical Server or a virtual server.
* OS Check – Checks OS version, It’s install date, and if there is a Pending Reboot.
* HDD – will list all Hard drives, Disk size, Free space, and Partition Type.
* Uptime - Will list uptime, last reboot, and if a pending Reboot is needed.
#>

# Script Blocks
$UpTIME = {
    param ($choice, $remoteComputer)
    cls
    Write-Host " "
    Write-Host "------------------------------------------------------------------------------------------------"
    Write-Host " "
    Write-Host "------------------------------------------------ "
    Write-Host "my Powershell Scripts - UpTime"
    Write-Host "------------------------------------------------ "
    Write-Host "This script checks the Uptime of a server, the date of last Reboot,"
    Write-Host "if there is a pending Reboot waiting, and who initiated the last reboot."
    Write-Host "====================================================================="
    Write-Host " "
do {
    # Prompt user for checking local or remote computer
    $choice = Read-Host "Enter 'L' to check local computer or 'R' to check a remote computer"
    if ($choice -eq 'L') {
        # Get server uptime for local computer
        $uptime = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty LastBootUpTime
        $uptime = (Get-Date) - [System.Management.ManagementDateTimeConverter]::ToDateTime($uptime)
        $uptimeMessage = "Server Uptime: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes"
        # Get last reboot time for local computer
        $lastReboot = (Get-WmiObject -Class Win32_OperatingSystem).LastBootUpTime
        $lastReboot = [System.Management.ManagementDateTimeConverter]::ToDateTime($lastReboot)
        $lastRebootMessage = "Last Reboot Time: $($lastReboot.ToString('yyyy-MM-dd HH:mm:ss'))"
        # Check for pending reboot for local computer
        $pendingReboot = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' -ErrorAction SilentlyContinue) -ne $null
        if ($pendingReboot) {
            $pendingRebootMessage = "Pending Reboot: Yes"
        } else {
            $pendingRebootMessage = "Pending Reboot: No"
        }
        # Get last reboot initiator for local computer
        $lastRebootInitiator = "Not Available"
        $events = Get-WinEvent -FilterHashtable @{Logname='System';ID=1074} -MaxEvents 5 | Where-Object {$_.MachineName -eq $env:COMPUTERNAME} | Select-Object -ExpandProperty Message
        foreach ($event in $events) {
            $userStartIndex = $event.IndexOf('User:')
            if ($userStartIndex -ne -1) {
                $userEndIndex = $event.IndexOf(';', $userStartIndex)
                if ($userEndIndex -ne -1) {
                    $lastRebootInitiator = $event.Substring($userStartIndex + 5, $userEndIndex - $userStartIndex - 5).Trim()
                    break
                }
            }
        }
        $lastRebootInitiatorMessage = "Last Reboot Initiator: $lastRebootInitiator"
        # Display information for local computer
        $uptimeMessage
        $lastRebootMessage
        $pendingRebootMessage
        $lastRebootInitiatorMessage
    } elseif ($choice -eq 'R') {
        # Get the remote computer name from the user
        Write-Host "--------------------------------------"
        $remoteComputer = Read-Host "Enter the name of the remote computer"
        Write-Host "--------------------------------------"
        # Get server uptime for remote computer
        $uptime = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $remoteComputer | Select-Object -ExpandProperty LastBootUpTime
        $uptime = (Get-Date) - [System.Management.ManagementDateTimeConverter]::ToDateTime($uptime)
        $uptimeMessage = "Server Uptime: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes"
        # Get last reboot time for remote computer
        $lastReboot = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $remoteComputer).LastBootUpTime
        $lastReboot = [System.Management.ManagementDateTimeConverter]::ToDateTime($lastReboot)
        $lastRebootMessage = "Last Reboot Time: $($lastReboot.ToString('yyyy-MM-dd HH:mm:ss'))"
        # Check for pending reboot for remote computer
        $pendingReboot = (Get-ItemProperty -Path "\\$remoteComputer\HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction SilentlyContinue) -ne $null
        if ($pendingReboot) {
            $pendingRebootMessage = "Pending Reboot: Yes"
        } else {
            $pendingRebootMessage = "Pending Reboot: No"
        }
        # Get last reboot initiator for remote computer
        $lastRebootInitiator = "Not Available"
        $events = Get-WinEvent -FilterHashtable @{Logname='System';ID=1074} -ComputerName $remoteComputer -MaxEvents 5 | Where-Object {$_.MachineName -eq $remoteComputer} | Select-Object -ExpandProperty Message
        foreach ($event in $events) {
            $userStartIndex = $event.IndexOf('User:')
            if ($userStartIndex -ne -1) {
                $userEndIndex = $event.IndexOf(';', $userStartIndex)
                if ($userEndIndex -ne -1) {
                    $lastRebootInitiator = $event.Substring($userStartIndex + 5, $userEndIndex - $userStartIndex - 5).Trim()
                    break
                }
            }
        }
        $lastRebootInitiatorMessage = "Last Reboot Initiator: $lastRebootInitiator"
        # Display information for remote computer
        $uptimeMessage
        $lastRebootMessage
        $pendingRebootMessage
        $lastRebootInitiatorMessage
    } else {
        Write-Host "Invalid choice. Please enter 'L' for local or 'R' for remote."
    }
    # Ask if the user wants to check another remote computer
    $checkAnother = Read-Host "Do you want to check another remote computer? (Y/N)"
} while ($checkAnother -eq 'Y')
cls
}

$PVcheck = {
    cls
    Write-Host " "
    Write-Host "------------------------------------------------------------------------------------------------"
    Write-Host " "
    Write-Host "------------------------------------------------ "
    Write-Host "my Powershell Scripts - Physical or Virtual Check"
    Write-Host "------------------------------------------------ "
    Write-Host " "
    Write-Host "This script will check if the server is running in a virtual environment or on a physical server."
    Write-Host "You can check a single server or multiple servers."
    Write-Host "    If you check multiple servers, the script will use text file with server names"
    Write-Host "    and output the data to a CSV file."
    Write-Host "--------------------------------------------------------------------------------------------------"
    Write-Host " "
<# This script will check if the server is running in a virtual environment or on a physical server.
    The script will ask if you want to check a single server or multiple servers. If single, the user
    will enter the server's name into the console. If multiple servers, the script will use a text
    file and print the results to a CSV file. The script will then prompt the user to enter the path
    to the text file and a path where you want CSV file output. #>
    # Prompt the user to choose whether to check a single server or multiple servers
    $choice = Read-Host "Do you want to check a single server (S) or use a text file (F) to check multiple servers?"
    if ($choice -eq "S") {
        # Check a single server
        $serverName = Read-Host "Enter the name of the server you want to check"
        # Check for the presence of virtualization-specific properties
        $systemInfo = Get-WmiObject -ComputerName $serverName -Class Win32_ComputerSystem
        if ($systemInfo) {
            if ($systemInfo.Manufacturer -eq "Microsoft Corporation" -or $systemInfo.Model -like "*Virtual*") {
                Write-Host "Server '$serverName' is running on a virtual platform."
            } else {
                Write-Host "Server '$serverName' is running on physical hardware."
            }
        } else {
            Write-Host "Server '$serverName' not found or inaccessible."
        }
    }
    elseif ($choice -eq "F") {
        # Check multiple servers using a text file
        $textFilePath = Read-Host "Enter the path to the text file containing server names"
        $outputFilePath = Read-Host "Enter the path for the CSV output file"
        # Initialize an array to store results
        $results = @()
        # Read server names from the text file
        $servers = Get-Content $textFilePath
        foreach ($server in $servers) {
            $systemInfo = Get-WmiObject -ComputerName $server -Class Win32_ComputerSystem
            if ($systemInfo) {
                $isVirtual = if ($systemInfo.Manufacturer -eq "Microsoft Corporation" -or $systemInfo.Model -like "*Virtual*") {
                    "Virtual"
                } else {
                    "Physical"
                }
                $results += [PSCustomObject]@{
                    "ServerName" = $server
                    "Platform" = $isVirtual
                }
            } else {
                $results += [PSCustomObject]@{
                    "ServerName" = $server
                    "Platform" = "Not Found or Inaccessible"
                }
            }
        }
        # Export results to a CSV file
        $results | Export-Csv -Path $outputFilePath -NoTypeInformation
        Write-Host "Results have been exported to $outputFilePath."
    }
    else {
        Write-Host "Invalid choice. Please enter 'S' for a single server or 'F' for a text file."
    }
    Write-Host " "
    Write-Host " "
    Read-Host -Prompt "Press ENTER key to continue"
    cls
}

$OSCheck = {
    cls
    Write-Host " "
    Write-Host "------------------------------------------------------------------------------------------------"
    Write-Host " "
    Write-Host "------------------------------------------------ "
    Write-Host "my Powershell Scripts - OS Check"
    Write-Host "This script will check the OS version and it’s install date."
    Write-Host "------------------------------------------------------------------------------------------------"
    Write-Host " "
    # Script will check OS version and its Install date on the a local or remote computer.
    # Prompt user to choose between local or remote computer
    $choice = Read-Host "Do you want to check the local computer (press 'L') or a remote computer (press 'R')?"
    if ($choice -eq "L") {
        # Get computer information for the local machine
        $osInfo = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer
        $installDate = (Get-WmiObject Win32_OperatingSystem).InstallDate
    } elseif ($choice -eq "R") {
        # Prompt user for remote computer name
        $remoteComputer = Read-Host "Enter the name of the remote computer:"
        # Get computer information for the remote machine
        $osInfo = Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
            Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer
        }
        $installDate = Invoke-Command -ComputerName $remoteComputer -ScriptBlock {
            (Get-WmiObject Win32_OperatingSystem).InstallDate
        }
    } else {
        Write-Host "Invalid choice. Please press 'L' for local or 'R' for remote."
        Exit
    }
    # Convert installation date to readable format
    $installDate = [Management.ManagementDateTimeConverter]::ToDateTime($installDate)
    # Display selected OS details along with installation date
    Write-Host "Windows Product Name: $($osInfo.WindowsProductName)"
    Write-Host "Windows Version: $($osInfo.WindowsVersion)"
    Write-Host "OS Hardware Abstraction Layer: $($osInfo.OsHardwareAbstractionLayer)"
    Write-Host "Installation Date: $($installDate)"
    Write-Host " "
    Write-Host " "
    Read-Host -Prompt "Press ENTER key to continue"
    cls
}
$HDD_Check = {
    cls
<# This script will list all the HDDs of a server, if it's an SSD or a HDD, display total disk space,
    free disk space, and the partition type. It will display this to the console, then it will ask you if you want
    to check another server. #>
    Write-Host " "
    Write-Host "------------------------------------------------------------------------------------------------"
    Write-Host " "
    Write-Host "my Powershell Scripts - HDD Check"
    Write-Host "================================="
    Write-Host "This script will list all the HDD"
    Write-Host "of a server, the total Disk size, "
    Write-Host "Free space, and Partition Type.  "
    Write-Host "================================="
    Write-Host ""
    Write-Host "------------------------------------------------------------------------------------------------"
    Write-Host " "
<# This script will list all the server's HDD's, Total space
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
    cls
}
# Main Script
do {
Write-Host " "
Write-Host "====================="
Write-Host "my Powershell Scripts"
Write-Host "====================="
Write-Host "This script is designed for you to check any of the following:"
Write-Host " "
Write-Host "Physical or Virtual -   Checks If a server is a Physical Server or a virtual server."
Write-Host "OS Check –              Checks OS version and it’s install date."
Write-Host "HDD –                   Will list all Hard drives, Disk size, Free space, and Partition Type."
Write-Host "Uptime -                Checks server's uptime, last reboot, and if a reboot is Pending"
Write-Host "------------------------------------------------------------------------------------------------"
Write-Host " "
Write-Host "Press 1 to check if a server is Physical or Virtual"
Write-Host "Press 2 to check the OS of a server"
Write-Host "Press 3 to check the Server's HDD"
Write-Host "Press 4 to check the Uptime of a server"
$input = Read-Host "Enter your choice (1/2/3/4), or 'q' to quit"
switch ($input) {
    '1' { & $PVcheck }
    '2' { & $OSCheck }
    '3' { & $HDD_Check }
    '4' { & $UpTIME } # Adding the new choice for Uptime check
    'q' { break }
    default { Write-Host "Invalid choice. Please enter 1, 2, 3, 4, or 'q' to quit" }
}
} while ($input -ne 'q')