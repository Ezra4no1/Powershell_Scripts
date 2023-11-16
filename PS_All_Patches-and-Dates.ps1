<# This script will list all patches and the dates they were installed.
 Script will ask if they want to check the local computer or a remote computer.
 It will than output to the Grid-View, than ask if they want to export the data to an HTML or CSV file.
 It will then ask the user if they want to run the script again. #>

function Get-UpdatesInfo {
    param (
        [string]$computerName
    )

    $Session = New-Object -ComObject "Microsoft.Update.Session"
    $Searcher = $Session.CreateUpdateSearcher()
    $HistoryCount = $Searcher.GetTotalHistoryCount()

    $Updates = $Searcher.QueryHistory(0, $HistoryCount) | Where-Object { $_.ResultCode -eq 2 } | Select-Object Title, Date

    $Updates | Out-GridView -Title "Updates on $computerName"

    $exportChoice = Read-Host "Do you want to export this data? (Y/N)"
    if ($exportChoice.ToLower() -eq "y") {
        $formatChoice = Read-Host "Enter 'H' for HTML format or 'C' for CSV format"
        $fileName = "$computerName Updates $(Get-Date -Format 'yyyy-MM-dd')"
        $exportPath = [Environment]::GetFolderPath("Desktop")
        
        if ($formatChoice.ToLower() -eq "h") {
            $Updates | ConvertTo-Html | Out-File -FilePath "$exportPath\$fileName.html"
            Write-Host "HTML file exported to $exportPath\$fileName.html"
        } elseif ($formatChoice.ToLower() -eq "c") {
            $Updates | Export-Csv -Path "$exportPath\$fileName.csv" -NoTypeInformation
            Write-Host "CSV file exported to $exportPath\$fileName.csv"
        } else {
            Write-Host "Invalid format choice. Export canceled."
        }
    } else {
        Write-Host "Export canceled."
    }

    $checkAnother = Read-Host "Do you want to check another computer? (Y/N)"
    if ($checkAnother.ToLower() -eq "y") {
        Get-Updates
    }
}

function Get-Updates {
    $locationChoice = Read-Host "Do you want to check the local computer (L) or a remote computer (R)?"

    if ($locationChoice.ToLower() -eq "l") {
        Get-UpdatesInfo -computerName $env:COMPUTERNAME
    } elseif ($locationChoice.ToLower() -eq "r") {
        $remoteComputer = Read-Host "Enter the name of the remote computer to check"
        Get-UpdatesInfo -computerName $remoteComputer
    } else {
        Write-Host "Invalid choice."
    }
}

Get-Updates
