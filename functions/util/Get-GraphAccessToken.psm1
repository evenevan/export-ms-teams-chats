[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }
$ProgressPreference = "SilentlyContinue"

$resourceScores = "Chat.Read User.Read offline_access"
# https://learn.microsoft.com/EN-US/azure/active-directory/develop/scopes-oidc#openid
$openIdScopes = "offline_access openid"

$scopes = $null
$accessToken = $null
$refreshToken = $null
$expires = $null
$interval = $null

function Get-GraphAccessToken ($clientId, $tenantId) {
    if ($expires -ge ((Get-Date) + 600)) {
        return $accessToken
    }

    if ([string]::IsNullOrEmpty($refreshToken)) {
        Write-Verbose "No access token, getting token."
        
        if ($clientId -eq "31359c7f-bd7e-475c-86db-fdb8c937548e") {
            # openid scopes and authentiation
            $script:scopes = $openIdScopes
            $contentType = "application/x-www-form-urlencoded"
            $codeBody = @{ 
                client_id = $clientId
                scope     = $openIdScopes
            }
        } else {
            # resource scopes and authentication
            $script:scopes = $resourceScopes
            $contentType = $null
            $codeBody = @{ 
                client_id = $clientId
                scope     = $resourceScores
            }
        }

        $deviceCodeRequest = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/devicecode" -ContentType $contentType -Body $codeBody
        Write-Host "`n$($deviceCodeRequest.message)"

        $interval = $deviceCodeRequest.interval

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
            scope         = $scopes
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

            Start-Sleep $interval
        } 
    }
    
    $script:accessToken = ConvertTo-SecureString $authRequest.access_token -AsPlainText -Force
    $script:refreshToken = $authRequest.refresh_token
    $script:expires = (Get-Date).AddSeconds($authRequest.expires_in)

    $accessToken
}