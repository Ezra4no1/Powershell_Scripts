cls

# Script will check OS version and it's Install date on the a local or remote computer.

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
