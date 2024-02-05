cls

<# 
This script will check multiple servers from a text file for a specific KB Hotfix.
Adjust your input and output paths to your needs.
When the script runs, it will ask the user to enter the KB Hotfix number.
The KB Hotfix number can be entered as KBNUMBER, ex. KB2919355
#>

# Ask the user for the KBHotfix ID
$kbHotfixId = Read-Host "Please enter the KBHotfix ID"

# Read server names from a text file
$servers = Get-Content "path\to\your\server_list.txt"

# Prepare the CSV file
$results = @()

# Loop through each server
foreach ($server in $servers) {
    # Check if the hotfix is installed
    $hotfix = Get-HotFix -Id $kbHotfixId -ComputerName $server -ErrorAction SilentlyContinue

    if ($hotfix) {
        $status = "Installed"
    } else {
        $status = "Not Installed"
    }

    # Add the result to the results array
    $results += [PSCustomObject]@{
        Server   = $server
        KBHotfix = $kbHotfixId
        Status   = $status
    }

    # Print the number of servers left
    $remainingServers = $servers.Count - $results.Count
    Write-Host "$remainingServers servers left to check"

    # Optional delay to reduce load on network (remove or adjust as needed)
    Start-Sleep -Seconds 1
}

# Export the results to a CSV file
$results | Export-Csv "path\to\your\output.csv" -NoTypeInformation

# Print completion message
Write-Host "Check complete. Results have been saved to path\to\your\output.csv"
