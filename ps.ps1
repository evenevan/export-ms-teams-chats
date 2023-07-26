# based on https://github.com/massgravel/mas-docs/blob/main/get.ps1

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$verbose = $VerbosePreference -ne 'SilentlyContinue'
$downloadURL = 'https://github.com/attituding/export-ms-teams-chats/archive/refs/heads/main.zip'

$extractedPath = "$([System.IO.Path]::GetTempPath())export-ms-teams-chats"
$zipPath = "$extractedPath.zip"

Invoke-WebRequest -Uri $downloadURL -OutFile $zipPath
Expand-Archive -LiteralPath $zipPath -DestinationPath $extractedPath -Force

$innerFolderName = Get-ChildItem -LiteralPath $extractedPath -Name
$out = "$(Get-Location)/out"

if ($IsMacOS -or $IsLinux) {
    pwsh -File "$extractedPath/$innerFolderName/Get-MicrosoftTeamsChat.ps1" -exportFolder $out -Verbose:$verbose

} else {
    try {
        pwsh.exe -File "$extractedPath/$innerFolderName/Get-MicrosoftTeamsChat.ps1" -exportFolder $out -Verbose:$verbose
    } catch [System.Management.Automation.CommandNotFoundException] {
        powershell.exe -File "$extractedPath/$innerFolderName/Get-MicrosoftTeamsChat.ps1" -exportFolder $out -Verbose:$verbose
    }
}

Remove-Item -LiteralPath $zipPath -Recurse
Remove-Item -LiteralPath $extractedPath -Recurse