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
            "Call started."
            Break
        }
        "#microsoft.graph.chatRenamedEventMessageDetail" {
            "Chat name changed to $($eventDetail.chatDisplayName)."
            Break
        }
        "#microsoft.graph.membersAddedEventMessageDetail" {
            $users = $eventDetail.members | Select-Object -ExpandProperty "id" | Select-Object -Unique | Sort-Object | ForEach-Object { try { Get-User $_ $clientId $tenantId } catch { $_ } }
            "Added $(($users | Select-Object -ExpandProperty "displayName") -join ", ")."
            Break
        }
        "#microsoft.graph.membersDeletedEventMessageDetail" {
            $users = $eventDetail.members | Select-Object -ExpandProperty "id" | Select-Object -Unique | Sort-Object | ForEach-Object { try { Get-User $_ $clientId $tenantId } catch { $_ } }
            "Removed $(($users | Select-Object -ExpandProperty "displayName") -join ", ")."
            Break
        }
        "#microsoft.graph.membersJoinedEventMessageDetail" {
            $users = $eventDetail.members | Select-Object -ExpandProperty "id" | Select-Object -Unique | Sort-Object | ForEach-Object { try { Get-User $_ $clientId $tenantId } catch { $_ } }
            "$(($users | Select-Object -ExpandProperty "displayName") -join ", ") joined."
            Break
        }
        "#microsoft.graph.membersLeftEventMessageDetail" {
            $users = $eventDetail.members | Select-Object -ExpandProperty "id" | Select-Object -Unique | Sort-Object | ForEach-Object { try { Get-User $_ $clientId $tenantId } catch { $_ } }
            "$(($users | Select-Object -ExpandProperty "displayName") -join ", ") left."
            Break
        }
        "#microsoft.graph.messagePinnedEventMessageDetail" {
            "Message pinned."
            Break
        }
        "#microsoft.graph.messageUnpinnedEventMessageDetail" {
            "Message unpinned."
        }
        Default {
            Write-Warning "Unhandled system event type: $($eventDetail."@odata.type")"
            "Unhandled system event type $($eventDetail."@odata.type"): $($eventDetail | ConvertTo-Json -Depth 5)"
        }
    }
}