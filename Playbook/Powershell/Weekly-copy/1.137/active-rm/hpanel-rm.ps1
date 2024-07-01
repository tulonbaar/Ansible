﻿# Remove: 
# Older than: 1 month
# If less than 2 folders don't remove

# Specify the path where the directories are located
$path = "X:\Hpanel\"

# Get all the directories in the specified path that match the date format YYYYMMDD
$directories = Get-ChildItem -Path $path -Directory | Where-Object {
    $_.Name -match '^\d{4}(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])$'
}

# Check if there are any directories that match the criteria
if ($directories.Count -gt 0) {
    # Check if the total count of directories is less than 2
    if ($directories.Count -lt 2) {
        Write-Output "Total directory count is less than 2. No directories will be removed."
        return
    }

    # Find the oldest directory based on the directory name (interpreted as a date)
    $oldestDirectory = $directories | Sort-Object { [datetime]::ParseExact($_.Name, "yyyyMMdd", $null) } | Select-Object -First 1

    # Calculate the date 2 months ago from today
    $twoMonthsAgo = (Get-Date).AddMonths(-1)

    # Parse the date of the oldest directory
    $oldestDirectoryDate = [datetime]::ParseExact($oldestDirectory.Name, "yyyyMMdd", $null)

    # Check if the oldest directory is older than 1 month
    if ($oldestDirectoryDate -lt $twoMonthsAgo) {
        # Remove the oldest directory and its contents
        Remove-Item -Path $oldestDirectory.FullName -Recurse -Force

        Write-Output "The oldest directory ($($oldestDirectory.Name)) has been removed."
    } else {
        Write-Output "The oldest directory ($($oldestDirectory.Name)) is less than 1 month old and will not be removed."
    }
} else {
    Write-Output "No directories found in the specified path that match the date format YYYYMMDD."
}