# Sync Conflict Resolver Overlay

## Purpose
Resolve file conflicts that occur during remote sync operations within the IRIX IDE.

## Layout
- Motif dialog with square corners, etched borders, and title bar icons matching IRIX guidelines.

## Sections
1. **Header** – File path, host badge, timestamp of conflict detection.
2. **Diff Pane** – Side-by-side diff (`component.diff-split-pane`). Include syntax colors and mismatch highlights.
3. **Resolution Options** – Radio buttons: Keep Local, Keep Remote, Open Merge Tool.
4. **Preview Toggle** – Checkbox to preview merged output in new window.
5. **Actions** – Primary button “Apply Resolution”, secondary “Cancel”. Danger style applied when discarding remote changes.

## States
- Default conflict (no selection yet).
- Local selected (enable Apply, show summary).
- Merge tool launching (loading spinner, status text).

## Accessibility Notes
- Focus order: Header → Diff pane → Resolution options → Preview toggle → Actions.
- Announce conflict summary when modal opens.
- Provide diff summary for screen readers (lines changed, file path).

## Export Targets
- `../exports/irix/sync-conflict.svg`
