[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }
$ProgressPreference = "SilentlyContinue"

function Get-Messages ($chat, $clientId, $tenantId) {
    #50 is the maximum allowed with the beta api
    $link = "https://graph.microsoft.com/v1.0/chats/" + $chat.id + "/messages?top=50"
    $messages = @()

    $start = Get-Date

    try {
        while ($null -ne $link) {
            $messagesToAdd = Invoke-Retry -Code { 
                Invoke-RestMethod -Method Get -Uri $link -Authentication OAuth -Token (Get-GraphAccessToken $clientId $tenantId) -Headers @{ "Prefer" = "include-unknown-enum-members" }
            }
            
            $messages += $messagesToAdd.value
            $link = $messagesToAdd."@odata.nextLink"
        }
    }
    catch {
        Write-Verbose "Failed to fetch messages. Failing."
        throw $_
    }

    Write-Verbose "Took $(((Get-Date) - $start).TotalSeconds)s to get $($messages.count) messages."

    $messages | Sort-Object createdDateTime
}