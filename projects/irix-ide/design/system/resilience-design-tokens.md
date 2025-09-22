# Resilience Design Tokens

Canonical tokens for the remote recovery UI surfaces. Keep values in sync with `docs/front-end-spec.md` and the component spec.

## Color Tokens
| Token | Hex | Usage |
|-------|-----|-------|
| `color.bg.base` | `#0F0F10` | Root app background behind shells |
| `color.bg.surface` | `#1E1E1E` | Primary surface cards, editor chrome |
| `color.bg.panel` | `#2C2C2E` | Overlays, navigation rail, toasts |
| `color.stroke.accent` | `#4C6EF5` | Active outlines, focus rings, progress |
| `color.stroke.muted` | `#3A3A3C` | Divider accents, ghost buttons |
| `color.text.primary` | `#F2F2F7` | Headings, essential labels |
| `color.text.secondary` | `#D1D1D6` | Body copy, helper text |
| `color.text.muted` | `#8E8E93` | Metadata, annotations |
| `color.status.success` | `#34C759` | Connected pill, diff additions |
| `color.status.warning` | `#FFD60A` | Retry banner, pending states |
| `color.status.danger` | `#FF3B30` | Failures, destructive cues |
| `color.status.offline` | `#FF9500` | Offline badge, undo accent |
| `color.status.irixAccent` | `#6699CC` | Native IRIX controls |

## Typography Tokens
| Token | Font | Size | Weight | Line Height |
|-------|------|------|--------|-------------|
| `type.heading.lg` | SF Pro Display / Inter | 24 px | SemiBold | 32 px |
| `type.heading.md` | SF Pro Display / Inter | 20 px | SemiBold | 28 px |
| `type.body.base` | SF Pro Text / Inter | 16 px | Regular | 24 px |
| `type.body.sm` | SF Pro Text / Inter | 14 px | Regular | 20 px |
| `type.mono.sm` | SF Mono / JetBrains Mono | 13 px | Regular | 20 px |

**Fallbacks:** Inter (UI) and Helvetica Neue (IRIX). Maintain anti-aliasing for dark backgrounds.

## Spacing & Radius
- `space.2` = 8 px
- `space.3` = 12 px
- `space.4` = 16 px (default gutter)
- `space.6` = 24 px (card padding)
- `space.8` = 32 px (modal padding)
- Corner radius tokens: `radius.sm` = 8 px (buttons/badges), `radius.md` = 16 px (cards/panels), `radius.lg` = 20 px (modals).

## Elevation & Shadows
| Token | Value | Notes |
|-------|-------|-------|
| `elevation.surface` | 0px 1px 2px rgba(15, 20, 29, 0.35) | Panels, sheets |
| `elevation.modal` | 0px 12px 32px rgba(9, 13, 20, 0.45) | Confirmation sheet, conflict modal |
| `elevation.toast` | 0px 8px 24px rgba(10, 15, 24, 0.4) | Undo toast |

## Motion Tokens
| Token | Value | Applies To |
|-------|-------|------------|
| `motion.duration.fast` | 120 ms | Status pill transitions, button hover |
| `motion.duration.base` | 200 ms | Banners slide in/out, toast entry |
| `motion.duration.slow` | 320 ms | Confirmation sheet expand, modal fade |
| `motion.easing.standard` | cubic-bezier(0.4, 0.0, 0.2, 1) | Default easing for IRIX overlays |
| `motion.easing.decelerate` | cubic-bezier(0.0, 0.0, 0.2, 1) | Retry progress completion |
| `motion.easing.accelerate` | cubic-bezier(0.4, 0.0, 1, 1) | Banner exit on success |

## Content Widths
- Editor column: 700 px max content.
- Log side panel: 236 px fixed.
- Banner width: parent minus 48 px horizontal padding.

## Token Governance
- Tokens live in design assets and should map 1:1 to the frontend theming system (e.g., SCSS/Design Tokens JSON).
- Document changes in PRs referencing this file and the component spec.
