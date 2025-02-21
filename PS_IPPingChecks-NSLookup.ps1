<#
Script was written to check Rogue IPs found during scans.

.SYNOPSIS
This script checks server availability using Ping and optionally performs NSLOOKUP on IP addresses.

.DESCRIPTION
- Allows users to input server names via a text file or a manual entry input box.
- Tests if each server responds to a Ping request.
- Optionally performs an NSLOOKUP to resolve hostnames from IP addresses.
- Provides output in either Grid-View or a CSV file.
- Displays progress updates during execution.

.PARAMETER inputMethod
Determines how the server list is provided (1 for text file, 2 for manual entry).

.PARAMETER performNSLookup
User selection to perform NSLOOKUP (Y/N).

.PARAMETER outputChoice
User selection for output format (1 for Grid-View, 2 for CSV file).

.OUTPUTS
- Displays results in Grid-View or exports them to a CSV file.

.NOTES
- Requires administrative privileges if necessary.
- Uses the Resolve-DnsName cmdlet for NSLOOKUP functionality.
- Implements basic error handling for file existence and user input validation.

#>

# Function to check if a server responds to ping
function Test-Ping {
    param(
        [string]$server
    )
    $pingResult = Test-Connection -ComputerName $server -Count 1 -Quiet
    return $pingResult
}
 
# Function to perform NSLOOKUP using Resolve-DnsName
function Perform-NSLookup {
    param(
        [string]$ipAddress
    )
    try {
        $dnsResult = Resolve-DnsName -Name $ipAddress -ErrorAction Stop
        return $dnsResult.NameHost  # Returns the resolved hostname
    } catch {
        return "NSLOOKUP Failed"
    }
}
 
# Function to display an input box for multiple server entries
function Read-MultiLineInputBoxDialog {
    param (
        [string]$Message,
        [string]$WindowTitle
    )
 
    Add-Type -AssemblyName System.Windows.Forms
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $WindowTitle
    $form.Size = New-Object System.Drawing.Size(400, 400)
    $form.StartPosition = "CenterScreen"
 
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Message
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $form.Controls.Add($label)
 
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Size = New-Object System.Drawing.Size(360, 250)
    $textBox.Location = New-Object System.Drawing.Point(10, 30)
    $textBox.Multiline = $true
    $textBox.ScrollBars = "Both"
    $form.Controls.Add($textBox)
 
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Size = New-Object System.Drawing.Size(75, 25)
    $okButton.Location = New-Object System.Drawing.Point(150, 300)
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($okButton)
 
    $form.AcceptButton = $okButton
    if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $textBox.Text -split "`r`n" | Where-Object { $_ -match '\S' }  # Remove empty lines
    } else {
        return $null
    }
}
 
# Ask user for input method
$inputMethod = Read-Host "Enter 1 to use a text file or 2 to enter servers manually"
 
if ($inputMethod -eq "1") {
    $filePath = "C:\Users\OMH3674\OneDrive - Baylor Scott & White Health\myWork\myPS_Stuff\Ping-IP-Check-Only.csv"
 
    if (Test-Path $filePath) {
        $data = Import-Csv -Path $filePath
    } else {
        Write-Host "File not found! Exiting..." -ForegroundColor Red
        exit
    }
} elseif ($inputMethod -eq "2") {
    $serverList = Read-MultiLineInputBoxDialog -Message "Enter one server per line" -WindowTitle "Enter Servers"
 
    if ($serverList -eq $null -or $serverList.Count -eq 0) {
        Write-Host "No servers entered! Exiting..." -ForegroundColor Red
        exit
    }
 
    # Convert input to object array for consistency
    $data = foreach ($server in $serverList) {
        [PSCustomObject]@{
            Name = $server
            IP   = $server  # Assume the entered value is an IP or hostname
        }
    }
} else {
    Write-Host "Invalid selection! Exiting..." -ForegroundColor Red
    exit
}
 
# Ask user if they want to perform NSLOOKUP
$performNSLookup = Read-Host "Do you want to perform NSLOOKUP on IP addresses? (Y/N)"
 
# Ask user for output format
$outputChoice = Read-Host "Enter 1 for Grid-View or 2 for CSV output"
 
# Initialize an array to store results
$results = @()
 
# Process each server
$totalServers = $data.Count
$serverCounter = 1
 
foreach ($row in $data) {
    $serverName = $row.Name
    $serverIP = $row.IP
    $nslookupResult = "Not Performed"
 
    if ([string]::IsNullOrWhiteSpace($serverIP)) {
        # If IP address is not provided, mark as "No IP Address"
        $result = [PSCustomObject]@{
            ServerName   = $serverName
            IPAddress    = "No IP Address"
            PingResult   = "N/A"
            NSLookupName = "N/A"
        }
    } else {
        # Check if the server responds to ping
        $pingResult = Test-Ping -server $serverIP
 
        # Perform NSLOOKUP if user opted in
        if ($performNSLookup -match "^[Yy]$") {
            $nslookupResult = Perform-NSLookup -ipAddress $serverIP
        }
 
        # Add the result to the results array
        $result = [PSCustomObject]@{
            ServerName   = $serverName
            IPAddress    = $serverIP
            PingResult   = $pingResult
            NSLookupName = $nslookupResult
        }
    }
 
    # Add the result to the results array
    $results += $result
 
    # Display progress
    Write-Host "Checked server $serverCounter of $totalServers. Servers left: $($totalServers - $serverCounter)"
 
    # Increment counter
    $serverCounter++
}
 
# Output results
if ($outputChoice -eq "1") {
    $results | Out-GridView -Title "Ping & NSLOOKUP Results"
} elseif ($outputChoice -eq "2") {
    $outputPath = "C:\Users\OMH3674\OneDrive - Baylor Scott & White Health\myWork\myPS_Stuff\Ping-IP-Check-Only-output.csv"
    $results | Export-Csv -Path $outputPath -NoTypeInformation
    Write-Host "Results saved to $outputPath" -ForegroundColor Green
} else {
    Write-Host "Invalid selection! Exiting..." -ForegroundColor Red
}