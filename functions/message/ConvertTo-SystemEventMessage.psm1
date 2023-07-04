[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }

function ConvertTo-SystemEventMessage ($eventDetail, $clientId, $tenantId) {
    switch ($eventDetail."@odata.type") {
        "#microsoft.graph.callEndedEventMessageDetail" {
            "Call ended after $($eventDetail.callDuration)."
            Break
        }
        "#microsoft.graph.callStartedEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) started a call."
            Break
        }
        "#microsoft.graph.chatRenamedEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) changed the chat name to $($eventDetail.chatDisplayName)."
            Break
        }
        "#microsoft.graph.membersAddedEventMessageDetail" {
            $users = ConvertTo-Users $eventDetail.members $clientId, $tenantId

            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) added $(($users | Select-Object -ExpandProperty "displayName") -join ", ")."

            Break
        }
        "#microsoft.graph.membersDeletedEventMessageDetail" {
            $users = ConvertTo-Users $eventDetail.members $clientId, $tenantId

            if (
                ($users.count -eq 1) -and
                ($null -ne $eventDetail.initiator.user) -and
                ($eventDetail.initiator.user.id -eq $users[0].id)
            ) {
                "$($users[0].displayName) left."
            }
            else {
                "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) removed $(($users | Select-Object -ExpandProperty "displayName") -join ", ")."
            }
            
            Break
        }
        "#microsoft.graph.messagePinnedEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) pinned a message."
            Break
        }
        "#microsoft.graph.messageUnpinnedEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) unpinned a message."
        }
        "#microsoft.graph.teamsAppInstalledEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) added $($eventDetail.teamsAppDisplayName) here."
        }
        "#microsoft.graph.teamsAppRemovedEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) removed $($eventDetail.teamsAppDisplayName)."
        }
        Default {
            Write-Warning "Unhandled system event type: $($eventDetail."@odata.type")"
            "Unhandled system event type $($eventDetail."@odata.type"): $($eventDetail | ConvertTo-Json -Depth 5)"
        }
    }
}

function ConvertTo-Users ($members, $clientId, $tenantId) {
    $eventDetail.members | Select-Object -ExpandProperty "id" | Select-Object -Unique | Sort-Object | ForEach-Object {
        $id = $_

        try {
            Get-User $id $clientId $tenantId
        }
        catch {
            Write-Verbose "Failed to fetch members."
            $id
        }
    }
}