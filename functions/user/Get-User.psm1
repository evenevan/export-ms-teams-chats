[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }

$users = @{}

function Get-User ($userId, $clientId, $tenantId) {
    if ($users.ContainsKey($userId)) {
        Write-Verbose "User cache hit."
        $users[$userId]
    } else {
        Write-Verbose "User cache miss, fetching."

        $start = Get-Date

        $userUri = "https://graph.microsoft.com/v1.0/users/" + $userId
    
        $user = Invoke-Retry -Code {
            Invoke-RestMethod -Method Get -Uri $userUri -Authentication OAuth -Token (Get-GraphAccessToken $clientId $tenantId)
        }
    
        Write-Verbose "Took $(((Get-Date) - $start).TotalSeconds)s to get user."

        $users.Add($userId, $user)
    
        $user
    }
}
