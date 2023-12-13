cls
<# This script will get filtered system event logs for Critial, Error, and Warning alerts.
This script can take a while to complete, so give it 10 to 20 minuites if needed. 

The script will output the file to an Excel file, with the server's name and today's date.
It will import an excel module and will create the path for the output if one is not created,
or you can list the path you want the output to got to. #>
 
Install-Module -Name ImportExcel -Scope CurrentUser
 
Write-Host "* "
Write-Host "** "
Write-Host "*** "
Write-Host "**** "
Write-Host "***** "
Write-Host "This script will get System Even Logs from a remote computer"
Write-Host "and filter for Critical, Error, and Warning alerts"
Write-Host "and output to an Excel File"
Write-Host "***** "
Write-Host "**** "
Write-Host "*** "
Write-Host "** "
Write-Host "* "
Write-Host " "

# Prompt for the remote server name
$serverName = Read-Host "Enter the name of the remote server"

# Get today's date in yyyyMMdd format
$date = Get-Date -Format "yyyyMMdd"

# Define the Excel file path
$excelFilePath = "C:\temp\$serverName-$date.xlsx"

# Check if C:\temp directory exists, if not create it
if (-not (Test-Path -Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp"
}

# Load Excel module (Install-Module -Name ImportExcel if not already installed)
Import-Module ImportExcel

# Function to export logs or a placeholder if logs are empty
function Export-LogsOrPlaceholder {
    param(
        [string]$WorksheetName,
        [System.Collections.Generic.List[object]]$Logs
    )

    if ($Logs.Count -eq 0) {
        @{"Message" = "No Logs Found"} | Export-Excel -Path $excelFilePath -WorksheetName $WorksheetName -Append
    } else {
        $Logs | Export-Excel -Path $excelFilePath -WorksheetName $WorksheetName -Append
    }
}

# Get Event Logs from the remote server
$criticalAlerts = Get-WinEvent -ComputerName $serverName -FilterHashtable @{LogName='System'; Level=1} -ErrorAction SilentlyContinue
$errorAlerts = Get-WinEvent -ComputerName $serverName -FilterHashtable @{LogName='System'; Level=2} -ErrorAction SilentlyContinue
$warnings = Get-WinEvent -ComputerName $serverName -FilterHashtable @{LogName='System'; Level=3} -ErrorAction SilentlyContinue

# Export to Excel
Export-LogsOrPlaceholder -WorksheetName "Critical" -Logs $criticalAlerts
Export-LogsOrPlaceholder -WorksheetName "Error" -Logs $errorAlerts
Export-LogsOrPlaceholder -WorksheetName "Warning" -Logs $warnings

Write-Host "Export completed to $excelFilePath"
