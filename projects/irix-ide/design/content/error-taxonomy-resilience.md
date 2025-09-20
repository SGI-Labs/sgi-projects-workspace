# Error Taxonomy: Remote Resilience

Classification of errors surfaced during remote development and guidance for messaging + routing.

## Categories
| Code | Name | Description | User-Facing Guidance | Telemetry Tag |
|------|------|-------------|----------------------|---------------|
| NET-001 | Connection Timeout | IDE cannot reach remote host within SLA (15s) | Trigger `Lost connection` banner, auto-retry up to 3 times | `error.connection.timeout` |
| NET-002 | Authentication Failure | SSH auth rejected due to key mismatch or expired credentials | Show modal prompting re-auth; link to credential doc | `error.connection.auth` |
| NET-003 | Host Maintenance | Host marked unavailable by ops | Display read-only banner with ETA; disable destructive actions | `error.connection.maintenance` |
| SYNC-101 | Sync Conflict | Remote file changed during offline editing | Launch conflict modal with diff preview | `error.sync.conflict` |
| SYNC-102 | Sync Permission Denied | Missing write access on remote directory | Provide troubleshooting link, surface contact info | `error.sync.permission` |
| BUILD-201 | Build Queue Saturated | Remote build agent backlog > threshold | Notify in Build & Logs view, suggest switching host | `error.build.queue` |
| BUILD-202 | Build Failed (Remote) | Latest build returned non-zero exit | Show diagnostics panel with jump-to-source | `error.build.failure` |
| DEPLOY-301 | Deploy Blocked | Deploy prevented by policy or environment mismatch | Confirmation sheet highlights blocker, provide contact | `error.deploy.blocked` |
| DEPLOY-302 | Undo Unavailable | Rollback window expired or operation irreversible | Toast update `Undo no longer available` and link to manual rollback doc | `error.deploy.undo_unavailable` |

## Severity Bands
- **Critical:** NET-001/002, DEPLOY-301 (blocks development or risks environment). Requires red accents, log escalation, optional pager alert.
- **High:** SYNC-101/102, BUILD-201 (impacts productivity). Use warning styling, prompt alternate actions.
- **Medium:** BUILD-202, DEPLOY-302 (non-blocking but needs attention). Provide follow-up instructions.

## Logging Requirements
- Include `hostId`, `projectId`, `attempt`, and `elapsedMs` for all connection-related errors.
- For conflicts, log `filePath`, `localCommit`, `remoteCommit`.
- For deploy/undo errors, capture `operationId`, `initiatedBy`, `rollbackAvailable:boolean`.

## Support Handoff
- Map codes to support runbook steps (see `design/ops/runbook-resilience.md` once available).
- Ensure error codes surface in activity feed for audit trail.
