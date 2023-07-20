[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }
$ProgressPreference = "SilentlyContinue"

$defaultProfilePicture = ("data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wAARCADIAMgDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD8qqKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD0r4H/s5fED9o3VdT034faGuu32mwLc3MJu4bcrGW2ggyuoPPYGuo8Z/sO/HjwBA8+s/C/XY4EGWltIlu0A+sLOK+sP8AgiR/yVz4h/8AYGg/9HGv2GoA/lbubaaznkgnieCaMlXjkUqyn0IPINR1/Sh8a/2WPhf+0Hp0lv428JWWpXDLtTUYlMN5EexWZMNxjoSR6ivyU/bG/wCCXfi74A2t54q8EzT+M/BEWZJwIwL3T045kQH94o/vqOO4A5oA+GqKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD9Iv+CJH/JXfiH/2BoP/AEca/Yavx5/4Ikf8ld+If/YGg/8ARxr9hqACkZQ6lWAZSMEEcGlooA/IL/gp7+wDa/D9Lv4ufDrThb+H5JN2u6RbrhLJ2IAuIxnhGY/MoGFJz0Jx+alf1N61o1j4i0i90vU7WO90+8haC4tpl3JLGwwykehBr+c79sP9n6f9mn4++I/BmHbSUkF3pU7nPm2kg3R89yvKH3Q0AeK0UUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAfpF/wRI/5K78Q/8AsDQf+jjX7DV+PP8AwRI/5K78Q/8AsDQf+jjX7DUAFFFFABX5j/8ABbL4WQ3vg7wF8QreILdWF3LpF24H34pV8yLP+60b4/3zX6cV8f8A/BWDS49Q/Yl8X3DqC1je6dcIfQm7ij/lIaAPwXooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA/SL/giR/yV34h/wDYGg/9HGv2Gr8ef+CJH/JXfiH/ANgaD/0ca/YagAooooAK+NP+CtmvxaR+xh4gsncLJqupWFrGp6sVuFmP6RGvsuvyj/4LY/F6Oe78B/DWzmDPAJda1BAfukgRwA/h5x/KgD8s6KKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAP0i/wCCJH/JXfiH/wBgaD/0ca/Yavx5/wCCJH/JXfiH/wBgaD/0ca/YagAoorN8R+JNL8IaFe61rd/b6XpNlGZrm8unCRxIOpYnpQBmfEj4h6H8KPAuteLvEl4tjouk27XNzM3oOAoHdmJCgdyRX8337QHxl1X9oD4v+JfHer5S51a53xwFsi3hUBYoh7KiqPc5PevpD/god+3tcftP+IF8K+E5JrP4b6XNvj3Ao+qTDGJpFIyFHOxT65PJAHxbQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFfrT/wRr+H3hjxl8H/Hs+veHtM1maHXUSOS+tI5mRfs6HALA4Ge1AH5LUV/Th/woz4df9CL4d/8FkP/AMTR/wAKM+HX/Qi+Hf8AwWQ//E0AfzH0V/Th/wAKM+HX/Qi+Hf8AwWQ//E0f8KM+HX/Qi+Hf/BZD/wDE0Aflj/wRI/5K78Q/+wNB/wCjjX65694m0jwtZtd6zqlnpVqoLGa9nWJQB15Yivzt/wCCtmn2vwc+E/g298CW8Xg28vdXeC5n0JBZvNGIiQjtHgsM84NfkZq/iPVvEEvmapqd5qMmc7rudpT/AOPE0Aful8df+Cp3wW+EVtcW2iao3j7XkBC2WjZ8gN/t3BGwD/d3fSvyh/ak/bg+I/7VWoeVr96uleGYn323h7TyVt4z/ec9ZW46t07AV890UAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAV+xP/BEf/ki/wAQ/wDsYI//AEmSvx2r9if+CI//ACRf4h/9jBH/AOkyUAfo/RRRQAUUUUAfnD/wW0/5Iz4A/wCw5J/6JNfjrX7Ff8FtP+SM+AP+w5J/6JNfjrQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAV+xP/BEf/ki/xD/7GCP/ANJkr8dq/Yn/AIIj/wDJF/iH/wBjBH/6TJQB+j9FFFABRRRQB+cP/BbT/kjPgD/sOSf+iTX461+xX/BbT/kjPgD/ALDkn/ok1+OtABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABXsHwU/a5+LX7Oui6hpPw88Wt4d0/ULgXVzCun2tx5koUKGzNE5HAAwCBXj9FAH1L/w8/8A2m/+inP/AOCTTf8A5Go/4ef/ALTf/RTn/wDBJpv/AMjV8tUUAfUv/Dz/APab/wCinP8A+CTTf/kaj/h5/wDtN/8ARTn/APBJpv8A8jV8tUUAewfGr9rr4tftEaLYaT8QvFreIdPsJzc28J0+1t9khXaWzDEhPHYkivH6KKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA//2Q==")

$attempted = @{}

function Get-ProfilePicture ($userId, $assetsFolderPath, $clientId, $tenantId) {
    $profilePictureFile = Join-Path -Path "$($MyInvocation.PSScriptRoot)/$assetsFolderPath" -ChildPath "$userId.jpg"

    if (Test-Path $profilePictureFile) {
        # if available
        Write-Verbose "Profile picture cache hit."
        "assets/$userId.jpg"
    }
    elseif (($null -eq $userId) -or ($attempted.ContainsKey($userId))) {
        Write-Verbose "Profile picture unavailable, using default."

        # if userId is null or failed to download profile picture
        $defaultProfilePicture
    }
    else {
        # if never attempted
        
        Write-Verbose "Profile picture cache miss, fetching."

        $attempted.Add($userId, $null)
        $profilePhotoUri = "https://graph.microsoft.com/v1.0/users/" + $userId + "/photo/`$value"

        try {
            $start = Get-Date

            Invoke-Retry -Code {
                Invoke-WebRequest -Uri $profilePhotoUri -Authentication OAuth -Token (Get-GraphAccessToken $clientId $tenantId) -OutFile $profilePictureFile
            }

            Write-Verbose "Took $(((Get-Date) - $start).TotalSeconds)s to download profile picture."

            "assets/$userId.jpg"
        }
        catch {
            Write-Verbose "Failed to fetch profile picture."
            $defaultProfilePicture
        }
    }
}