[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }
$ProgressPreference = "SilentlyContinue"

$Scope = "Chat.Read, User.Read, User.ReadBasic.All, offline_access"

$accessToken = $null
$refreshToken = $null
$expires = $null

function Get-GraphAccessToken ($clientId, $tenantId) {
    if ($expires -ge ((Get-Date) + 600)) {
        return $accessToken
    }

    if ([string]::IsNullOrEmpty($refreshToken)) {
        Write-Verbose "No access token, getting token."

        $contentType = $null
        $codeBody = @{ 
            client_id = $clientId
            scope     = $Scope
        }
        if ($clientId -eq "31359c7f-bd7e-475c-86db-fdb8c937548e") {
            $contentType = "application/x-www-form-urlencoded"
            $codeBody = "client_id=$clientID&scope=https%3A%2F%2Fgraph.microsoft.com%2F%2F.default+offline_access+openid+profile"
        }

        $deviceCodeRequest = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/devicecode" -ContentType $contentType -Body $codeBody
        # Print Code to console
        Write-Host "`n$($deviceCodeRequest.message)"

        $tokenBody = @{
            grant_type  = "urn:ietf:params:oauth:grant-type:device_code"
            code        = $deviceCodeRequest.device_code
            device_code = $deviceCodeRequest.device_code
            client_info = 1
            client_id   = $clientId
          
        }
    }
    else {
        Write-Verbose "Access token expired, getting new token."
        
        $tokenBody = @{
            grant_type    = "refresh_token"
            scope         = $scope
            refresh_token = $refreshToken
            client_id     = $clientId       
        }
    }
      
  
    # Get OAuth Token
    while ([string]::IsNullOrEmpty($authRequest.access_token)) { 
        $authRequest = try {
            Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Body $tokenBody
        }
        catch {
            $errorMessage = $_.ErrorDetails.Message | ConvertFrom-Json
  
            # If not waiting for auth, throw error
            if ($errorMessage.error -ne "authorization_pending") {
                throw
            } 
        } 
    }
    
    $script:accessToken = ConvertTo-SecureString $authRequest.access_token -AsPlainText -Force
    $script:refreshToken = $authRequest.refresh_token
    $script:expires = (Get-Date).AddSeconds($authRequest.expires_in)

    $accessToken
}