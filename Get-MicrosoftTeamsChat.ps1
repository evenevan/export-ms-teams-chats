#Requires -Version 7.0
<#

    .SYNOPSIS
        Exports Microsoft Chat History

    .DESCRIPTION
        This script reads the Microsoft Graph API and exports of chat history into HTML files in a location you specify.

    .PARAMETER ExportFolder
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
    [Parameter(Mandatory = $true, HelpMessage = "Export location of where the HTML files will be saved.")] [string] $ExportFolder,
    [Parameter(Mandatory = $false, HelpMessage = "The client id of the Azure AD App Registration")] [string] $clientId = "31359c7f-bd7e-475c-86db-fdb8c937548e",
    [Parameter(Mandatory = $false, HelpMessage = "The tenant id of the Azure AD environment the user logs into")] [string] $tenantId = "common",
    [Parameter(Mandatory = $true, HelpMessage = "The domain name of the UPNs for users in your tenant. E.g. contoso.com")] [string] $domain
)

#################################
##   Import Modules  ##
#################################

Set-Location $PSScriptRoot

Import-Module ($PSScriptRoot + "/functions/TelstraPurpleFunctions") -Force

Get-TPASCII

####################################
##   HTML  ##
####################################

$HTML = Get-Content -Raw ./files/chat.html

$HTMLMessagesBlock_them = @"
<div class="message-container">
    <div class="message">
        <div style="display:flex; margin-top:10px">
            <div style="flex:none; overflow:hidden; border-radius:50%; height:42px; width:42px; margin:10px">
                <img height="42" src="###IMAGE###" style="vertical-align:top; width:42px; height:42px;" width="42">
            </div>
            <div class="them" style="flex:1; overflow:hidden;">
                <div style="font-size:1.2rem; white-space:nowrap; text-overflow:ellipsis; overflow:hidden;">
                    <span style="font-weight:700;">###NAME###</span><span style="margin-left:1rem;">###DATE###</span>
                </div>
                <div>
                    ###CONVERSATION###
                </div>
                ###ATTACHMENT###
            </div>
        </div>
    </div>
</div>
"@


$HTMLMessagesBlock_me = @"
<div class="message-container">
    <div class="message">
        <div style="display:flex; margin-top:10px">
            <div class="me" style="flex:1; overflow:hidden;">
                <div style="font-size:1.2rem; white-space:nowrap; text-overflow:ellipsis; overflow:hidden;">
                    <span style="font-weight:700;">###NAME###</span><span style="margin-left:1rem;">###DATE###</span>
                </div>
                <div>
                    ###CONVERSATION###
                </div>
                ###ATTACHMENT###
            </div>
            <div style="flex:none; overflow:hidden; border-radius:50%; height:42px; width:42px; margin:10px">
                <img height="42" src="###IMAGE###" style="vertical-align:top; width:42px; height:42px;" width="42">
            </div>
        </div>
    </div>
</div>
"@

$HTMLAttachmentsBlock = @"
<div class="attachments">
###ATTACHEMENTS###
</div>
"@

$HTMLAttachment = @"
<div class="attachment-container">
<a class="attachment" href="###ATTACHEMENTURL###" target="_blank">###ATTACHEMENTNAME###</a>
</div>
"@


#Script
Write-Host -ForegroundColor Cyan "`r`nStarting script..."
Write-Host -ForegroundColor White "`r`nSign in with the Device Code to the app registration:"
$tokenOutput = Connect-DeviceCodeAPI $clientId $tenantId $null
$token = $tokenOutput.access_token
$refresh_token = $tokenOutput.refresh_token

$ImagesFolder = Join-Path -Path $ExportFolder -ChildPath "images"
if (-not(Test-Path -Path $ImagesFolder)) { New-Item -ItemType Directory -Path $ImagesFolder | Out-Null }
$ExportFolder = (Resolve-Path -Path $ExportFolder).ToString()

$accessToken = ConvertTo-SecureString $token -AsPlainText -Force

$me = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/me" -Authentication OAuth -Token $accessToken

$allChats = @();
$firstChat = Invoke-RestMethod -Method Get -Uri "https://graph.microsoft.com/v1.0/me/chats" -Authentication OAuth -Token $accessToken
$allChats += $firstChat
$allChatsCount = $firstChat."@odata.count" 

Write-Host ("`r`nGetting all chats, please wait... This may take some time.`r`n")

if ($null -ne $firstChat."@odata.nextLink") {
    $chatNextLink = $firstChat."@odata.nextLink"
    do {
        $chatsToAdd = Invoke-RestMethod -Method Get -Uri $chatNextLink -Authentication OAuth -Token $accessToken
        $allChats += $chatsToAdd
        $chatNextLink = $chatsToAdd."@odata.nextLink"
        $allChatsCount = $allChatsCount + $chatsToAdd."@odata.count"
    } until ($null -eq $chatsToAdd."@odata.nextLink" )
}

$chats = $allChats.value | Sort-Object createdDateTime -Descending
$chats = $allChats.value | Where-Object { $_.id -eq "19:a53f20641c35442f92c005c9f4edb60f@thread.v2" } | Sort-Object createdDateTime -Descending
Write-Host ("`r`n" + $chats.count + " possible chat threads found.`r`n")

$threadCount = 0
$StartTime = Get-Date

foreach ($thread in $chats) {
    #50 is the maximum allowed with the beta api
    $conversationUri = "https://graph.microsoft.com/v1.0/me/chats/" + $thread.id + "/messages?top=50"

    $elapsedTime = (Get-Date) - $StartTime
    
    Write-Verbose ("Script running for " + $elapsedTime.TotalSeconds + " seconds.")
    if ($elapsedTime.TotalMinutes -gt 30) {
        Write-Host -ForegroundColor Cyan "Reauthenticating with refresh token..."
        $tokenOutput = Connect-DeviceCodeAPI $clientId $tenantId $refresh_token
        $token = $tokenOutput.access_token
        $refresh_token = $tokenOutput.refresh_token
        $accessToken = ConvertTo-SecureString $token -AsPlainText -Force
        $StartTime = $(Get-Date)
        Start-Sleep 5
    }

    $name = Get-Random;

    if ($null -ne $thread.topic) {
        $name = $thread.topic
    }
    else {
        $membersUri = "https://graph.microsoft.com/v1.0/me/chats/" + $thread.id + "/members"
        $members = Invoke-RestMethod -Method Get -Uri $membersUri -Authentication OAuth -Token $accessToken
        $members = $members.value.displayName | Where-Object { $_ -notlike "*@purple.telstra.com" } | Sort-Object
        $name = ($members | Where-Object { $_ -notmatch $me.displayName } | Select-Object -Unique) -join ", "
    }
    $allConversations = @();

    try {
        $firstConversation = Invoke-RestMethod -Method Get -Uri $conversationUri -Authentication OAuth -Token $accessToken -Headers @{ "Prefer" = "include-unknown-enum-members" }
        $allConversations += $firstConversation
        $allConversationsCount = $firstConversation."@odata.count" 
    }
    catch {
        Write-Host ($name + " :: Could not download historical messages.")
        Write-Host -ForegroundColor Yellow "Skipping...`r`n"
    }

    if ($null -ne $firstConversation."@odata.nextLink") {
        $conversationNextLink = $firstConversation."@odata.nextLink"
        do {
            # nclude-unknown-enum-members needed for the messageType prop
            $conversationToAdd = Invoke-RestMethod -Method Get -Uri $conversationNextLink -Authentication OAuth -Token $accessToken -Headers @{ "Prefer" = "include-unknown-enum-members" }
            $allConversations += $conversationToAdd
            $conversationNextLink = $conversationToAdd."@odata.nextLink"

            $allConversationsCount = $allConversationsCount + $conversationToAdd."@odata.count"
        } until ($null -eq $conversationToAdd."@odata.nextLink")
    }

    $conversation = $allConversations.value | Sort-Object createdDateTime 
    $threadCount++
    $messagesHTML = $null

    if (($conversation.count -gt 0) -and (-not([string]::isNullorEmpty($name)))) {

        Write-Host -ForegroundColor White ($name + " :: " + $allConversationsCount + " messages.")
        Write-Verbose $conversationUri

        foreach ($message in $conversation) {
            $userPhotoUPN = ($message.from.user.displayName -replace " ", ".") + "@" + $domain
            $profilefile = Join-Path -Path $ImagesFolder -ChildPath "$userPhotoUPN.jpg"
            if (-not(Test-Path $profilefile)) {
                $profilePhotoUri = "https://graph.microsoft.com/v1.0/users/" + $userPhotoUPN + "/photos/96x96/`$value"
                $pictureURL = ("data:image/jpeg;base64,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")
                try {
                    Invoke-WebRequest -Uri $profilePhotoUri -Authentication OAuth -Token $accessToken -OutFile $profilefile
                    $pictureURL = Get-EncodedImage $profilefile
                }
                catch {
                }
            }
            else {
                $pictureURL = Get-EncodedImage $profilefile
            }

            switch ($message.messageType) {
                "message" {
                    $messageBody = $message.body.content
                    $imagecount = 0
        
                    while ($messageBody -match "<img.+?src=[\`"']https:\/\/graph.microsoft.com(.+?)[\`"'].*?>") {
                        $imagecount++
                        $threadidIO = $thread.id.Split([IO.Path]::GetInvalidFileNameChars()) -join "_"
                        $imagefile = Join-Path -Path $ImagesFolder -ChildPath "$threadidIO$imagecount.jpg"
                        $imageUri = "https://graph.microsoft.com" + $Matches[1]
        
                        Write-Host "Downloading embedded image in message..."
        
                        $retries = 0
                        $limit = 5
                        $completed = $false
                        while (-not $completed) {
                            try {
                                $response = Invoke-WebRequest -Uri $imageUri -Authentication OAuth -Token $accessToken
                                Set-Content -Path $imagefile -AsByteStream -Value $response.Content
        
                                $imageencoded = Get-EncodedImage $imagefile
                                $messageBody = $messageBody.Replace($Matches[0], "<img src=`"$imageencoded`" style=`"width: 100%;`" >")
                                $completed = $true
                            }
                            catch [System.Net.Http.HttpRequestException] {
                                Write-Verbose $_
        
                                $status = $_.Exception.Response.StatusCode.value__
        
                                # if a 4XX error and not 429, reduce retry limit
                                if (($status -ne 429) -and ($status -ge 400) -and ($sttaus -lt 500)) {
                                    $limit = 1
                                }
        
                                if ($retries -ge $limit) {
                                    Write-Warning "Request to $imageUri failed the maximum number of $limit times with status $status."
                                    $completed = $true
                                }
                                else {
                                    Write-Warning "Request to $imageUri failed with status $status. Retrying in 5 seconds."
                                    Start-Sleep 5
                                    $retries++
                                }
                            }
                            catch {
                                Write-Error $_
                                Write-Error "Unable to handle error, skipping image."

                                $completed = $true
                            }
                        }

                        # fun little hack to stop the regex from matching failed requests
                        $messageBody = $messageBody.Replace($Matches[0], "")
                    }
        
                    $time = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date ($message.createdDateTime)), (Get-TimeZone).Id)
                    $time = Get-Date $time -Format "dd MMMM yyyy, hh:mm tt"
        
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
                            -Replace "###IMAGE###", $pictureURL
                            
                    }
                    else {
                        $messagesHTML += $HTMLMessagesBlock `
                            -Replace "###NAME###", $message.from.user.displayName`
                            -Replace "###CONVERSATION###", $messageBody`
                            -Replace "###DATE###", $time`
                            -Replace "###ATTACHMENT###", $null`
                            -Replace "###IMAGE###", $pictureURL
                    }
                }
                "systemEventMessage" {
                    Write-Debug AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
                    $eventType = $message.eventDetail."@odata.type" `
                        -Replace "#microsoft.graph.", ""

                    $messageBody = "${eventType}: $($message.eventDetail | ConvertTo-Json)"

                    $messagesHTML += $HTMLMessagesBlock_them `
                        -Replace "###NAME###", "System Event"`
                        -Replace "###CONVERSATION###", $messageBody`
                        -Replace "###DATE###", $time`
                        -Replace "###ATTACHMENT###", $null`
                        -Replace "###IMAGE###", $pictureURL
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
            $name = $name.Substring(0, 64);
        }

        $file = Join-Path -Path $ExportFolder -ChildPath "$name.html"
        if (Test-Path $file) { $file = ($file -Replace ".html", ( "(" + $threadCount + ")" + ".html")) }
        Write-Host -ForegroundColor Green "Exporting $file... `r`n"
        $HTMLfile | Out-File -FilePath $file
    }
    else {
        Write-Host ($name + " :: No messages found.")
        Write-Host -ForegroundColor Yellow "Skipping...`r`n"
    }
}
Remove-Item -Path $ImagesFolder -Recurse
Write-Host -ForegroundColor Cyan "`r`nScript completed... Bye!"
