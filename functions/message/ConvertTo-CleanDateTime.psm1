[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }

function ConvertTo-CleanDateTime ($iso) {
    $time = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date ($iso)), (Get-TimeZone).Id)
    Get-Date $time -Format "dd MMMM yyyy, hh:mm tt"
}