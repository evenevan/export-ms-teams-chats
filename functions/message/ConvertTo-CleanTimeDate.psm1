[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }

function ConvertTo-CleanTimeDate ($iso) {
    $time = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date ($iso)), (Get-TimeZone).Id)
    $time = Get-Date $time -Format "dd MMMM yyyy, hh:mm tt"
}