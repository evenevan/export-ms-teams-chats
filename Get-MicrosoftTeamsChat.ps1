#Requires -Version 5.1
<#

    .SYNOPSIS
        Exports Microsoft Chat History

    .DESCRIPTION
        This script reads the Microsoft Graph API and exports of chat history into HTML files in a location you specify.

    .PARAMETER exportFolder
        Export location of where the HTML files will be saved. For example, "D:\ExportedHTML\"

    .PARAMETER clientId
        The client id of the Azure AD App Registration.

    .PARAMETER tenantId
        The tenant id. See https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-protocols-oidc#find-your-apps-openid-configuration-document-uri for possible tenants.

    .EXAMPLE
        .\Get-MicrosoftTeamChat.ps1 -ExportFolder "D:\ExportedHTML" -clientId "31359c7f-bd7e-475c-86db-fdb8c937548e" -tenantId "contoso.onmicrosoft.com"

    .NOTES
        Original Author: Trent Steenholdt
        Pre-requisites: An app registration with delegated User.Read, Chat.Read and User.ReadBasic. All permissions is needed in the Azure AD tenant you're connecting to.

#>

[cmdletbinding()]
Param(
    [Parameter(Mandatory = $false, HelpMessage = "Export location of where the HTML files will be saved.")] [string] $exportFolder = "out",
    [Parameter(Mandatory = $false, HelpMessage = "The client id of the Azure AD App Registration")] [string] $clientId = "31359c7f-bd7e-475c-86db-fdb8c937548e",
    [Parameter(Mandatory = $false, HelpMessage = "The tenant id of the Azure AD environment the user logs into")] [string] $tenantId = "common"
)

#################################
##   Import Modules  ##
#################################

Set-Location $PSScriptRoot

$verbose = $PSBoundParameters["verbose"]

Get-ChildItem "$PSScriptRoot/functions/chat/*.psm1" | ForEach-Object { Import-Module $_.FullName -Force -ArgumentList $verbose }
Get-ChildItem "$PSScriptRoot/functions/message/*.psm1" | ForEach-Object { Import-Module $_.FullName -Force -ArgumentList $verbose }
Get-ChildItem "$PSScriptRoot/functions/user/*.psm1" | ForEach-Object { Import-Module $_.FullName -Force -ArgumentList $verbose }
Get-ChildItem "$PSScriptRoot/functions/util/*.psm1" | ForEach-Object { Import-Module $_.FullName -Force -Global -ArgumentList $verbose }

####################################
##   HTML  ##
####################################

$chatHTMLTemplate = Get-Content -Raw ./assets/chat.html
$messageHTMLTemplate = Get-Content -Raw ./assets/message.html
$stylesheetCSS = Get-Content -Raw ./assets/stylesheet.css

#Script
$start = Get-Date

Write-Host -ForegroundColor Cyan "Starting script..."

$assetsFolder = Join-Path -Path $exportFolder -ChildPath "assets"
if (-not(Test-Path -Path $assetsFolder)) { New-Item -ItemType Directory -Path $assetsFolder | Out-Null }
$exportFolder = (Resolve-Path -Path $exportFolder).ToString()

Write-Host "Your chats will be exported to $exportFolder."

$me = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/me" -Headers @{
    "Authorization" = "Bearer $(Get-GraphAccessToken $clientId $tenantId)"
}

Write-Host ("Getting all chats, please wait... This may take some time.")
$chats = Get-Chats $clientId $tenantId
Write-Host ("" + $chats.count + " possible chat chats found.")

$chatIndex = 0

foreach ($chat in $chats) {
    Write-Progress -Activity "Exporting Chats" -Status "Chat $($chatIndex) of $($chats.count)" -PercentComplete $(($chatIndex / $chats.count) * 100)
    $chatIndex += 1

    $members = Get-Members $chat $clientId $tenantId
    $name = ConvertTo-ChatName $chat $members $me $clientId $tenantId
    $messages = Get-Messages $chat $clientId $tenantId

    $messagesHTML = $null

    if (($messages.count -gt 0) -and (-not([string]::isNullorEmpty($name)))) {

        Write-Host -ForegroundColor White ("`r`n$name :: $($messages.count) messages.")

        # download profile pictures for use later
        Write-Host "Downloading profile pictures..."

        foreach ($member in $members) {
            Get-ProfilePicture $member.userId $assetsFolder $clientId $tenantId | Out-Null
        }

        Write-Host "Processing messages..."

        foreach ($message in $messages) {
            $profilePicture = Get-ProfilePicture $message.from.user.id $assetsFolder $clientId $tenantId
            $time = ConvertTo-CleanDateTime $message.createdDateTime

            switch ($message.messageType) {
                "message" {
                    $messageBody = $message.body.content

                    $imageTagMatches = [Regex]::Matches($messageBody, "<img.+?src=[\`"']https:\/\/graph.microsoft.com(.+?)[\`"'].*?>")

                    foreach ($imageTagMatch in $imageTagMatches) {
                        Write-Verbose "Downloading embedded image in message..."
                        $imagePath = Get-Image $imageTagMatch $assetsFolder $clientId $tenantId
                        $messageBody = $messageBody.Replace($imageTagMatch.Groups[0], "<img src=`"$imagePath`" style=`"width: 100%;`" >")
                    }
        
                    $messageHTML = $messageHTMLTemplate `
                        -Replace "###ATTACHMENTS###", (ConvertTo-HTMLAttachments $message.attachments) `
                        -Replace "###CONVERSATION###", $messageBody `
                        -Replace "###DATE###", $time `
                        -Replace "###DELETED###", "$($null -ne $message.deletedDateTime)".ToLower() `
                        -Replace "###EDITED###", "$($null -ne $message.lastEditedDateTime)".ToLower() `
                        -Replace "###IMAGE###", $profilePicture `
                        -Replace "###ME###", "$($message.from.user.displayName -eq $me.displayName)".ToLower() `
                        -Replace "###NAME###", (Get-Initiator $message.from clientId $tenantId) `
                        -Replace "###PRIORITY###", $message.importance

                    $messagesHTML += $messageHTML `
                        
                    Break
                }
                "systemEventMessage" {
                    $messagesHTML += $messageHTMLTemplate `
                        -Replace "###ATTACHMENTS###", $null `
                        -Replace "###CONVERSATION###", (ConvertTo-SystemEventMessage $message.eventDetail $clientId $tenantId) `
                        -Replace "###DATE###", $time `
                        -Replace "###DELETED###", $null `
                        -Replace "###EDITED###", $null `
                        -Replace "###IMAGE###", $profilePicture `
                        -Replace "###ME###", "false" `
                        -Replace "###NAME###", "System Event" `
                        -Replace "###PRIORITY###", $message.importance

                    Break
                }
                Default {
                    Write-Warning "Unhandled message type: $($message.messageType)"
                }
            }
        }

        $chatHTML = $chatHTMLTemplate `
            -Replace "###MESSAGES###", $messagesHTML`
            -Replace "###CHATNAME###", $name`
            -Replace "###STYLE###", $stylesheetCSS`

        $name = $name.Split([IO.Path]::GetInvalidFileNameChars()) -join "_"

        if ($name.length -gt 64) {
            $name = $name.Substring(0, 64)
        }

        $file = Join-Path -Path $exportFolder -ChildPath "$name.html"

        if ($chat.chatType -ne "oneOnOne") {
            # add hash of chatId in case multiple chats have the same name or members
            $chatIdStream = [IO.MemoryStream]::new([byte[]][char[]]$chat.id)
            $chatIdShortHash = (Get-FileHash -InputStream $chatIdStream -Algorithm SHA256).Hash.Substring(0,8)
            $file = ($file -Replace ".html", ( " ($chatIdShortHash).html"))
        }

        Write-Host -ForegroundColor Green "Exporting $file..."
        $chatHTML | Out-File -FilePath $file
    }
    else {
        Write-Host ("`r`n$name :: No messages found.")
        Write-Host -ForegroundColor Yellow "Skipping..."
    }
}

Write-Host -ForegroundColor Cyan "`r`nScript completed after $(((Get-Date) - $start).TotalSeconds)s... Bye!"