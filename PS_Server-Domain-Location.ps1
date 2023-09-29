CLS

<# This script will get the AD path of a server in AD. #>



# Define the path to the input text file containing server names (one per line)
$InputTextFile = "C:\PATH_TO_LOCATION\PS_Server-Domain-Location-Input.txt"

 

# Define the path to the output CSV file
$OutputCSVFile = "C:\PATH_TO_LOCATION\PS_Server-Domain-Location--Output.csv"

 

# Initialize a counter to keep track of processed servers
$ServerCount = 0

 

# Get the content of the input text file and loop through each server name
$ServerNames = Get-Content $InputTextFile
$TotalServers = $ServerNames.Count

 

# Create an array to store server information
$ServerInfoArray = @()

 

foreach ($ServerName in $ServerNames) {
    $ServerCount++
    Write-Host "Processing server $ServerCount of $TotalServers $ServerName"

    # Use Get-ADComputer to retrieve the Active Directory path of the server
    try {
        $ADComputer = Get-ADComputer -Filter {Name -eq $ServerName} -ErrorAction Stop
        $ADPath = $ADComputer.DistinguishedName
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        $ADPath = "Not Found"
    }

    # Create a custom object to store server information
    $ServerInfo = [PSCustomObject]@{
        ServerName = $ServerName
        ADPath = $ADPath
    }

    # Add the server information to the array
    $ServerInfoArray += $ServerInfo

 

    # Display a countdown of remaining servers
    $RemainingServers = $TotalServers - $ServerCount
    Write-Host "Remaining Servers: $RemainingServers"
}

 

# Export the server information to a CSV file
$ServerInfoArray | Export-Csv -Path $OutputCSVFile -NoTypeInformation

 

Write-Host "Script completed. Server information has been saved to $OutputCSVFile."