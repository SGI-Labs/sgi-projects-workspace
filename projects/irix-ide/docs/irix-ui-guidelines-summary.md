# IRIX UI Guidelines Highlights
- Enable the IRIX interactive look with `sgiMode: TRUE` so IRIS IM widgets render smooth beveled components, locate highlight, and distinctive checkbox/radio states expected on IRIX desktops.
- Use schemes (symbolic color/font names) instead of hard-coded values; default palette is neutral gray + Helvetica, and users can swap schemes through the Desktop Customize tools.
- Desktop icons follow strict anatomy: distinctive symbol, black outline, drop shadow, label, plus animated “magic carpet” base for executables; design to be legible at ~50×50 px and register behavior via File Typing Rules.
- Windows should map to IRIX categories (main, co-primary, support, dialog), respect 4Dwm focus behavior, supply required window-menu options, and provide clear minimized-window art/titles for multi-desk workflows.
- Controls leverage IRIS IM enhancements: grouped right-justified dialog buttons, integrated scrollbar grips, hover highlight, and clean menu mnemonics; pushbuttons, toggles, lists, and text fields should match documented feedback patterns.
- Interaction rules: left button for primary actions, middle reserved for paste/advanced shortcuts, right for context menus; drag-and-drop and clipboard/primary selection models must both work, with appropriate pointer cues.
- 3D or advanced views should map navigation/editing to mouse buttons plus modifiers, offer consistent pointer shapes, and resize viewports gracefully.
- Implementation guidance: rebuild against current IRIS IM, use scheme map files for colors/fonts, and follow IRIX integration docs for resource definitions, icon catalogs, and session management.
