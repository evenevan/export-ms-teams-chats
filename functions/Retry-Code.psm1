[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }

function Retry-Code {
    param(
        [ScriptBlock]$code,
        [int]$maxRetries = 1,
        [int]$delaySeconds = 1
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