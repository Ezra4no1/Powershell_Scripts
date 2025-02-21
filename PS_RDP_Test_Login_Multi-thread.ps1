<#
.SYNOPSIS
    This script tests Remote Desktop Protocol (RDP) connectivity and login status for a list of servers.

.DESCRIPTION
    - Reads a list of servers from a user input box or a text file.
    - Uses multi-threading (runspaces) to efficiently test multiple servers in parallel.
    - Checks server reachability using a ping test.
    - Tests if RDP (port 3389) is enabled on each server.
    - Attempts to log in using user-provided credentials via PowerShell remoting.
    - Logs results including server status, RDP availability, and login success or failure.
    - Outputs results to both CSV and Excel files.
    - Provides real-time progress updates in the console.
    - Includes error handling for module imports, file access, and connectivity issues.
#>



cls
Write-Host "RDP \ Login test"

# Define Paths
$ServerListPath = "C:\Windows\Temp\servers.txt"
$OutputExcel = "C:\Windows\Temp\RDP_Test_Results.xlsx"
$TempCSV = "C:\Windows\Temp\RDP_Temp_Results.csv"
$TimeoutSeconds = 15  # Timeout for each connection attempt
 
# Import Required Modules
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    try {
        Install-Module -Name ImportExcel -Force -Scope CurrentUser -ErrorAction Stop
    } catch {
        Write-Host "Failed to install ImportExcel module! Exiting..." -ForegroundColor Red
        exit
    }
}
 
try {
    Import-Module ImportExcel -ErrorAction Stop
} catch {
    Write-Host "Failed to import ImportExcel module! Exiting..." -ForegroundColor Red
    exit
}
 
# Prompt user for credentials once
$Credential = Get-Credential -Message "Enter credentials for RDP login attempts"
 
# Function to check if the Excel file is open
function Test-FileLock {
    param ($Path)
    try {
        $FileStream = [System.IO.File]::Open($Path, 'Open', 'Write')
        $FileStream.Close()
        return $false
    } catch {
        return $true
    }
}
 
# Remove any previous temp CSV file
if (Test-Path $TempCSV) { Remove-Item $TempCSV -Force }
 
# Prompt User for Input Method
$UserChoice = Read-Host "Enter [1] for Input Box or [2] for Text File"
 
if ($UserChoice -eq "1") {
    Add-Type -AssemblyName System.Windows.Forms
    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = "Enter Server Names"
    $Form.Size = New-Object System.Drawing.Size(300,400)
    $TextBox = New-Object System.Windows.Forms.TextBox
    $TextBox.Multiline = $true
    $TextBox.Size = New-Object System.Drawing.Size(260,300)
    $TextBox.Location = New-Object System.Drawing.Point(10,10)
    $Button = New-Object System.Windows.Forms.Button
    $Button.Text = "OK"
    $Button.Location = New-Object System.Drawing.Point(100,320)
    $Button.Add_Click({$Form.Close()})
    $Form.Controls.Add($TextBox)
    $Form.Controls.Add($Button)
    $Form.ShowDialog()
    $Servers = $TextBox.Text -split "`r`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
} elseif ($UserChoice -eq "2") {
    if (Test-Path $ServerListPath) {
        $Servers = Get-Content $ServerListPath
    } else {
        Write-Host "Server list file not found! Exiting..." -ForegroundColor Red
        exit
    }
} else {
    Write-Host "Invalid choice! Exiting..." -ForegroundColor Red
    exit
}
 
# Multi-threading Setup using Runspaces
$RunspacePool = [runspacefactory]::CreateRunspacePool(1, 50)
$RunspacePool.Open()
$Runspaces = @()
 
$ResultsQueue = [System.Collections.Concurrent.ConcurrentBag[PSCustomObject]]::new()
$TotalServers = $Servers.Count
$CompletedServers = 0
 
foreach ($Server in $Servers) {
    Write-Host "Starting test for server: $Server" -ForegroundColor Yellow
    $Runspace = [powershell]::Create().AddScript({
        param ($Server, $TimeoutSeconds, $Credential, $ResultsQueue)
 
        Write-Host "Checking connectivity to: $Server" -ForegroundColor Cyan
        $Result = [PSCustomObject]@{
            Server = $Server
            Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            Status = "Unknown"
            LoginStatus = "Not Attempted"
        }
 
        try {
            # Check if server is reachable with a timeout
            $Pingable = Test-Connection -ComputerName $Server -Count 1 -Quiet -ErrorAction Stop
            Start-Sleep -Seconds $TimeoutSeconds
            if (-not $Pingable) {
                Write-Host "Server unreachable: $Server" -ForegroundColor Red
                $Result.Status = "Unreachable"
            } else {
                # Check if RDP (Terminal Services) is enabled with timeout
                $RDPEnabled = Test-NetConnection -ComputerName $Server -Port 3389 -InformationLevel Quiet -ErrorAction Stop
                if (-not $RDPEnabled) {
                    Write-Host "RDP Disabled on: $Server" -ForegroundColor Red
                    $Result.Status = "RDP Disabled"
                } else {
                    Write-Host "RDP enabled, attempting login for: $Server" -ForegroundColor Cyan
                    try {
                        $LoginSuccess = Invoke-Command -ComputerName $Server -ScriptBlock { hostname } -Credential $Credential -ErrorAction Stop
                        if ($LoginSuccess) {
                            $Result.LoginStatus = "Success"
                        } else {
                            $Result.LoginStatus = "Failed"
                        }
                    } catch {
                        $Result.LoginStatus = "Failed"
                    }
                    $Result.Status = "RDP Enabled"
                }
            }
        } catch {
            Write-Host "Unexpected error for: $Server - $_" -ForegroundColor Red
            $Result.Status = "Error"
        }
 
        # Store result in queue
        $ResultsQueue.Add($Result)
 
    }).AddArgument($Server).AddArgument($TimeoutSeconds).AddArgument($Credential).AddArgument($ResultsQueue)
 
    $Runspace.RunspacePool = $RunspacePool
    $Runspaces += [PSCustomObject]@{
        Pipe = $Runspace
        Status = $Runspace.BeginInvoke()
    }
}
 
# Wait for all runspaces to complete
Write-Host "Waiting for all tasks to finish..." -ForegroundColor Cyan
while ($Runspaces.Status.IsCompleted -contains $false) {
    $CompletedServers = ($Runspaces | Where-Object { $_.Status.IsCompleted }).Count
    Write-Progress -Activity "Testing RDP Servers" -Status "$CompletedServers of $TotalServers completed" -PercentComplete (($CompletedServers / $TotalServers) * 100)
    Start-Sleep -Seconds 3
}
 
foreach ($Run in $Runspaces) {
    $Run.Pipe.EndInvoke($Run.Status)
    $Run.Pipe.Dispose()
}
 
# Convert queue to array for processing
$ResultsArray = $ResultsQueue.ToArray()
Write-Host "Total Results Collected: $($ResultsArray.Count)" -ForegroundColor Cyan
 
# Verify all servers are recorded
if ($ResultsArray.Count -eq 0) {
    Write-Host "No results captured! Excel export aborted." -ForegroundColor Red
    exit
}
 
# Export to CSV first for reliability
$ResultsArray | Export-Csv -Path $TempCSV -NoTypeInformation -Force
 
# Export to Excel with error handling
try {
    $ResultsArray | Export-Excel -Path $OutputExcel -WorksheetName "Results" -AutoSize
} catch {
    Write-Host "Error exporting to Excel: $_" -ForegroundColor Red
}
 
Write-Host "RDP Test Completed! Results saved to $OutputExcel" -ForegroundColor Green