[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }
$ProgressPreference = "SilentlyContinue"

function Get-Members ($chat, $clientId, $tenantId) {
    $start = Get-Date

    $membersUri = "https://graph.microsoft.com/v1.0/chats/" + $chat.id + "/members"

    try {
        $members = Invoke-Retry -Code {
            Invoke-RestMethod -Method Get -Uri $membersUri -Headers @{
                "Authorization" = "Bearer $(Get-GraphAccessToken $clientId $tenantId)"
            }
        }
    }
    catch {
        Write-Verbose "Failed to fetch members. Failing."
        throw $_
    }

    Write-Verbose "Took $(((Get-Date) - $start).TotalSeconds)s to get $($members.value.count) members."

    $members.value
}
