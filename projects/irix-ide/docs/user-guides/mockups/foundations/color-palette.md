# Color Palette Cheatsheet

Use this table when building mockups to keep token usage consistent across IRIX variants. Hex values come directly from the token prototype (`projects/irix-ide/docs/architecture/token-prototype/tokens.sample.json`).

| Token | Hex | Usage Notes |
|-------|-----|-------------|
| `color.bg.base` | `#4F5B66` | Motif desktop base |
| `color.bg.surface` | `#5E6B7A` | Primary panels, editor chrome |
| `color.bg.panel` | `#3B4654` | Navigation rail, secondary surfaces |
| `color.focus.accent` | `#6699CC` | Focus rings, active tabs |
| `color.text.primary` | `#F2F2F7` | Primary text on dark backgrounds |
| `color.text.secondary` | `#D0D8E2` | Supporting text, metadata |
| `color.status.success` | `#94D55A` | Build success, synced states |
| `color.status.warning` | `#FFD454` | Pending/at-risk indicators |
| `color.status.danger` | `#FF6B6B` | Failed builds, destructive actions |
| `color.status.offline` | `#FFA94D` | Offline/resilience banners |

When rendering mockups, annotate swatches or style layers with the token ID rather than the raw hex to keep linkage back to the source of truth.
