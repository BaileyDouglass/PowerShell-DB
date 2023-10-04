# Read the template file into an array, one line at a time
$topic_template = Get-Content ".\topic_template.txt"

# Initialize hashtables and variables
$missingAttributes = @{}
$extraAttributes = @{}
$weirdCharFiles = @{}
$status = "ERROR"
$allowedChars = '^[a-zA-Z0-9\s\p{P}]+$'
$fail = "$([char]0x1b)[1;4;31mFAILED!"
$warn = "$([char]0x1b)[33mWARNING!"
$pass = "$([char]0x1b)[1;4;32mPASSED!"

# Function to check for weird characters in files
function CheckFileContent($filePath) {
    $content = Get-Content $filePath
    if ($content -notmatch $allowedChars) {
        return $true
    }
    return $false
}

# Main Logic
Get-ChildItem -Directory | ForEach-Object {
    $dir = $_.Name
    $missingFiles = @()
    $extraneousFiles = @()
    $filesWithWeirdChars = @()

    # Missing and extra files check
    $existingFiles = Get-ChildItem -Path $dir -File
    $missingFiles = $topic_template | Where-Object { $_ -notin $existingFiles.Name }
    $extraneousFiles = $existingFiles.Name | Where-Object { $_ -notin $topic_template }
    
    # Check for weird characters
    $existingFiles | ForEach-Object {
        $filePath = "$dir\$($_.Name)"
        if ((CheckFileContent $filePath) -eq $true) {
            $filesWithWeirdChars += $_.Name
        }
    }

    # Store issues
    if ($missingFiles) { $missingAttributes[$dir] = $missingFiles -join ', ' }
    if ($extraneousFiles) { $extraAttributes[$dir] = $extraneousFiles -join ', ' }
    if ($filesWithWeirdChars) { $weirdCharFiles[$dir] = $filesWithWeirdChars -join ', ' }
}

# Output Results
if ($missingAttributes.Count -eq 0) { 
    Write-Host "$([char]0x1b)[2mNo missing attributes..  $([char]0x1b)[32mok$([char]0x1b)[0m"
} else {
    Write-Host "$([char]0x1b)[1;4;31mTopics missing attributes$([char]0x1b)[0m:" 
    $missingAttributes.GetEnumerator() | ForEach-Object { Write-Host "  - $([char]0x1b)[4m$($_.Key)$([char]0x1b)[0m: [$([char]0x1b)[31m$($_.Value)$([char]0x1b)[0m]" }
    $status = $fail
}

if ($extraAttributes.Count -eq 0) { 
    Write-Host "$([char]0x1b)[2mNo extra attributes..    $([char]0x1b)[32mok$([char]0x1b)[0m"
} else { 
    Write-Host "$([char]0x1b)[2;33mTopics with extra files:"
    $extraAttributes.GetEnumerator() | ForEach-Object { Write-Host "  - $([char]0x1b)[4m$($_.Key)$([char]0x1b)[0m: [$([char]0x1b)[33m$($_.Value)$([char]0x1b)[0m]" }
    if ($status -ne $fail) { $status = $warn }
}

if ($weirdCharFiles.Count -eq 0) { 
    Write-Host "$([char]0x1b)[2mNo weird attributes..    $([char]0x1b)[32mok$([char]0x1b)[0m"
} else {
    Write-Host "$([char]0x1b)[2;31mTopics with files containing weird characters:"
    $weirdCharFiles.GetEnumerator() | ForEach-Object { Write-Host "  - $([char]0x1b)[4m$($_.Key)$([char]0x1b)[0m: [$([char]0x1b)[31m$($_.Value)$([char]0x1b)[0m]" }
    $status = $fail
}

# Check if any issues were found, if not status remains OK
if ($missingAttributes.Count -eq 0 -and $extraAttributes.Count -eq 0 -and $weirdCharFiles.Count -eq 0) {
    $status = $pass
}

Write-Host "Status: $status"
