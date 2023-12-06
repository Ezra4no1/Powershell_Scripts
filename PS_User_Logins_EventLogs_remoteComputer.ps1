<# This script will pull Log-ins to the server from the Event Logs, EventID 4624 #>
cls

Write-Host "********************************************************************"
Write-Host "This script will pull Log-ins of a remote server from the Event Logs"
Write-Host "********************************************************************"
write-Host " "

# Prompt user for the remote computer name
$remoteComputer = Read-Host -Prompt "Enter the name of the remote computer"

# Define the log name for security events
$logName = "Security"

# Get security events related to user logins on the remote computer
$events = Get-WinEvent -ComputerName $remoteComputer -LogName $logName -FilterXPath "*[System[(EventID=4624)]]" -MaxEvents 1000

# Create an array to store user login information
$loginInfo = @()

# Iterate through each event and extract relevant information
foreach ($event in $events) {
    $properties = [ordered]@{
        'Time'       = $event.TimeCreated
        'User'       = $event.Properties[5].Value
        'LogonType'  = $event.Properties[8].Value
        'IPAddress'  = $event.Properties[18].Value
        'Computer'   = $event.MachineName
    }

    $loginInfo += New-Object PSObject -Property $properties
}

# Export the information to a CSV file
$csvPath = "C:\Temp\UserLogins_$remoteComputer.csv"
$loginInfo | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "User login information exported to: $csvPath"
