# Editor – Connected State (IRIX Motif Variant)

## Layout Overview
- **Viewport:** 1280×900 inside Motif workspace frame.
- **Tokens:**
  - Background: `color.bg.base` (motif override).
  - Editor surface: `color.bg.surface`.
  - Splitter + gutters: `color.bg.panel`.
  - Accent/focus: `color.focus.accent` (motif `#6699CC`).

## Regions
1. **Menu + Toolbar**
   - Traditional Motif menu bar with accelerators (Alt shortcuts).
   - Toolbar uses 22px monochrome icons; toggles render depressed state when active.

2. **Project Explorer (Left panel, 300px)**
   - Tree nodes use square disclosure triangles.
   - Sync badges utilize solid square with tokenized color fill.

3. **Code Editor Pane (Center)**
   - Text style: Helvetica Medium 15px; spacing 18px line height.
   - Active line highlight uses `color.focus.accent` at 20% opacity.
   - Inline diagnostics appear in gutter with motif icon glyph.

4. **Terminal Drawer (Bottom, 260px)**
   - Background `color.bg.panel`; text `typography.body.monoSm` (Courier 13px).
   - Connection status row uses `color.status.success` for “Connected to octane”.

5. **Command Palette Overlay**
   - Modal sheet anchored center with Motif border + title strip.
   - Search field uses square focus highlight; quick actions listed below with accelerator labels.

6. **Status Strip (Bottom)**
   - Shows host, branch, sync state; offline icon tinted `color.status.offline` when triggered.

## States Captured
- Editor connected, status strip idle.
- Command palette open with keyboard focus on search field.
- Project explorer node showing pending sync (warning badge).
- Terminal drawer streaming logs with ANSI color placeholders for investigation.

## Annotation Notes
- Document ANSI rendering expectations and ensure token coverage for colorized logs.
- Identify fallback fonts for Japanese locales (Osaka) if Helvetica unavailable.
- Clarify keyboard focus order (Menu → Toolbar → Explorer → Editor → Terminal → Status strip).
