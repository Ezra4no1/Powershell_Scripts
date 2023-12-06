cls

<# This script will list active RDP sessions of a remote computer,
and will give an option to log-off an active RDP session on a remote 
computer. This is helpful when a session stays connected after a 
user has disconnected. #>

Write-Host " "
Write-Host "==================================================="
Write-Host " Display's active RDP session on a remote computer"
Write-Host " Log-off active RDP session on a remote computer"
Write-Host "==================================================="
Write-Host " "
Write-Host "Use the same Session ID of the active RDP connection" 
Write-Host "when specify the session to Log-off."

function Show-Menu {
    Write-Host "      *************************************"
    Write-Host "Press (1) to check RDP session of a remote computer."
    Write-Host "Press (2) to logoff a user logged in on a remote computer."
    Write-Host "Press (Q) to quit."
}
function Check-RDPSession {
    $remoteComputer = Read-Host "Enter the name of the remote computer:"
    Write-Host "--------------------------------------------------------"
    qwinsta /server:$remoteComputer
    Write-Host "--------------------------------------------------------"
    Write-Host " "
}
function Logoff-User {
    $remoteComputer = Read-Host "Enter the name of the remote computer:"
    $sessionId = Read-Host "Enter the session ID:"
    logoff $sessionId /server:$remoteComputer
    Write-Host "---==={ DONE } ===--- "
}
$quit = $false
while (-not $quit) {
    Show-Menu
    $choice = Read-Host "Enter your choice:"
    switch ($choice) {
        '1' {
            Check-RDPSession
        }
        '2' {
            Logoff-User
        }
        'Q' {
            $quit = $true
        }
        default {
            Write-Host "Invalid choice. Please try again."
        }
    }
}