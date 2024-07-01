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
$sourcePath = "L:\RMAN_BACKUP_ERPARCH"
$currentDate = Get-Date -Format "yyyyMMdd"
$destinationPath = "X:\Oracle\$currentDate\RMAN_BACKUP_ERPARCH"

# Check if the destination directory exists, if not, create it
if (-not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath
    Write-Host "Destination directory created: $destinationPath"
} else {
    Write-Host "Destination directory already exists."
}

# Get the 7 newest files from the source directory
$newestFiles = Get-ChildItem -Path $sourcePath | Sort-Object LastWriteTime -Descending | Select-Object -First 7

foreach ($file in $newestFiles) {
    $sourceFile = $file.FullName
    $destinationFile = $destinationPath
    Copy-Item -Path $sourceFile -Destination $destinationFile
    Write-Host "Copied file: $($file.Name)"
}

Write-Host "7 newest files have been copied successfully."