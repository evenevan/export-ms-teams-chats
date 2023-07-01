#Requires -Version 7.0
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
        The domain name of the UPNs for users in your tenant. E.g. contoso.com.
    
    .PARAMETER domain
        The heritage tenant, Readify or Kloud.


    .EXAMPLE
        .\Get-MicrosoftTeamChat.ps1 -ExportFolder "D:\ExportedHTML" -clientId "ClientIDforAzureADAppRegistration" -tenantId "TenantIdoftheAADOrg" -domain "contoso.com"

    .NOTES
        Author:  Trent Steenholdt
        Pre-requisites: An app registration with delegated User.Read, Chat.Read and User.ReadBasic.All permissions is needed in the Azure AD tenant you're connecting to.

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
Import-Module "$PSScriptRoot/functions/ConvertTo-Base64Image.psm1" -Force -ArgumentList $verbose
Import-Module "$PSScriptRoot/functions/Get-GraphAccessToken.psm1" -Force -Global -ArgumentList $verbose
Import-Module "$PSScriptRoot/functions/Invoke-Retry.psm1" -Force -Global -ArgumentList $verbose

####################################
##   HTML  ##
####################################

$HTML = Get-Content -Raw ./files/chat.html
$HTMLMessagesBlock_them = Get-Content -Raw ./files/message/other.html
$HTMLMessagesBlock_me = Get-Content -Raw ./files/message/me.html
$HTMLAttachmentsBlock = Get-Content -Raw ./files/message/attachment/block.html
$HTMLAttachment = Get-Content -Raw ./files/message/attachment/attachment.html

#Script
Write-Host -ForegroundColor Cyan "`r`nStarting script..."

$imagesFolder = Join-Path -Path $exportFolder -ChildPath "images"
if (-not(Test-Path -Path $imagesFolder)) { New-Item -ItemType Directory -Path $imagesFolder | Out-Null }
$exportFolder = (Resolve-Path -Path $exportFolder).ToString()

$me = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/me" -Authentication OAuth -Token (Get-GraphAccessToken $clientId $tenantId)

Write-Host ("Getting all chats, please wait... This may take some time.")
$chats = Get-Chats $clientId $tenantId
Write-Host ("" + $chats.count + " possible chat chats found.")

$chatCount = 0

foreach ($chat in $chats) {
    $members = Get-Members $chat $clientId $tenantId
    $name = ConvertTo-ChatName $chat $members $me $clientId $tenantId
    $messages = Get-Messages $chat $clientId $tenantId

    # download all profile pictures for use later
    Write-Host "Downloading all profile pictures..."

    foreach ($member in $members) {
        Save-EncodedProfilePicture $member.userId $imagesFolder $clientId $tenantId
    }

    $chatCount++
    $messagesHTML = $null

    if (($messages.count -gt 0) -and (-not([string]::isNullorEmpty($name)))) {

        Write-Host -ForegroundColor White ($name + " :: " + $messages.count + " messages.")

        foreach ($message in $messages) {
            $encodedProfilePicture = Get-EncodedProfilePicture $message.from.user.id $imagesFolder

            switch ($message.messageType) {
                "message" {
                    $messageBody = $message.body.content

                    $imageTagMatches = [Regex]::Matches($messageBody, "<img.+?src=[\`"']https:\/\/graph.microsoft.com(.+?)[\`"'].*?>")

                    foreach ($imageTagMatch in $imageTagMatches) {
                        Write-Host "Downloading embedded image in message..."
                        $encodedImage = Get-EncodedImage $imageTagMatch $imagesFolder $clientId $tenantId
                        $messageBody = $messageBody.Replace($imageTagMatch.Groups[0], "<img src=`"$encodedImage`" style=`"width: 100%;`" >")
                    }
        
                    $time = ConvertTo-CleanDateTime $message.createdDateTime
        
                    if ($message.from.user.displayName -eq $me.displayName) {
                        $HTMLMessagesBlock = $HTMLMessagesBlock_me
                    } 
                    else { 
                        $HTMLMessagesBlock = $HTMLMessagesBlock_them
                    }

                    $fileAttachments = $message.attachments | Where-Object { $_.contentType -eq "reference" }
        
                    if ($fileAttachments.count -gt 0) {
                        $attachmentsHTML = ""
        
                        foreach ($attachment in $fileAttachments) {
                            $attachmentsHTML += $HTMLAttachment `
                                -Replace "###ATTACHEMENTURL###", $attachment.contentURL`
                                -Replace "###ATTACHEMENTNAME###", $attachment.name
                        }
        
                        $attachmentsBlockHTML = $HTMLAttachmentsBlock `
                            -Replace "###ATTACHEMENTS###", $attachmentsHTML
        
                        $messagesHTML += $HTMLMessagesBlock `
                            -Replace "###NAME###", $message.from.user.displayName`
                            -Replace "###CONVERSATION###", $messageBody`
                            -Replace "###DATE###", $time`
                            -Replace "###ATTACHMENT###", $attachmentsBlockHTML`
                            -Replace "###IMAGE###", $encodedProfilePicture
                            
                    }
                    else {
                        $messagesHTML += $HTMLMessagesBlock `
                            -Replace "###NAME###", $message.from.user.displayName`
                            -Replace "###CONVERSATION###", $messageBody`
                            -Replace "###DATE###", $time`
                            -Replace "###ATTACHMENT###", $null`
                            -Replace "###IMAGE###", $encodedProfilePicture
                    }
                }
                "systemEventMessage" {
                    $eventType = $message.eventDetail."@odata.type" `
                        -Replace "#microsoft.graph.", ""

                    $messageBody = "${eventType}: $($message.eventDetail | ConvertTo-Json -Depth 5)"

                    $messagesHTML += $HTMLMessagesBlock_them `
                        -Replace "###NAME###", "System Event"`
                        -Replace "###CONVERSATION###", $messageBody`
                        -Replace "###DATE###", $time`
                        -Replace "###ATTACHMENT###", $null`
                        -Replace "###IMAGE###", $encodedProfilePicture
                }
                Default {
                    Write-Warning "Unhandled message type: $($message.messageType)"
                }
            }
        }
        $HTMLfile = $HTML `
            -Replace "###MESSAGES###", $messagesHTML`
            -Replace "###CHATNAME###", $name`

        $name = $name.Split([IO.Path]::GetInvalidFileNameChars()) -join "_"

        if ($name.length -gt 64) {
            $name = $name.Substring(0, 64)
        }

        $file = Join-Path -Path $exportFolder -ChildPath "$name.html"
        if (Test-Path $file) { $file = ($file -Replace ".html", ( "(" + $chatCount + ")" + ".html")) }
        Write-Host -ForegroundColor Green "Exporting $file... `r`n"
        $HTMLfile | Out-File -FilePath $file
    }
    else {
        Write-Host ($name + " :: No messages found.")
        Write-Host -ForegroundColor Yellow "Skipping...`r`n"
    }
}

Remove-Item -Path $imagesFolder -Recurse
Write-Host -ForegroundColor Cyan "`r`nScript completed... Bye!"