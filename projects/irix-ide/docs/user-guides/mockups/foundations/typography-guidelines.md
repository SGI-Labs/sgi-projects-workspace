# Typography Guidelines

Map text styles in mockups to the tokenized typographic scale below. Reference tokens live in `projects/irix-ide/docs/architecture/token-prototype/tokens.sample.json`.

| Token | Font (IRIX) | Size | Weight | Line Height | Typical Usage |
|-------|-------------|------|--------|-------------|----------------|
| `typography.heading.lg` | Helvetica | 28 px | Bold | 34 px | Screen titles, modal headers |
| `typography.heading.md` | Helvetica | 22 px | Semibold | 28 px | Section headers, key cards |
| `typography.body.base` | Helvetica | 15 px | Regular | 22 px | Body copy, table cells |
| `typography.body.monoSm` | Courier | 13 px | Regular | 20 px | Logs, code snippets, terminal |

### IRIX Platform Notes
- Ensure Helvetica and Courier XLFD entries exist on target hosts; document fallbacks where fonts are missing.
- Maintain equivalent point sizes where possible to keep visual parity; reduce only if Motif constraints demand it.

### Mockup Tips
- Label text layers with their token ID to aid future implementation.
- Capture leading/tracking differences in annotations if you tweak values for visual balance.
- For multiline annotations or labels, ensure minimum contrast ratio 4.5:1 using the palette tokens.
