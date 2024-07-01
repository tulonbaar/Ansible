# Check if the X: drive is already mapped
if (-not (Get-PSDrive X -ErrorAction SilentlyContinue)) {
    # If the X: drive is not present, map it
    try {
        New-PSDrive -Name X -PSProvider FileSystem -Root "\\<IP>\kopia" -Credential (New-Object System.Management.Automation.PSCredential("login", (ConvertTo-SecureString "password" -AsPlainText -Force)))
        Write-Output "Drive X: has been successfully mapped."
    } catch {
        Write-Error "An error occurred while trying to map drive X:."
    }
} else {
    Write-Output "Drive X: is already mapped."
}

# Define source and destination paths
$sourcePath = "L:\ARCHIVELOGS_HARTERP"
$currentDate = Get-Date -Format "yyyyMMdd"
$destinationPath = "X:\Oracle\$currentDate\ARCHIVELOGS_HARTERP"

# Define time range
$startTime = (Get-Date).AddDays(-1).Date.AddHours(21) # 21:00 Yesterday
$endTime = (Get-Date).Date.AddHours(1) # 01:00 Today

# Check if the destination directory exists, if not, create it
if (-not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath
    Write-Host "Destination directory created: $destinationPath"
} else {
    Write-Host "Destination directory already exists."
}

# Get files created between 21:00 yesterday and 01:00 today
$filesToCopy = Get-ChildItem -Path $sourcePath | Where-Object { $_.CreationTime -ge $startTime -and $_.CreationTime -le $endTime }

# Copy the selected files to the destination directory
foreach ($file in $filesToCopy) {
    $sourceFile = Join-Path -Path $sourcePath -ChildPath $file.Name
    $destinationFile = Join-Path -Path $destinationPath -ChildPath $file.Name
    Copy-Item -Path $sourceFile -Destination $destinationFile
    Write-Host "Copied file: $($file.Name)"
}

Write-Host "Files created between 21:00 yesterday and 01:00 today have been copied successfully."