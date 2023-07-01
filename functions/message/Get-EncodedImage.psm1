[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }

# probably better to save the encoded pictures to the files so duplciates don't have to recalculate
function Get-EncodedImage ($imageTagMatch, $imageFolderPath, $clientId, $tenantId) {
    $imageUriPath = $imageTagMatch.Groups[1].Value
    $imageFileName = ($imageUriPath -replace "^.*/hostedContents/(.*)/\`$value$", '$1')
    $imageFileName = $imageFileName.substring(0, [System.Math]::Min(250, $imageFileName.Length))
    $imageFile = Join-Path -Path "$($MyInvocation.PSScriptRoot)/$imageFolderPath" -ChildPath "$imageFileName.jpg"

    if (-not(Test-Path $imageFile)) {
        Write-Verbose "Image cache miss, downloading."

        $imageUri = "https://graph.microsoft.com" + $imageUriPath
        
        try {
            $start = Get-Date

            Invoke-Retry -Code {
                Invoke-WebRequest -Uri $imageUri -Authentication OAuth -Token (Get-GraphAccessToken $clientId $tenantId) -OutFile $imageFile
            }

            Write-Verbose "Took $(((Get-Date) - $start).TotalSeconds)s to download image."

            $imageEncoded = ConvertTo-Base64Image $imageFile
        }
        catch {
            Write-Verbose "Unable to fetch and encode image, returning input."
            $imageEncoded = $imageUri
        }
    }
    else {
        Write-Verbose "Image cache hit."
        $imageEncoded = ConvertTo-Base64Image $imageFile
    }

    $imageEncoded
}