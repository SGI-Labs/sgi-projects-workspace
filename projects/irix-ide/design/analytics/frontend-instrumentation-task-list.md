# Frontend Instrumentation Tasks – Remote Resilience

**Assignee:** @frontend-lead (delegate to @frontend-dev1 / @frontend-dev2 as needed)
**Target Branch:** `feature/resilience-telemetry`

## Task Breakdown
1. **Event Wiring in Connection Manager**
   - Emit `connection_status_changed` on every state transition with `state`, `hostId`, `reason`.
   - Emit `connection_retry_started` / `connection_retry_finished` around auto-retry loop (include `attempt`, `maxAttempts`, `elapsedMs`).
   - Ensure events queue when offline and flush when back to `Connected`.
2. **Offline Queue Module**
   - Fire `offline_queue_updated` whenever queued file count changes; include `queuedFiles`, `queuedBytes`.
   - Instrument command palette actions with `offline_action_selected` (action label + hostId).
3. **UI Components**
   - `SyncConflictModal`: emit `sync_conflict_resolved` with `action`, `filePath`, `diffLines`, `durationMs`.
   - `DeployConfirmationSheet`: hook `deploy_confirmation_shown` & `deploy_confirmation_completed` (capture checklist state, suppress toggle).
   - `UndoToast`: fire `undo_toast_action` on click/dismiss/timeout.
   - `LogReconnectPanel`: send `logs_reconnect_clicked` with `hostId`, `buildId`, `retryCount`.
4. **Shared Event Helper**
   - Create utility `trackResilienceEvent(name, payload)` to append common fields: `sessionId`, `userId`, `projectId`, `appVersion`, timestamp.
   - Unit tests verifying payload enrichment + offline queue flush.
5. **Storybook & Manual Verification**
   - Add knobs to stories to trigger events and log payloads in console for QA review.
   - Coordinate with analytics to verify events appear in staging Segment feed.

## Definition of Done
- All events present in telemetry snapshot (Segment debugger) with required fields.
- Tests cover success/failure branches for retries, offline queue, undo.
- Documentation updated (`design/analytics/engineering-handoff.md`) with PR links.
