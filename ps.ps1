# heavily based on https://github.com/massgravel/mas-docs/blob/main/get.ps1

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Enable TLSv1.2 for compatibility with older clients
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$downloadURL = 'https://github.com/evenevan/export-ms-teams-chats/archive/refs/heads/main.zip'
$extractedPath = "$([System.IO.Path]::GetTempPath())export-ms-teams-chats"
$zipPath = "$extractedPath.zip"

Invoke-WebRequest -Uri $downloadURL -OutFile $zipPath
Expand-Archive -LiteralPath $zipPath -DestinationPath $extractedPath -Force

$innerFolderName = Get-ChildItem -LiteralPath $extractedPath -Name
$out = "$(Get-Location)/out"

if ($IsMacOS -or $IsLinux) {
    pwsh -File "$extractedPath/$innerFolderName/Get-MicrosoftTeamsChat.ps1" -exportFolder $out

} else {
    try {
        pwsh.exe -File "$extractedPath/$innerFolderName/Get-MicrosoftTeamsChat.ps1" -exportFolder $out
    } catch [System.Management.Automation.CommandNotFoundException] {
        powershell.exe -File "$extractedPath/$innerFolderName/Get-MicrosoftTeamsChat.ps1" -exportFolder $out
    }
}

Remove-Item -LiteralPath $zipPath -Recurse
Remove-Item -LiteralPath $extractedPath -Recurse