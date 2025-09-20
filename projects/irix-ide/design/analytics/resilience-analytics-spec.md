# Analytics Spec: Remote Resilience

Defines telemetry required to monitor recovery workflows. Coordinate implementation with data engineering.

## Event Catalogue
| Event Name | Trigger | Properties | Notes |
|------------|---------|------------|-------|
| `connection_status_changed` | Connection manager transitions states | `state` (connected/degraded/reconnecting/offline), `hostId`, `reason` (timeout/auth/maintenance) | Fire once per state change |
| `connection_retry_started` | Automatic retry initiated | `hostId`, `attempt`, `maxAttempts`, `latencyMs` | `attempt` starts at 1 |
| `connection_retry_finished` | Retry succeeded or failed | `hostId`, `attempt`, `outcome` (success/failure), `elapsedMs` | If failure and attempts remaining, follow with new `retry_started` |
| `offline_queue_updated` | Local queue size changes | `queuedFiles`, `queuedBytes`, `hostId` | Fire when going offline and when queue drains |
| `offline_action_selected` | User picks command palette option | `action` (queue_sync/work_offline/open_diff/switch_host), `hostId` | Capture from command palette and banners |
| `sync_conflict_resolved` | Conflict modal action taken | `action` (keep_local/keep_remote/open_merge), `filePath`, `diffLines`, `durationMs` | Duration measured from modal open |
| `deploy_confirmation_shown` | Destructive confirmation presented | `operationId`, `operationType` (deploy/kill), `hostId` | Helps track bypass frequency |
| `deploy_confirmation_completed` | User selects primary/secondary | `operationId`, `decision` (confirm/cancel), `checklistComplete:boolean`, `suppressToggle:boolean` | `checklistComplete` true if all prerequisites checked |
| `undo_toast_action` | User clicks undo or toast expires | `operationId`, `action` (undo_clicked/timeout/dismissed), `secondsRemaining` | Track trust in undo window |
| `logs_reconnect_clicked` | User attempts manual log reconnect | `hostId`, `buildId`, `retryCount` | Correlate with actual success |

## Funnels & KPIs
1. **Retry Funnel:** `connection_retry_started` → `connection_retry_finished (success)` → `connection_status_changed (connected)`; target success ≥ 85% within 3 attempts.
2. **Offline Continuity:** `connection_status_changed (offline)` → `offline_action_selected (queue_sync)` → `sync_conflict_resolved`; monitor drop-off and resolution time.
3. **Deploy Safety:** `deploy_confirmation_shown` → `deploy_confirmation_completed (confirm)` → `undo_toast_action (undo_clicked/timeout)`; ensure ≥60% of confirmed deploys trigger toast view.

## Data Quality
- All events must include `sessionId`, `userId`, `projectId`, `appVersion`.
- Emit in real time to analytics pipeline (Segment → BigQuery). Fallback to local queue when offline; flush once connected.
- Unit tests in analytics layer to validate schema and required properties.

## Dashboards
- **Reliability Dashboard:** Retry success rate, average attempts per host, offline durations.
- **Productivity Dashboard:** Time spent offline, sync conflict counts, queue size trends.
- **Change Safety Dashboard:** Deploy confirmations vs. undo usage, failure escalation counts.

## Privacy & Compliance
- No PII in event payloads; host names use hashed IDs + friendly alias where needed.
- Retain events for 180 days, then aggregate.
