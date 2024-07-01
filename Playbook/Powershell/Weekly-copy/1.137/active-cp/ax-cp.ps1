# AX.ps1
$currentDate = Get-Date -Format "yyyyMMdd"

$sourcePath = "Z:\AX\" # Update this with your actual source folder path
$destinationPath = "X:\AX\$currentDate\" # Update this with your actual destination folder path

# Ensure the destination directory exists; if not, create it
if (-not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath
}

# Copy items from source to destination with detailed logging
Get-ChildItem -Path $sourcePath -Recurse | ForEach-Object {
    $sourceFile = $_
    $destinationFile = $sourceFile.FullName.Replace($sourcePath, $destinationPath)
    
    # Ensure destination directory exists for the current file
    $destinationDir = [System.IO.Path]::GetDirectoryName($destinationFile)
    if (-not (Test-Path -Path $destinationDir)) {
        New-Item -ItemType Directory -Path $destinationDir
    }
    
    # Check if the destination file already exists; if not, copy the file
    if (-not (Test-Path -Path $destinationFile)) {
        try {
            Copy-Item -Path $sourceFile.FullName -Destination $destinationFile -Force
            Write-Host "Copied: $($sourceFile.FullName) to $destinationFile"
        } catch {
            Write-Host "Failed to copy: $($sourceFile.FullName) to $destinationFile. Error: $_"
        }
    } else {
        Write-Host "Skipped: $destinationFile already exists."
    }
}