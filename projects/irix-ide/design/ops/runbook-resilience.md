# Ops Runbook Excerpt: Remote Resilience UI

## Purpose
Guide support/operations teams when users report connection instability while using the IRIX IDE.

## Quick Decision Tree
1. **User sees `Lost connection` banner**
   - Check host status in monitoring (Grafana dashboard `irix-host-health`).
   - If host healthy, ask user to trigger `Retry` and collect timestamp + hostId.
   - If host degraded, notify infra on-call and suggest user switch to standby host.
2. **Retries Exhausted / Offline**
   - Confirm network path (VPN, firewall) for user. If widespread, post status update.
   - Provide offline guidance doc (link: `/docs/support/offline-work.md`).
3. **Sync Conflict Reports**
   - Request conflict modal screenshot and diff snippet.
   - If merge tool fails, escalate to SCM team with file path + commits.
4. **Undo Issues**
   - If undo window missed, direct to manual rollback command `deploy rollback --last`.

## Data to Capture in Tickets
- Username, project, hostId, time of incident.
- Connection state transitions (from activity feed screenshots).
- Event IDs from analytics (if available).

## Communication Templates
- **Slack Update:** “Team, host `<hostId>` experiencing degraded connectivity. IDE auto-retries. ETA `<eta>`.”
- **Status Page:** “IRIX IDE remote builds: Intermittent disconnects. Users can continue offline; queued changes will sync automatically once restored.”

## Escalation
- Infra on-call if >3 users impacted or retries fail for 10 minutes.
- SCM team if conflicts exceed threshold (≥5 in 30 minutes).

## Post-Incident
- Collect analytics (`connection_retry_*`, `offline_queue_updated`).
- File findings in `design/research/resilience-findings-log.md`.
