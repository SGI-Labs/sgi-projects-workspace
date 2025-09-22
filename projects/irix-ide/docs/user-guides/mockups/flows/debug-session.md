# Remote Debug Session Flow

Document the transition from host selection to active debugging for the IRIX Motif client. Use these references when assembling clickable prototypes or narrated walkthroughs.

## Step Sequence
1. **Remote Hosts – Select Target**
   - Source: `../screens/irix/remote-hosts.md`.
   - Export: `../exports/irix/remote-hosts.svg`.
   - Annotation: Host health, telemetry card, attach debugger CTA.

2. **Deploy Confirmation Overlay**
   - Source: `../overlays/deploy-confirmation.md`.
   - Export: `../exports/overlays/deploy-confirmation.svg`.
   - Notes: confirm countdown + cancel affordance.

3. **Debugger Session – Active**
   - Source: `../screens/irix/debugger-session.md`.
   - Export: `../exports/irix/debugger-session.svg`.
   - Highlight breakpoints, call stack, watch expressions.

4. **Connection Drop Scenario**
   - Use same debugger source with reconnect modal state.
   - Document announcement requirements for IRIX assistive tech (status strip + audible bell).

5. **Session Summary & Export**
   - Outline where logs/traces appear post-session (Build & Logs view).

## Notes
- Track tooltips for each control; include key binding overlay.
- Ensure notifications use status strip rather than floating toast.
- Capture gdbserver attach time target (<10s) in annotations.
