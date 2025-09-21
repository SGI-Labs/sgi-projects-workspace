# Spike Plan: Shared Design Tokens (SwiftUI + Motif/X11)

## Goal
Create a single source of truth for IRIX IDE visual tokens that can feed both the macOS SwiftUI client and Motif/X11 shells, reducing styling drift and easing accessibility updates.

## Scope
- Inventory existing color, typography, spacing, and component-state tokens from the front-end spec, IRIX Motif guidance, and resilience design kits.
- Identify platform gaps/conflicts (rounded corners, shadow treatments, density) and document required translations or fallbacks.
- Propose a distributable token format (YAML/JSON) and pipeline to generate SwiftUI theming assets and Motif resource files.
- Prototype the pipeline on a small subset of tokens to validate tooling approach.

## Source Materials (Collected)
- `projects/irix-ide/docs/front-end-spec.md` — screen blueprints, palette, typography, spacing, state diagrams.
- `projects/irix-ide/design/system/resilience-design-tokens.md` — canonical recovery workflow tokens (colors, typography, motion, spacing, elevation).
- `projects/irix-ide/design/system/iconography-kit.md` — icon usage patterns aligning with Indigo Magic styling.
- `projects/irix-ide/docs/prd.md#uiux-stylistic-guidelines` — narrative guidance on macOS vs. IRIX styling expectations.
- External reference needed: SGI Motif/Indigo Magic style guide (pending acquisition; note in dependencies).

## Acceptance Criteria
1. Token Inventory Documented: Spreadsheet or markdown table capturing token name, value, semantic meaning, and current platform usage (SwiftUI, Motif).
2. Gap Analysis Completed: Explicit list of conflicts or missing tokens with recommended resolutions or fallback strategies.
3. Distribution Proposal Approved: Description of source-of-truth format, generation tooling, update workflow, and owner assignments.
4. Prototype Artefacts Delivered: Sample generated SwiftUI struct and Motif resource file produced from the same token definition, with build steps noted.
5. Follow-up Tasks Logged: Stories or tasks filed for full implementation, including automation, documentation updates, and QA sign-off.

## Work Breakdown
| # | Task | Outputs | Est. Effort |
|---|------|---------|-------------|
| 1 | Gather source materials (front-end spec, design tokens, Motif guidelines) | Collated references, token list draft | 0.5 day |
| 2 | Build token inventory table | Markdown/CSV inventory, coverage metrics | 1 day |
| 3 | Analyze platform gaps and map resolutions | Gap report with action items | 0.5 day |
| 4 | Evaluate tooling options (manual scripts vs. build integration) | Trade-off notes, selected approach | 0.5 day |
| 5 | Prototype generation pipeline | Script or tool config, generated SwiftUI & Motif outputs, usage notes | 1 day |
| 6 | Document recommendations and next steps | Spike summary, backlog entries, success criteria | 0.5 day |

## Milestones & Timeline
- Week 1: Complete Tasks 1–2.
- Week 2: Deliver gap analysis (Task 3) and tooling evaluation (Task 4).
- Week 3: Produce prototype pipeline outputs (Task 5).
- Week 4: Compile spike report and backlog follow-ups (Task 6).

## Risks & Mitigations
- **Platform Divergence:** SwiftUI and Motif may not support identical token semantics. Mitigate by defining platform-specific transformers within the pipeline.
- **Tooling Complexity:** Automation might need custom scripts. Start with a simple CLI prototype before integrating into build systems.
- **Maintenance Ownership:** Without a clear owner tokens may drift. Assign ongoing stewardship in the follow-up tasks.

## Dependencies
- `projects/irix-ide/docs/front-end-spec.md`
- `projects/irix-ide/design/system/resilience-design-tokens.md`
- Motif/Indigo Magic styling references (existing team notes or external documentation)
- SwiftUI theming module entry points (codebase references TBD)

## Initial Token Inventory (Draft)
| Token ID | Semantic | Value | Source | SwiftUI Usage | Motif/X11 Notes |
|----------|----------|-------|--------|---------------|-----------------|
| `color.bg.base` | App background | `#0F0F10` | resilience-design-tokens.md | `Color("bgBase")` root background | Override to slate `#4F5B66` so Motif shells remain legible |
| `color.bg.surface` | Primary surface | `#1E1E1E` | resilience-design-tokens.md | Editor chrome, cards | Verify contrast vs. Motif neutral grays |
| `color.bg.panel` | Secondary surface | `#2C2C2E` | resilience-design-tokens.md | Navigation rail, overlays | Consider Motif pixmap to emulate depth |
| `color.focus.accent` | Focus/active outline | `#4C6EF5` | resilience-design-tokens.md | Focus rings, active tabs | Transform to Indigo Magic blue on Motif |
| `color.text.primary` | Primary text | `#F2F2F7` | resilience-design-tokens.md | Default foreground | Bind to `XtNforeground`; pass WCAG 4.5:1 |
| `color.text.secondary` | Secondary text | `#8E8E93` | resilience-design-tokens.md | Metadata copy | Requires contrast audit on slate background |
| `color.status.success` | Success state | `#34C759` | resilience-design-tokens.md | Build success pills | Confirm Motif colormap supports vivid green |
| `color.status.warning` | Warning state | `#FFD60A` | resilience-design-tokens.md | Retry banners, pending states | Adjust brightness for CRT readability |
| `color.status.danger` | Error/destructive | `#FF3B30` | resilience-design-tokens.md | Failure states, destructive buttons | Meets dark-surface contrast |
| `color.status.offline` | Offline indicator | `#FF9500` | resilience-design-tokens.md | Offline badge, undo toast | Align with amber LED metaphor |
| `color.status.irixAccent` | IRIX accent | `#6699CC` | front-end-spec.md | IRIX-native accents | Used as default focus on Motif |
| `spacing.s4` | Default gutter | 16 px | resilience-design-tokens.md | Panel spacing | Motif transformer scales by 0.75 → 12 px |
| `radius.sm` | Button corner radius | 8 px | resilience-design-tokens.md | Buttons, pills | Clamp to 2 px for Motif square widgets |
| `type.heading.lg` | Primary heading | 28 px / Bold | front-end-spec.md | `Font.custom("SF Pro Display", 28)` | Map to Helvetica Bold 28px via XLFD |
| `type.heading.md` | Section heading | 22 px / Semibold | front-end-spec.md | Section headers | Map to Helvetica 22px semibold |
| `type.body.base` | Body copy | 15 px / Regular | resilience-design-tokens.md | Standard body text | Motif: Helvetica 15px regular |
| `type.body.monoSm` | Mono body | 13 px / Regular | resilience-design-tokens.md | Logs, diff panes | Motif: Courier 13px fallback |
| `icon.warning` | Caution icon | `exclamationmark.triangle.fill` | iconography-kit.md | SF Symbol mapping | Provide Motif pixmap `warning.xbm` |

**Coverage snapshot:** 17 tokens captured (10 colors, 4 typography, 1 spacing, 1 radius, 1 icon). Outstanding: stroke/outline tokens, additional spacing scales, elevation shadows, motion timings, broader icon set.

## Interim Gap Analysis
| Area | Conflict / Gap | Impact | Proposed Resolution |
|------|----------------|--------|---------------------|
| Color: Background Base | Motif default background is light gray, conflicting with dark token `#0F0F10`. | Without override IRIX panes become unreadable mix of light/dark. | Introduce platform transformer that maps `color.bg.base` to Motif-compatible slate (`#4F5B66`) while retaining macOS dark token; document requirement for per-platform overrides. |
| Color: Focus Accent | macOS uses `#4C6EF5`, IRIX spec prefers `#6699CC`. | Inconsistent focus cues degrade platform trust. | Token source remains semantic (`focus.accent`); pipeline emits macOS `#4C6EF5` and Motif `#6699CC` variants based on target. |
| Typography: SF Pro | SF Pro fonts unavailable on IRIX. | Font fallback required to avoid rendering issues. | Map typography tokens to platform-specific font stacks (SF Pro → Helvetica Neue on macOS fallback; Helvetica on IRIX via XLFD). |
| Spacing: `space.4` 16px | Motif standard spacing closer to 12px. | IRIX UI may feel too roomy vs. native apps. | Allow per-platform scaling multiplier (e.g., 0.75) when generating Motif spacing constants; ensure accessibility min hit targets still met. |
| Radius Tokens | Motif widgets are square/shallow radius. | Rounded corners look alien in native IRIX context. | Provide transformer that clamps `radius.sm`/`radius.md` to 2px/0px for Motif outputs while keeping macOS values. |
| Motion Tokens | Motif stack lacks animation support. | Duration/easing tokens unused, potential confusion. | Treat motion tokens as macOS-only; annotate pipeline to skip animation constants for Motif, use instant state change guidelines. |
| Iconography | SF Symbols have no Motif equivalent. | Missing icons on IRIX builds. | Require bitmap/pixmap exports from design team; pipeline maps token to asset path (macOS SF Symbol name, IRIX `*.xbm`). |
| Elevation/Shadows | macOS uses blur shadows; Motif relies on embossed borders. | Shadow tokens may not render as intended. | During generation, convert elevation tokens to Motif cues (light/dark border pairs). Need additional token definitions for border colors. |
| Accessibility Contrast | Dark palette needs verification on CRT displays with Motif. | Potential legibility issues. | Add contrast test step to pipeline; consider alternate light theme tokens for IRIX if contrast fails. |
| Layout Width | macOS 700px content width may not fit IRIX window defaults. | Horizontal scrolling or clipped panes. | Parameterize layout tokens per platform; gather IRIX window metrics to determine proper defaults. |

### Next Steps for Gap Analysis
- Validate Motif spacing, color, and font assumptions with actual reference docs once sourced.
- Expand gap table to include elevation, accessibility tokens, and any missing icons once inventory extends to remaining tokens.
- Draft transformation rules in pseudocode to feed into tooling evaluation (Task 4).

## Tooling Evaluation (Draft)
| Option | Pros | Cons | Notes |
|--------|------|------|-------|
| **Custom script (Python/Swift CLI)** | Full control over platform transformers; minimal dependencies; easy to integrate into existing build scripts. | Requires bespoke maintenance; need to replicate token validation/testing manually. | Prototype using Python + `jinja2` for emitting Swift structs and Motif resource files; allow future port to Swift if deployment prefers pure Apple tooling. |
| **Style Dictionary (Node.js)** | Mature ecosystem for multi-platform token generation; built-in transforms and formatters; good plugin model. | Adds Node dependency to pipeline; may not ship easily on IRIX; custom Motif formatter required. | Could host master tokens in JSON/YAML and generate Swift + custom Motif output; evaluate license/compatibility. |
| **Theo / Amazon Design Token Framework** | Similar benefits to Style Dictionary; strong transform layer. | Same dependency footprint; less community momentum recently. | Possibly redundant if Style Dictionary selected; keep as fallback. |
| **Swift Package + Xcode Build Phase** | Leverages Swift data models to compile tokens directly into app; fits macOS tooling. | Harder to share with Motif/X11 toolchain; requires parallel pipeline for IRIX outputs. | Could be consumer layer after tokens generated via shared JSON; not ideal as primary generator. |

### Recommended Direction
- Continue evolving the Python generator as the canonical transformer (simpler runtime story for macOS + IRIX build hosts).
- Enhance transformer rules inside the script:
  - Color overrides per platform (already applied for background/focus/status tokens).
  - Spacing multiplier + radius clamps for Motif density alignment.
  - Typography mapping to platform-specific font stacks (SwiftUI custom fonts, Motif XLFD).
  - Icon remapping from SF Symbol identifiers to bitmap asset paths.
- Emit outputs:
  - SwiftUI: `Tokens.generated.swift` struct with color/spacing/typography/icon accessors.
  - Motif/X11: `IRIXIDE.generated.ad` app-defaults file consumed by Motif shells.
- Validation steps: embedded color syntax + contrast checks (in place) with future expansion to asset existence and token coverage tests.

### Action Items
1. Spike Style Dictionary locally with subset tokens; confirm transform hooks for Motif output.
2. Draft JSON schema for token definitions including platform overrides.
3. Investigate availability of Node runtime on IRIX build hosts; if blocked, fall back to Python custom generator.

## Prototype Outputs
- **Source Sample:** `projects/irix-ide/docs/architecture/token-prototype/tokens.sample.json` demonstrates token format with platform overrides.
- **SwiftUI Output (sample/manual):** `.../Tokens.sample.swift` illustrates expected `Tokens` struct mapping colors, spacing, radius, typography, and icons.
- **Motif Output (sample/manual):** `.../IRIXIDE.sample.ad` captures equivalent app-defaults entries (backgrounds, spacing, radius, font, icon pixmap).
- **Automation Script:** `.../generate_tokens.py` consumes the JSON and emits consolidated outputs `Tokens.generated.swift` and `IRIXIDE.generated.ad`, validating transform logic without external dependencies.
- **Automation Script:** `.../generate_tokens.py` consumes the JSON and emits consolidated outputs `Tokens.generated.swift` and `IRIXIDE.generated.ad`, validating transform logic without external dependencies. Script now supports CLI arguments, basic color validation, contrast checks, and Motif-specific naming/transform rules (spacing scaler, font XLFD mapping, icon lowercasing).
- **Unit Tests:** `.../test_generate_tokens.py` covers Swift/Motif generation, validations, and CLI path handling; executed via `python -m unittest discover projects/irix-ide/docs/architecture/token-prototype`.
- Next step: decide whether to wrap this script inside Style Dictionary or continue enhancing custom generator; both options now grounded by working prototype outputs.

## Recommended Backlog Tasks
1. **Finalize Python generator:** Harden existing script with unit tests, packaging, and CI integration; ensure it supports full token set and platform transforms without external dependencies.
2. **Expand Token Coverage:** Extend inventory to include elevation shadows (Motif border mappings), accessibility cues, additional icon variants, and typography for secondary text; update JSON and generator accordingly.
3. **Automate Contrast & Validation Checks:** Add scripts to verify WCAG contrast across tokens for both platforms and ensure required Motif assets exist.
4. **Consumer Integration:** Wire the generated Swift code into the macOS theming layer and define Motif resource inclusion process (build scripts, deployment instructions).
5. **Documentation & Ownership:** Publish workflow in `docs/architecture` detailing how to update tokens, regenerate outputs, and review diffs; assign maintenance owner for ongoing updates.
