[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }
$ProgressPreference = "SilentlyContinue"

function Get-Chats ($clientId, $tenantId) {
    $link = "https://graph.microsoft.com/v1.0/me/chats"
    $chats = @();

    $start = Get-Date

    while ($null -ne $link) {
        $chatsToAdd = Invoke-Retry -Code {
            Invoke-RestMethod -Method Get -Uri $link -Authentication OAuth -Token (Get-GraphAccessToken $clientId $tenantId)
        }
        
        $chats += $chatsToAdd.value
        $link = $chatsToAdd."@odata.nextLink"
    }

    Write-Verbose "Took $(((Get-Date) - $start).TotalSeconds)s to get $($chats.count) chats."

    $chats | Sort-Object createdDateTime -Descending
}