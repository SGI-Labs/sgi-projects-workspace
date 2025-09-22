# Token Reference (Foundations)
Source: `projects/irix-ide/docs/architecture/token-prototype/tokens.sample.json`
## Color Tokens
### Bg
| Token | Value | Platform Overrides | Description |
|-------|-------|--------------------|-------------|
| `color.bg.base` | `#0F0F10` | motif: #4F5B66 | App background |
| `color.bg.surface` | `#1E1E1E` | — | — |
| `color.bg.panel` | `#2C2C2E` | — | — |

### Focus
| Token | Value | Platform Overrides | Description |
|-------|-------|--------------------|-------------|
| `color.focus.accent` | `#4C6EF5` | motif: #6699CC | — |

### Text
| Token | Value | Platform Overrides | Description |
|-------|-------|--------------------|-------------|
| `color.text.primary` | `#F2F2F7` | — | — |
| `color.text.secondary` | `#8E8E93` | — | — |

### Status
| Token | Value | Platform Overrides | Description |
|-------|-------|--------------------|-------------|
| `color.status.success` | `#34C759` | — | — |
| `color.status.warning` | `#FFD60A` | — | — |
| `color.status.danger` | `#FF3B30` | — | — |
| `color.status.offline` | `#FF9500` | — | — |
| `color.status.irixAccent` | `#6699CC` | — | — |

## Spacing Tokens
| Token | Value | Unit | Platform Overrides |
|-------|-------|------|--------------------|
| `spacing.4` | `16` | `px` | motif: scale=0.75 |

## Radius Tokens
| Token | Value | Platform Overrides |
|-------|-------|--------------------|
| `radius.sm` | `8` | motif: 2 |

## Typography Tokens
### Heading
| Token | Font | Size | Weight | Line Height | Platform Overrides |
|-------|------|------|--------|-------------|--------------------|
| `typography.heading.lg` | `SF Pro Display` | `28` | `bold` | `34` | motif: fontFamily=Helvetica, fontSize=28 |
| `typography.heading.md` | `SF Pro Display` | `22` | `semibold` | `28` | motif: fontFamily=Helvetica, fontSize=22 |

### Body
| Token | Font | Size | Weight | Line Height | Platform Overrides |
|-------|------|------|--------|-------------|--------------------|
| `typography.body.base` | `SF Pro Text` | `15` | `regular` | `22` | motif: fontFamily=Helvetica, fontSize=15 |
| `typography.body.monoSm` | `SF Mono` | `13` | `regular` | `20` | motif: fontFamily=Courier, fontSize=13 |

## Icon Tokens
| Token | Value | Platform Overrides |
|-------|-------|--------------------|
| `icon.warning` | `exclamationmark.triangle.fill` | motif: assets/warning.xbm |
