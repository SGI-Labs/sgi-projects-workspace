# Journey Map: Remote Edit & Recovery Loop

## Overview
- Persona: Mac-First IDE Operator (primary)
- Scenario: Editing code on macOS client while targeting IRIX host; experiences connection loss and recovery.
- Goal: Maintain momentum with minimal context loss and clear guidance during remote instability.

## Lifecycle Phases

| Phase | User Actions | System Touchpoints | Thoughts & Emotions | Pain Points | Opportunities | Key Metrics |
|-------|--------------|---------------------|---------------------|-------------|---------------|-------------|
| Setup & Focus | Opens project, connects to target host, begins editing files | Dashboard, Status Pill (`Connected`), Editor | “Everything looks synced; let’s ship quickly.” | Potential doubt about remote state | Reinforce connection confidence with stable iconography | Time-to-connect, host uptime indicator |
| Save & Sync | Saves file, triggers auto-sync | Status Pill -> `Connected`, Toast on success | “Great, sync is instant.” | None at baseline | Surface diff preview for confirmation (optional) | Sync latency, success rate |
| Host Drop | Notices log stream stalls, status flips to `Degraded`, host drop banner appears | Connection Banner (`Host Drop`), disabled build/deploy buttons | “Why did the host disappear? Is my work safe?” | Anxiety around losing progress; confusion about next step | Provide troubleshooting link + reassure local queue | Time-to-first notification, banner comprehension |
| Automatic Retry | Watches retry banner count attempts; progress bar updates | Connection Banner (`Retrying`), Status Pill (`Reconnecting`), Log Panel skeleton | “Okay, it’s trying—hope it succeeds fast.” | Lack of control if retries fail silently | Allow cancel/host switch inline; show attempt ETA | Retry success rate, user cancellation frequency |
| Offline Editing | Continues editing; sees unsynced badge, command palette highlights offline actions | Offline Badge, Command Palette overlay | “I can keep working, but I should plan a sync.” | Fear of merge conflicts; uncertainty about queue visibility | Queue Sync CTA, access to offline diff summary | Number of queued changes, offline duration |
| Conflict Resolution | On reconnect, conflict modal surfaces with diff options | Sync Conflict Modal, Merge Tool | “Need to choose carefully—I’ll preview diff.” | Overwhelm if diff large | Offer “Open Merge Tool” fallback, highlight recommended option | Conflict resolution time, post-merge errors |
| Recovery Complete | Status returns to `Connected`, resolved toast directs to logs | Resolved Toast, Status Pill (`Connected`), Build logs resume | “Back on track. Let me review what happened.” | Hard to locate relevant logs post-recovery | Direct link to resumed logs, recovery summary in activity feed | Successful completion of workflow, NPS after incident |
| Deploy & Undo | Initiates deploy; confirmation sheet requires checklist review; undo toast appears post-action | Confirmation Sheet, Undo Toast | “Safety net is there, I can rollback if needed.” | Timer anxiety; concern about missing undo window | Pause countdown on focus, provide escalation instructions | Undo usage rate, errors in destructive flow |

## Experience Highlights
- **Moments of Truth:** Host drop detection, offline editing guidance, conflict resolution clarity, destructive action reversal.
- **Emotional Curve:** Confidence → Concern → Cautious optimism → Relief.

## Supporting Requirements
- Connection events must emit analytics for retry duration and outcomes.
- Sync manager logs conflict details for QA follow-up.
- Activity feed aggregates recovery events for team visibility.

## Next Research Moves
- Validate banner comprehension via quick unmoderated test (copy clarity).
- Observe users handling large diffs (>200 lines) to refine conflict modal thresholds.
- Measure how often undo is invoked vs. ignored to calibrate timer length.
