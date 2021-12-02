function Get-TPASCII() {
    Write-Host @"
 _____    _    _             ___               _     
|_   _|__| |__| |_ _ _ ___  | _ \_  _ _ _ _ __| |___ 
  | |/ -_) (_-<  _| '_/ _ | |  _/ || | '_| '_ \ / -_)
  |_|\___|_/__/\__|_| \___| |_|  \_,_|_| | .__/_\___|
                                         |_|         
"@ -ForegroundColor White
} 

function Connect-DeviceCodeAPI ($clientId, $tenantId, $refresh) {

    if ([string]::IsNullOrEmpty($refresh)) {
            $codeBody = @{ 

                resource  = "https://graph.microsoft.com/"
                client_id = $clientId
                scope     = "Chat.Read, User.Read, User.ReadBasic.All, offline_access"

            }

            $codeRequest = Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$tenantId/oauth2/devicecode" -Body $codeBody

            # Print Code to console
            Write-Host "`n$($codeRequest.message)"

            $tokenBody = @{
                grant_type = "urn:ietf:params:oauth:grant-type:device_code"
                code       = $codeRequest.device_code
                client_id  = $clientId
          
            }
        }
        else {
            $tokenBody = @{
                grant_type = "refresh_token"
                scope     = "Chat.Read, User.Read, User.ReadBasic.All, offline_access"
                refresh_token = $refresh
                client_id  = $clientId       
            }
        }
    
      
  
        # Get OAuth Token
        while ([string]::IsNullOrEmpty($tokenRequest.access_token)) { 
            $tokenRequest = try {
                Invoke-RestMethod -Method POST -Uri "https://login.microsoftonline.com/$tenantId/oauth2/token" -Body $tokenBody
            }
            catch {
  
                $errorMessage = $_.ErrorDetails.Message | ConvertFrom-Json
  
                # If not waiting for auth, throw error
                if ($errorMessage.error -ne "authorization_pending") {
                    throw
                } 
            } 
        }
        return $tokenRequest
    }


    function Get-EncodedImage ($string) {
        $Encoded = [convert]::ToBase64String((get-content $string -AsByteStream))
        return ("data:image/jpeg;base64," + $Encoded)
    }