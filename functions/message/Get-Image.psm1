[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }
$ProgressPreference = "SilentlyContinue"

# probably better to save the encoded pictures to the files so duplciates don't have to recalculate
function Get-Image ($imageTagMatch, $imageFolderPath, $clientId, $tenantId) {
    $imageUriPath = $imageTagMatch.Groups[1].Value
    $imageUriPathStream = [IO.MemoryStream]::new([byte[]][char[]]$imageUriPath)
    $imageFileName = "$((Get-FileHash -InputStream $imageUriPathStream -Algorithm SHA256).Hash).jpg"
    $imageFilePath = Join-Path -Path "$($MyInvocation.PSScriptRoot)/$imageFolderPath" -ChildPath "$imageFileName"

    if (-not(Test-Path $imageFilePath)) {
        Write-Verbose "Image cache miss, downloading."

        $imageUri = "https://graph.microsoft.com" + $imageUriPath
        
        try {
            $start = Get-Date

            Invoke-Retry -Code {
                Invoke-WebRequest -Uri $imageUri -Authentication OAuth -Token (Get-GraphAccessToken $clientId $tenantId) -OutFile $imageFilePath
            }

            Write-Verbose "Took $(((Get-Date) - $start).TotalSeconds)s to download image."

            $imageEncoded = "images/$imageFileName"
        }
        catch {
            Write-Verbose "Failed to fetch image, returning input."
            $imageEncoded = $imageUri
        }
    }
    else {
        Write-Verbose "Image cache hit."
        $imageEncoded = "images/$imageFileName"
    }

    $imageEncoded
}