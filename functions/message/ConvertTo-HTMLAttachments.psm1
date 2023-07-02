[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }

$attachmentsBlockHTML = Get-Content -Raw ./files/message/attachment/block.html
$fileAttachmentHTML = Get-Content -Raw ./files/message/attachment/file.html

function ConvertTo-HTMLAttachments ($attachments) {
    $attachmentsHTML = ""

    # files
    $fileAttachments = $attachments | Where-Object { $_.contentType -eq "reference" }
        
    foreach ($attachment in $fileAttachments) {
        $attachmentsHTML += $fileAttachmentHTML `
            -Replace "###ATTACHMENTURL###", $attachment.contentURL`
            -Replace "###ATTACHMENTNAME###", $attachment.name
    }
    
    if ($attachmentsHTML.Length -ge 0) {
        $attachmentsBlockHTML `
            -Replace "###ATTACHMENTS###", $attachmentsHTML
    } else {
        $null
    }
}