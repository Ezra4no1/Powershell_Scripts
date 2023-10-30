CLS
<# This script will check if the sever is running in a virtual environment or on a physical server.
 Ths script will ask if y ou want to check a single server or multiple servers. If single the user
 will enter the server's name into the console. If mulltiple servers, the script will use a text
 file and print the results to a CSV file. The script will than prompt the user to enter the path
 to the text file and a path where you want csv file output. #>

# Prompt the user to choose whether to check a single server or multiple servers
$choice = Read-Host "Do you want to check a single server (S) or use a text file (F) to check multiple servers?"

if ($choice -eq "S") {
    # Check a single server
    $serverName = Read-Host "Enter the name of the server you want to check"

    # Check for the presence of virtualization-specific properties
    $systemInfo = Get-WmiObject -ComputerName $serverName -Class Win32_ComputerSystem

    if ($systemInfo) {
        if ($systemInfo.Manufacturer -eq "Microsoft Corporation" -or $systemInfo.Model -like "*Virtual*") {
            Write-Host "Server '$serverName' is running on a virtual platform."
        } else {
            Write-Host "Server '$serverName' is running on physical hardware."
        }
    } else {
        Write-Host "Server '$serverName' not found or inaccessible."
    }
}
elseif ($choice -eq "F") {
    # Check multiple servers using a text file
    $textFilePath = Read-Host "Enter the path to the text file containing server names"
    $outputFilePath = Read-Host "Enter the path for the CSV output file"

    # Initialize an array to store results
    $results = @()

    # Read server names from the text file
    $servers = Get-Content $textFilePath

    foreach ($server in $servers) {
        $systemInfo = Get-WmiObject -ComputerName $server -Class Win32_ComputerSystem

        if ($systemInfo) {
            $isVirtual = if ($systemInfo.Manufacturer -eq "Microsoft Corporation" -or $systemInfo.Model -like "*Virtual*") {
                "Virtual"
            } else {
                "Physical"
            }

            $results += [PSCustomObject]@{
                "ServerName" = $server
                "Platform" = $isVirtual
            }
        } else {
            $results += [PSCustomObject]@{
                "ServerName" = $server
                "Platform" = "Not Found or Inaccessible"
            }
        }
    }

    # Export results to a CSV file
    $results | Export-Csv -Path $outputFilePath -NoTypeInformation

    Write-Host "Results have been exported to $outputFilePath."
}
else {
    Write-Host "Invalid choice. Please enter 'S' for a single server or 'F' for a text file."
}
