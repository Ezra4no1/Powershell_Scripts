<# This script is design to run on Powershel ISE, as it will send it's output to Gridview.
This script will get a list of installed programs from either the local comptuer or a remote computer #>

cls
Write-Host " "
Write-Host "============================================================"
Write-Host "This script will get a list of installed programs from"
write-Host "either the local comptuer or a remote computer and send it's"
Write-Host "output to a Grid-View."
Write-Host "============================================================"
Write-Host " "

# Ask the user to choose between Local (L) or Remote (R) computer
$userChoice = Read-Host "Press 'L' to check the local computer or 'R' to check a remote computer"

# Function to get installed programs
function Get-InstalledPrograms {
    param (
        [string]$computerName
    )
    Get-WmiObject -Class Win32_Product -ComputerName $computerName | 
    Select-Object Name, Version, Vendor | 
    Out-GridView
}

# Execute based on user's choice
switch ($userChoice.ToUpper()) {
    "L" {
        # Local computer
        Get-InstalledPrograms -computerName "localhost"
    }
    "R" {
        # Remote computer
        $remoteComputerName = Read-Host "Enter the name of the remote computer"
        Get-InstalledPrograms -computerName $remoteComputerName
    }
    default {
        Write-Host "Invalid choice. Please enter 'L' or 'R'."
    }
}
