#Set workpath in which script files are located
$workPath = "C:\Skrypty\Backup_w\2024"

#Always remember to set creds and copy files to active-cp/active-rm. This script only connects disks and starts further scripts, which are really doing all the work.

# Function to get credentials
function Get-CredentialsFromFile {
    param (
        [Parameter(Mandatory=$true)][string]$FilePath
    )
    $credsContent = Get-Content -Path $FilePath
    $username, $password = $credsContent -split ':'
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    return New-Object System.Management.Automation.PSCredential ($username, $securePassword)
}

# Function to unmount drives
function Unmount-Drives {
    param (
        [Parameter(Mandatory=$true)][string[]]$DriveLetters
    )
    foreach ($driveLetter in $DriveLetters) {
        try {
            # Attempt to remove the drive using PowerShell
            Remove-PSDrive -Name $driveLetter -Force -ErrorAction Stop
            Write-Host "Drive $driveLetter`: removed successfully."
        } catch {
            Write-Host "Failed to remove drive $driveLetter`: through PowerShell, attempting with net use."
            # If PowerShell removal fails, attempt with net use /delete
            net use "\\$driveLetter`:" /delete /y
        }
    }
}

# Ensure network locations are mapped with credentials from creds.key
# Order of disks must be correct in all three $networkPaths, $driveLetters, $driveLettersToUnmount

$networkPaths = @("\\<IP-SRC>\backup", "\\<IP-DST>\kopia")
$credsFilePath = "$workPath\creds.key" # Update this path to where your creds.key file is located
$credentials = Get-CredentialsFromFile -FilePath $credsFilePath

#Drives to mount
$driveLetters = @("Z", "X")

# Collect the drive letters for mapped drives to unmount later
$driveLettersToUnmount = @("Z", "X")

foreach ($path in $networkPaths) {
    $driveLetter = $driveLetters[$networkPaths.IndexOf($path)]

    if (!(Test-Path $path)) {
        Write-Host "Mapping network drive for $path"
        # Attempt to map the network drive with credentials
        try{
            New-PSDrive -Name $driveLetter -PSProvider "FileSystem" -Root $path -Credential $credentials -Persist
        }catch {
            Write-Host "Unable to map drive. Is it already mapped?"
        }
    }
}

# Manual run = Copy to this moment, and run script that copies files

# Scripts for deleting old items
# Check for scripts in ./active-rm and execute them
$scriptDirectory = "$workPath\active-rm"
$scriptFiles = Get-ChildItem -Path $scriptDirectory -Filter *.ps1

if ($scriptFiles.Count -eq 0) {
    Write-Host "No scripts found in $scriptDirectory"
    $emailBody = "No scripts were found in the ./active-rm folder. Operation was not successful."
} else {
    foreach ($file in $scriptFiles) {
        try {
            Write-Host "Executing script: $($file.FullName)"
            & $file.FullName
        } catch {
            Write-Host "Error executing script: $($file.FullName)"
            $emailBody = "An error occurred while executing the scripts. Please check the logs for more details."
            Send-Email -Body $emailBody
            exit
        }
    }
    $emailBody = "All scripts in the ./active-rm folder were executed successfully."
}

# Scripts for copying new ones
# Check for scripts in ./active and execute them
$scriptDirectory = "$workPath\active-cp"
$scriptFiles = Get-ChildItem -Path $scriptDirectory -Filter *.ps1

if ($scriptFiles.Count -eq 0) {
    Write-Host "No scripts found in $scriptDirectory"
    $emailBody = "No scripts were found in the ./active-cp folder. Operation was not successful."
} else {
    foreach ($file in $scriptFiles) {
        try {
            Write-Host "Executing script: $($file.FullName)"
            & $file.FullName
        } catch {
            Write-Host "Error executing script: $($file.FullName)"
            $emailBody = "An error occurred while executing the scripts. Please check the logs for more details."
            Send-Email -Body $emailBody
            exit
        }
    }
    $emailBody = "All scripts in the ./active-cp folder were executed successfully."
}



Unmount-Drives -DriveLetters $driveLettersToUnmount

# Function to send email
function Send-Email {
    param (
        [Parameter(Mandatory=$true)][string]$Body
    )
    $smtpServer = "smtp.server"
    $smtpFrom = "sender@email.com"
    $smtpTo = "recipent@email.com"
    $messageSubject = "PowerShell Script Execution Report"
    
    $message = New-Object System.Net.Mail.MailMessage $smtpFrom, $smtpTo
    $message.Subject = $messageSubject
    $message.Body = $Body
    
    $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
    $smtp.Send($message)
}

# Send email report
Send-Email -Body $emailBody