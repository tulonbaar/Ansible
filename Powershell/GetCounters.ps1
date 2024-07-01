$executionTime = Measure-Command {

# PowerShell Script to Get MSSQL$<InstanceName> Counters, Output in JSON Format, and Save to a File

# Get all counters that start with "\MSSQL$<InstanceName>:"
$counterList = Get-Counter -ListSet * | Where-Object {$_.PathsWithInstances -like "\MSSQL`$<InstanceName>:*"}

# Initialize an array to hold the counter values
$counterValues = @()

# Loop through each counter in the list and get its value
foreach ($counter in $counterList) {
    foreach ($path in $counter.Paths) {
        # Use try-catch to ignore errors for specific counters
        try {
            
            #Get Counters
            $value = Get-Counter -Counter "$($path)" -ErrorAction Stop
            
            $colonIndex = $value.CounterSamples.Path.IndexOf(':')
            # Extract the substring from the character after the colon to the end
            $modifiedCounterName = $value.CounterSamples.Path.Substring($colonIndex + 1)

            # Optionally, remove "\\dynamsql-os126\\" from the CounterName
            $modifiedCounterName = $modifiedCounterName -replace '\\\\<Hostname>\\', ''
            
            
            #Patterns to change (*) -> (counterTag)
            $regexpattern = '\((.*?)\)'
            $placeholderPattern = '\(\*\)'

            for(($i = 0), ($j = 0); $i -lt $modifiedCounterName.Count; $i++)
            {
                $counterTag = $null
                if ($modifiedCounterName[$i] -match $regexpattern) {
                    $counterTag = $matches[1]
                } else {
                    Write-Host "No match found - $($modifiedCounterName[$i])"
                    $counterTag = "*"
                }

                $obj = New-Object PSObject -Property @{

                    CounterName = $modifiedCounterName[$i]
                    CounterValue = $value.CounterSamples.CookedValue[$i]
                    CounterPath = $counter.Paths[$i] -replace $placeholderPattern, "($counterTag)"
                    CounterDescription = $counter.Description
                    CounterId = $modifiedCounterName[$i] -replace 'mssql$<InstanceName>:', ''
                    CounterTag = $counterTag
                    CounterNo = $i
                }
                $counterValues += $obj
            }           
        } catch {
            # Optionally, log or output error information
            Write-Host "Error retrieving counter: $path. Error: $_"
        }
    }
}

# Convert the array of counter values to JSON format
$jsonOutput = $counterValues | ConvertTo-Json -Depth 10

$jsonOutput = $jsonOutput.Replace("\u003c", "<")
$jsonOutput = $jsonOutput.Replace("\u003e", ">")
$jsonOutput = $jsonOutput.Replace("\u0026", "&")
$jsonOutput = $jsonOutput.Replace("\u0027", "'")

$jsonOutput = $jsonOutput.Replace("\\", "`\")
$jsonOutput = $jsonOutput.Replace("mssql`$<InstanceName>:", "")

# Save the JSON output to a file named json.json on the C: drive
$jsonOutput | Out-File -FilePath "C:\json.json"

# Optionally, display a message indicating completion
Write-Host "JSON output saved to C:\json.json"
}

Write-Host "Total execution time: $($executionTime.TotalMilliseconds) ms"


