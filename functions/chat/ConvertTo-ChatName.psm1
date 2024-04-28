[cmdletbinding()]
Param([bool]$Verbose)
$VerbosePreference = if ($Verbose) { 'Continue' } else { 'SilentlyContinue' }

function ConvertTo-ChatName ($chat, $members, $me, $clientId, $tenantId) {
    $name = $chat.topic

    if ($null -eq $chat.topic) {
        $memberNames = $members | ForEach-Object -Process {
            if ($null -eq $_.displayName) {
                $_.displayName = (Get-DisplayName $_.userId $clientId $tenantId)
            }

            $_
        } | Select-Object -ExpandProperty "displayName" | Select-Object -Unique | Sort-Object 
        $name = ($memberNames | Where-Object { $_ -notmatch $me.displayName }) -join ", "
    }

    $name
}
