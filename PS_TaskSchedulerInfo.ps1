CLS

# Script will check servers from a text file and list all the scheduled tasks and their descriptions
# and exports the results to a CSV file.

# Specify the path to the text file containing server names

$ServerListPath = "C:\PATH_TO_LOCATION\PS_TaskSchedulerInfo-INPUT.txt"

 

# Specify the path for the CSV output file

$OutputCSVPath = "C:\PATH_TO_LOCATION\PS_TaskSchedulerInfo-OUTPUT.csv"

 

# Read the list of server names from the text file

$ServerNames = Get-Content -Path $ServerListPath

 

# Initialize a counter for the total number of servers

$TotalServers = $ServerNames.Count

 

# Create an empty array to store the results

$Results = @()

 

# Loop through each server name and query Task Scheduler

foreach ($ServerName in $ServerNames) {

    # Decrement the total server count

    $TotalServers--

 

    # Display a countdown

    Write-Host "Checking server: $ServerName ($TotalServers servers left)"

 

    # Query Task Scheduler on the remote server

    $ScheduledTasks = Invoke-Command -ComputerName $ServerName -ScriptBlock {

        Get-ScheduledTask | Select-Object TaskName, Description

    }

 

    # Add the results to the array

    foreach ($Task in $ScheduledTasks) {

        $Result = [PSCustomObject]@{

            ServerName  = $ServerName

            TaskName    = $Task.TaskName

            Description = $Task.Description

        }

        $Results += $Result

    }

}

 

# Export the results to a CSV file

$Results | Export-Csv -Path $OutputCSVPath -NoTypeInformation

 

# Display a completion message

Write-Host "Task completed. Results exported to $OutputCSVPath"

 