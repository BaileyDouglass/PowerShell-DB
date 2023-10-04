param (
    [Parameter(Mandatory=$true)]
    [string]$topic_name,
    
    [Parameter(Mandatory=$true)]
    [string]$description
)


function Create-TopicFolder {
    param (
        [string]$topic_name,
        [string]$description
    )

    $folder_name = $topic_name.Replace(' ', '-')
    $folder_path = ".\$folder_name"

    if (Test-Path $folder_path) {
        Write-Host "Folder $folder_name already exists."
    } else {
        New-Item -Path $folder_path -ItemType "directory" > $null
        
        $description_file_path = "$folder_path\description.txt"
        Add-Content -Path $description_file_path -Value $description

        Write-Host "$([char]0x1b)[33mCreated folder $folder_name with description.$([char]0x1b)[0m"
    }
}

Create-TopicFolder -topic_name $topic_name -description $description
