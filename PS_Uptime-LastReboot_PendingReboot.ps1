<# This script will check the Uptime, Last Reboot, and if there is a pending reboot waiting.
It will ask if you want to check Local or Remote. #>

CLS

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

    # Display information for local computer
    $uptimeMessage
    $lastRebootMessage
    $pendingRebootMessage
} elseif ($choice -eq 'R') {
    # Get the remote computer name from the user
    $remoteComputer = Read-Host "Enter the name of the remote computer"

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

    # Display information for remote computer
    $uptimeMessage
    $lastRebootMessage
    $pendingRebootMessage
} else {
    Write-Host "Invalid choice. Please enter 'L' for local or 'R' for remote."
}
