param (
    [Parameter(Mandatory=$true)]
    [string]$topic_name
)
function Format-TopicName {
    param (
        [Parameter(Mandatory=$true)]
        [string]$inputString
    )

    # Capitalize the first letter of each word
    $capitalizedString = ($inputString -split ' ').ForEach({ $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() }) -join ' '

    # Replace spaces with a single hyphen
    $formattedString = $capitalizedString -replace ' ', '-'

    return $formattedString
}
$formattedName = Format-TopicName -inputString $topic_name

# Check if the given topic directory exists
$dir = $formattedName
if (-Not (Test-Path $dir -PathType Container)) {
    Write-Host "The specified topic directory does not exist."
    exit
}

# Read the template file into an array, one line at a time
$topic_template = Get-Content ".\topic_template.txt"

Write-Host "`nProcessing topic: $([char]0x1b)[1;4;36m$dir$([char]0x1b)[0m"

# Check for each attribute (file) from the template
foreach ($attribute in $topic_template) {
    $attributePath = "$dir\$attribute"

    if (Test-Path $attributePath) {
        # If the file exists, load its content
        $content = Get-Content $attributePath
        Write-Host "Existing content of $([char]0x1b)[100m${attribute}$([char]0x1b)[0m: `"$([char]0x1b)[35m$content$([char]0x1b)[0m`""
    } else {
        # If the file doesn't exist, initialize an empty string
        $content = ""
    }

    # If the attribute is a .txt file, prompt the user to update its content
    if ($attribute -match ".txt$") {
        $newContent = Read-Host "Enter new content for ${attribute} ($([char]0x1b)[2mleave empty to keep existing content$([char]0x1b)[0m)"
        if ($newContent -ne "") {
            $content = $newContent
        }
        Set-Content -Path $attributePath -Value $content
    }
}
