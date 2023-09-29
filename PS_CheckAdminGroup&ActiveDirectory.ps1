CLS

# Script will connect to Remote Servers and get all the objects found in the Local Admin group.
# Than it will check in AD if the Object is found in AD, and if it is a User account or a Group.

# Specify the path to the text file containing the list of remote servers

$serverListFile = "C:\PATH_TO_LOCATION\PS_CheckAdminGroup&ActiveDirectory-INPUT.txt"

# Specify the output CSV file

$outputCSV = "C:\PATH_TO_LOCATION\PS_CheckAdminGroup&ActiveDirectory-OUTPUT.csv"

 

# Read the list of remote servers from the text file

$servers = Get-Content -Path $serverListFile

 

# Initialize an array to store the results

$results = @()

 

# Initialize a variable to keep track of the server count

$serverCount = $servers.Count

 

# Loop through each server in the list

foreach ($server in $servers) {

    Write-Host "Processing $server. Servers left: $serverCount"

   

    # Connect to the remote server (you may need to provide credentials)

    $session = New-PSSession -ComputerName $server

   

    # Get members of the local administrators group

    $localAdmins = Invoke-Command -Session $session -ScriptBlock {

        $group = [ADSI]"WinNT://./Administrators,group"

        $group.psbase.Invoke("Members") | ForEach-Object {

            $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)

        }

    }

   

    # Check each member in Active Directory

    foreach ($member in $localAdmins) {

        $adObject = Get-ADObject -Filter "SamAccountName -eq '$member'" -Properties ObjectClass

       

        if ($adObject) {

            $objectType = $adObject.ObjectClass

        } else {

            $objectType = "Not Found in AD"

        }

       

        # Add the result to the results array

        $results += [PSCustomObject]@{

            Server = $server

            Member = $member

            ObjectType = $objectType

        }

    }

   

    # Close the remote session

    Remove-PSSession -Session $session

   

    # Decrement the server count

    $serverCount--

}

 

# Export the results to a CSV file

$results | Export-Csv -Path $outputCSV -NoTypeInformation

 

Write-Host "Script completed. Results exported to $outputCSV"