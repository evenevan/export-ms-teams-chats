[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }

function Get-Initiator ($identitySet, $clientId, $tenantId) {
    if ($identitySet.user) {
        if ($identitySet.user.displayName) {
            $identitySet.user.displayName
        }
        else {
            try {
                $user = Get-User $identitySet.user.id $clientId $tenantId
                $user.displayName
            }
            catch {
                Write-Verbose "Failed to get initiator username."
                "Unknown (Failed to fetch)"
            }
        }
    }
    elseif ($identitySet.application) {
        if ($identitySet.application.displayName) {
            $identitySet.application.displayName
        }
        else {
            "An application"
        }
    }
    else {
        "Unknown"
    }
}