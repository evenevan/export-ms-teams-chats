[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }
$ProgressPreference = "SilentlyContinue"

function Invoke-Retry {
    param(
        [ScriptBlock]$code,
        [int]$maxRetries = 2,
        [int]$delaySeconds = 2
    )

    $retryCount = 0

    while ($retryCount -lt $maxRetries) {
        try {
            & $code
            break
        }
        catch {
            $retryCount++
            if ($retryCount -eq $maxRetries) {
                Write-Verbose "Failed to run code after the maxmimum amount of $maxRetries retries."
                throw $_
            }
            else {
                Write-Verbose "Failed to run code, retrying."
                Start-Sleep -Seconds $delaySeconds
            }
        }
    }
}