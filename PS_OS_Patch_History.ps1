cls

<# This script attempts to list all installed Microsoft OS patches.
It looks for Cumulative Update for Windows, Security Update for Windows,
and Servicing Stack Update for Windows. It also attempts to look for the
Update patches, described as just "Update" from a Get-Hotfix.

The script will also ask if you want to check the Local computer or a Remote computer.

My Rant.. There is no reason for Microsoft to have made it so difficult to pull patch
history from a computer through Powershell without needing to install other modules.
SHAME ON YOU MICROSOFT!
#>

Write-Host " "
Write-Host "================================================="
Write-Host "Installed Microsoft Patches"
Write-Host "================================================="
Write-Host " "

# Define a hash table for result code mapping
$ResultCodeMapping = @{
    2 = "Succeeded"
    3 = "Succeeded With Errors"
    4 = "Failed"
}

# Function to convert result code to name
function Convert-WuaResultCodeToName {
    param([Parameter(Mandatory=$true)][int] $ResultCode)
    return $ResultCodeMapping[$ResultCode]
}

# Function to get WUA history
function Get-WuaHistory {
    # Get a WUA Session
    $session = New-Object -ComObject 'Microsoft.Update.Session'
    
    # Query the latest 1000 History starting with the first record
    $session.QueryHistory("",0,1000) | ForEach-Object {
        # Convert result code to name
        $Result = Convert-WuaResultCodeToName -ResultCode $_.ResultCode
        
        # Get Product name
        $Product = ($_.Categories | Where-Object {$_.Type -eq 'Product'} | Select-Object -First 1 -ExpandProperty Name)
        
        # Add custom properties
        $_ | Add-Member -MemberType NoteProperty -Value $Result -Name Result
        $_ | Add-Member -MemberType NoteProperty -Value $Product -Name Product -PassThru
    } | Where-Object { -not [string]::IsNullOrWhiteSpace($_.title) } | 
    Select-Object Result, Date, Title, SupportUrl
}

# Function to get computer name and OS install date
function Get-ComputerInfo {
    $computerName = $env:COMPUTERNAME
    $osInstallDate = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty InstallDate
    $formattedInstallDate = [Management.ManagementDateTimeConverter]::ToDateTime($osInstallDate)
    
    Write-Host "Computer Name: $computerName"
    Write-Host "OS Install Date: $formattedInstallDate"
}

# Ask the user for input to check local or remote computer
Write-Host "Type" -NoNewline
Write-Host " L" -ForegroundColor Yellow -NoNewline
Write-Host " to check the local computer or" -NoNewline
Write-Host " R" -ForegroundColor Yellow -NoNewline
Write-Host " to check a remote computer."

$choice = Read-Host "Enter your choice (L/R):"

if ($choice -eq 'L' -or $choice -eq 'l') {
    # Display computer name and OS install date for local computer
    Get-ComputerInfo
    
    # Get WUA history for local computer
    $wuaHistory = Get-WuaHistory
    $wuaHistory | Where-Object { $_.Title -like '*Cumulative Update for Windows*' -or 
                                 $_.Title -like '*Security Update for Windows*' -or
                                 $_.Title -like '*Servicing Stack Update for Windows*' } |
    Format-Table
    
    # Get hotfixes for local computer
    $hotfixes = Get-HotFix
    $hotfixes | Where-Object { $_.Description -like 'Update' } |
    Format-Table
}
elseif ($choice -eq 'R' -or $choice -eq 'r') {
    # Ask for the remote computer name
    $remoteComputer = Read-Host "Enter the name of the remote computer:"
    
    # Display computer name and OS install date for remote computer
    Invoke-Command -ComputerName $remoteComputer -ScriptBlock { Get-ComputerInfo }
    
    # Get WUA history for remote computer
    $wuaHistory = Invoke-Command -ComputerName $remoteComputer -ScriptBlock { Get-WuaHistory }
    $wuaHistory | Where-Object { $_.Title -like '*Cumulative Update for Windows*' -or 
                                 $_.Title -like '*Security Update for Windows*' -or
                                 $_.Title -like '*Servicing Stack Update for Windows*' } |
    Format-Table
    
    # Get hotfixes for remote computer
    $hotfixes = Invoke-Command -ComputerName $remoteComputer -ScriptBlock { Get-HotFix }
    $hotfixes | Where-Object { $_.Description -like 'Update' } |
    Format-Table
}
else {
    Write-Host "Invalid choice. Please type either L or R." -ForegroundColor Red
}
