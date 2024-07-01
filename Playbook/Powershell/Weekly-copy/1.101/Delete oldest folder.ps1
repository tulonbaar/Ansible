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

# Define the path
$path = "X:\Oracle\"

# Get all the folders in the specified path
$folders = Get-ChildItem -Path $path -Directory

# Check if the number of folders is greater than 4
if ($folders.Count -gt 4) {
    # Sort the folders by creation time in ascending order
    $oldestFolder = $folders | Sort-Object CreationTime | Select-Object -First 1

    # Remove the oldest folder with all its contents
    Remove-Item -Path $oldestFolder.FullName -Recurse -Force

    Write-Host "The oldest folder ($($oldestFolder.Name)) has been removed."
} else {
    Write-Host "There are 4 or fewer folders. No action is taken."
}