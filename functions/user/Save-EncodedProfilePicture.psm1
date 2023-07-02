[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }
$ProgressPreference = "SilentlyContinue"

function Save-EncodedProfilePicture ($userId, $imageFolderPath, $clientId, $tenantId) {
    $profilePictureFile = Join-Path -Path "$($MyInvocation.PSScriptRoot)/$imageFolderPath" -ChildPath "$userId"
    $profilePictureFileJpg = "$profilePictureFile.jpg"
    $profilePictureFileTxt = "$profilePictureFile.txt"

    if ((-not(Test-Path $profilePictureFileJpg)) -or -not(Test-Path $profilePictureFileTxt)) {
        $profilePhotoUri = "https://graph.microsoft.com/v1.0/users/" + $userId + "/photo/`$value"

        try {
            $start = Get-Date

            Invoke-Retry -Code {
                Invoke-WebRequest -Uri $profilePhotoUri -Authentication OAuth -Token (Get-GraphAccessToken $clientId $tenantId) -OutFile $profilePictureFileJpg
            }

            Write-Verbose "Took $(((Get-Date) - $start).TotalSeconds)s to download profile picture."
            ConvertTo-Base64Image $profilePictureFileJpg | Out-File -FilePath $profilePictureFileTxt
        }
        catch {
            Write-Verbose "Unable to fetch and encode profile picture."
        }
    }
}