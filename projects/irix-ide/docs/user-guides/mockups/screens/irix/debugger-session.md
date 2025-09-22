# Debugger Session – Motif Variant

## Layout Overview
- **Viewport:** 1280×900.
- **Tokens:**
  - Background: `color.bg.base` (motif).
  - Inspector panels: `color.bg.surface`.
  - Breakpoint markers: `color.status.warning`.
  - Offline/error states: `color.status.offline`, `color.status.danger`.

## Regions
1. **Call Stack Panel (Left, 260px)**
   - List entries with square selection highlight; double-click opens file.
   - Current frame badge uses accent box + bold text.

2. **Code View (Center)**
   - Displays current source with inline variable previews.
   - Breakpoint icon from Indigo Magic set; resolved breakpoints tinted success.
   - Execution arrow uses accent color; margin 16px.

3. **Variable Inspector (Right, 320px)**
   - Tree view with disclosure triangles; value column monospace.
   - Watch expressions section separated by motif etched line.

4. **Console Pane (Bottom, 220px)**
   - gdbserver output using monospace text; error lines tinted danger.
   - Reconnect modal overlays console when session lost.

5. **Control Bar (Top)**
   - Buttons: Continue, Step Over, Step Into, Step Out, Stop.
   - Buttons follow Motif push button style with icon overlays.

## States Captured
- Breakpoint hit in `render.c` line 128 with highlighted arrow.
- Variable inspector showing updated value (highlighted). 
- Console containing warning about network latency.
- Reconnect modal overlay with `Retry` primary button (accent) and `Work Offline` secondary.

## Annotation Notes
- Indicate keyboard shortcuts (F5 continue, F10 step over, etc.).
- Provide guidance for screen reader ordering (call stack → code → inspector → console).
- Note requirement for preserving 60 FPS target despite Motif rendering constraints.
