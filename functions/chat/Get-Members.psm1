[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }

function Get-Members ($chat, $clientId, $tenantId) {
    $start = Get-Date

    $membersUri = "https://graph.microsoft.com/v1.0/chats/" + $chat.id + "/members"

    $members = Retry-Code -Code {
        Invoke-RestMethod -Method Get -Uri $membersUri -Authentication OAuth -Token (Get-GraphAccessToken $clientId $tenantId)
    }

    Write-Verbose "Took $(((Get-Date) - $start).TotalSeconds)s to get $($members.count) members."

    $members
}
