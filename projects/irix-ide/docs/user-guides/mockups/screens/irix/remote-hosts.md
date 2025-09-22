# Remote Hosts – Motif Maintenance View

## Layout Overview
- **Viewport:** 1280×900 Motif window.
- **Tokens:**
  - Background: `color.bg.base` (motif override).
  - Cards and panels: `color.bg.surface` with 2px bevel.
  - Accent/focus: `color.focus.accent` `#6699CC`.
  - Status chips: `color.status.success`, `color.status.warning`, `color.status.offline`.

## Regions
1. **Host List (Left rail, 360px)**
   - Entries use square selection highlight with dotted outline.
   - Context menu accessible via Shift+F10, shows terminal options.

2. **Detail Stack (Center)**
   - Health summary card featuring Motif progress bars for CPU/RAM.
   - Telemetry graph uses Indigo Magic gridlines; tooltip triggered by Space/Enter.
   - Activity log table with alternating row shading.

3. **Process Inspector (Bottom split pane)**
   - Table with columns (PID, Command, CPU%, Memory, Status).
   - Degraded process row uses warning background + icon.

4. **Maintenance Sidebar (Right, 240px)**
   - Buttons for Restart Daemon, Collect Logs, Toggle Offline Mode.
   - Offline guidance text uses `color.text.secondary` and bullet markers.

5. **Alert Banner**
   - When host offline, top-of-window banner with `color.status.offline` background and instructions.

## States Captured
- List selection on degraded host; sidebar buttons partially disabled.
- Telemetry graph showing drop-off plateau; tooltip visible.
- Process inspector flagged row and context actions.
- Offline alert banner with countdown message.

## Annotation Notes
- Highlight telemetry polling interval (10s) and implications for backend streaming alignment.
- Document screen reader labels for process table (announce host + status).
- Note requirement for high-contrast icon variants for IRIX displays.
