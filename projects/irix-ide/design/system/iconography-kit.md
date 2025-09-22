# Iconography Kit: Remote Resilience

## Overview
Defines key icons required for connection feedback, recovery actions, and destructive affordances. Export assets as 24×24 SVG with monochrome fills.

## Required Icons
| Name | Purpose | Notes |
|------|---------|-------|
| `icon-connection` | Displays current connection status alongside status pill | Change fill color per state (success/warning/danger) |
| `icon-retry` | Inline button for manual retry | Rotating arrow; Motif pixmap variant `icons/retry.xbm` |
| `icon-offline` | Indicates queued offline edits | Combine plug + slash motif, referenced in offline badge |
| `icon-host` | Represents remote host machine | Outline of workstation; used in host list and banners |
| `icon-warning` | Highlights destructive or cautionary messages | Triangle variant mirroring Indigo Magic style |
| `icon-diff-add` | Diff addition highlight for conflict modal | Plus inside square, tinted `color.status.success` |
| `icon-diff-remove` | Diff removal highlight for conflict modal | Minus inside square, tinted `color.status.danger` |
| `icon-undo` | Undo toast action | Curved arrow left |
| `icon-logs` | Link back to build logs | Scroll/paper icon |

## Production Checklist
- Export to `resources/icons/resilience/` as optimized SVG (no extra metadata, stroke-width 1.5).
- Provide `@2x` PNG versions for legacy IRIX builds if vector pipeline unavailable.
- Include symbol definitions in Storybook component library for quick testing.

## Next Steps
- When icons are created, add thumbnail previews and usage guidelines to this file.
- Align with engineering to confirm naming conventions match sprite sheet or code module.
