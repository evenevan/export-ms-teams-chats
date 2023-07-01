[cmdletbinding()]
Param([bool]$Verbose)
$VerbosePreference = if ($Verbose) { 'Continue' } else { 'SilentlyContinue' }

function ConvertTo-ChatName ($chat, $members, $me, $clientId, $tenantId) {
    $name = $chat.topic

    if ($null -eq $chat.topic) {
        $memberNames = $members.value.displayName | Sort-Object
        $name = ($memberNames | Where-Object { $_ -notmatch $me.displayName } | Select-Object -Unique) -join ", "
    }

    $name
}
