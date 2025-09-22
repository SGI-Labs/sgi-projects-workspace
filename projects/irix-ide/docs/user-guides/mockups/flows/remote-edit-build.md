# Remote Edit → Build Flow (Hi-Fi Storyboard)

Link to source screens and components so the mockup exports can be assembled into an interactive walkthrough.

## Step Sequence
1. **Editor – Synced (IRIX)**
   - Source: `../screens/irix/editor-connected.md`
   - Export: `../exports/irix/editor-connected.svg`
   - Annotation: Command palette invocation, status strip synced.

2. **Build Trigger (Quick Action)**
   - Component: `component.shell-rail` + `component.status-pill` (running state).
   - Overlay: `../overlays/deploy-confirmation.md` (countdown variant optional).

3. **Build & Logs – Running**
   - Source: `../screens/irix/build-logs.md`
   - Export: `../exports/irix/build-logs.svg`
   - Highlight streaming log, running row, filter drawer.

4. **Build Failure Drill-down**
   - Use IRIX build logs export with failure toggle; annotate log reconnection banner.
   - Provide callout referencing backend log retention requirement.

5. **Recovery & Retry**
   - Apply `component.toast/status-strip` for retry success message.
   - Document accessible feedback via status strip updates and live region announcements.

## Notes
- Include keyboard shortcut badges in each frame (e.g., `Ctrl+B` run build).
- Capture timing metadata: <30s expectation from edit to build completion.
- Indicate API calls or telemetry events triggered per step for engineers.
