<# Script will get a server's Distinguished Name and Path from Active Directory 
    Script was set up for Block Scripts #>
    
cls
 
# Define the script block and assign it to the variable 'ServerADPath'
$ServerADPath = {
    # Import Active Directory module
    Import-Module ActiveDirectory
    # Ask the user for the server name
    $serverName = Read-Host -Prompt "Enter the name of the server"
    # Search Active Directory for the server
    try {
        $server = Get-ADComputer -Identity $serverName -Properties *
        if ($server -ne $null) {
            # Output the distinguished name (path) of the server
            Write-Host " "
            Write-Host "Server: $serverName"         
            Write-Host "Distinguished Name: $($server.DistinguishedName)"
            # Extract each part of the distinguished name and reverse the array
            $dnParts = ($server.DistinguishedName -split "," | ForEach-Object { $_ -replace "CN=","" -replace "OU=","" -replace "DC=","" }) -join "\"
            # Create the full path
            $fullPath = $dnParts -replace '\\','\'
            # Output the full path
            Write-Host "Path: $fullPath"
            Write-Host " "
 
        } else {
            Write-Host "Server not found in Active Directory."
        }
    } catch {
        Write-Host "Error occurred: $_"
    }
}
# To execute the script block, you can call it like this:
& $ServerADPath
