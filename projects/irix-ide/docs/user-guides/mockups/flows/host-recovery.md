# Host Recovery Flow

Visual handoff describing how operators recover an offline IRIX host. Aligns with resilience requirements and ensures Motif shell interactions remain consistent.

## Step Sequence
1. **Dashboard Alert**
   - Source: `../screens/irix/dashboard-default.md` (status strip retry).
   - Export: `../exports/irix/dashboard-default.svg`.
   - Annotation: alert messaging, link to Remote Hosts.

2. **Remote Hosts – Offline Host Selected**
   - Source: `../screens/irix/remote-hosts.md`.
   - Export: `../exports/irix/remote-hosts.svg`.
   - Highlight offline banner, retry controls, troubleshooting link.

3. **Offline Work Drawer / Status Strip**
   - Overlay: `../overlays/offline-work-drawer.md` with drawer + status strip states.
   - Document path for queueing edits while offline.

4. **Recovery Confirmation**
   - Return to dashboard with success pill + status strip success message.

## Notes
- When offline, disable destructive actions; annotate UI states accordingly.
- Provide guidance for telemetry event mapping (reconnect attempts, success).
- Outline screen-reader copy for offline/resolved statuses.
