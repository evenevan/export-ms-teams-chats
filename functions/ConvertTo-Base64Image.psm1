[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }

function ConvertTo-Base64Image ($string) {
    $start = Get-Date
    $encoded = [Convert]::ToBase64String((Get-Content $string -AsByteStream -Raw))
    Write-Verbose "Took $(((Get-Date) - $start).TotalSeconds)s to encode image."
    return ("data:image/jpeg;base64," + $encoded)
}