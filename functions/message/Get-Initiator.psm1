[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }

# used to get the initator of an event

function Get-Initiator ($identitySet, $clientId, $tenantId) {
    if ($identitySet.user) {
        if ($identitySet.user.displayName) {
            $identitySet.user.displayName
        }
        else {
            Get-DisplayName $identitySet.user.id $clientId $tenantId
        }
    }
    elseif ($identitySet.application) {
        if ($null -ne $identitySet.application.displayName) {
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