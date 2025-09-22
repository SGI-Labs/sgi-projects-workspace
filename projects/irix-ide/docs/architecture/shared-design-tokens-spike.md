# Spike Plan: Shared Design Tokens (Motif/X11)

## Goal
Create a single source of truth for IRIX IDE visual tokens that can feed the Motif/X11 client and supporting scripts, reducing styling drift and easing accessibility updates.

## Scope
- Inventory existing color, typography, spacing, and component-state tokens from the front-end spec, IRIX Interactive Desktop guidelines, and resilience design kits.
- Identify gaps between current mockups and Motif capabilities (rounded corners, shadow treatments, density) and document required translations.
- Propose a distributable token format (YAML/JSON) and pipeline to generate Motif resource files (`*.ad`) and helper metadata for documentation/tests.
- Prototype the pipeline on a subset of tokens to validate tooling approach.

## Source Materials (Collected)
- `projects/irix-ide/docs/front-end-spec.md` — screen blueprints, palette, typography, spacing, state diagrams.
- `projects/irix-ide/design/system/resilience-design-tokens.md` — canonical recovery workflow tokens (colors, typography, motion, spacing, elevation).
- `projects/irix-ide/design/system/iconography-kit.md` — icon usage patterns aligning with Indigo Magic styling.
- IRIX Interactive Desktop manuals imported under `projects/irix-ide/docs/007-*` — authoritative guidance on colors, icons, and widget behavior.

## Acceptance Criteria
1. Token Inventory Documented: Markdown table capturing token name, value, semantic meaning, and Motif usage.
2. Gap Analysis Completed: Explicit list of conflicts or missing tokens with recommended resolutions or fallback strategies.
3. Distribution Proposal Approved: Description of source-of-truth format, generation tooling, update workflow, and owner assignments.
4. Prototype Artefacts Delivered: Sample generated Motif resource file (`IRIXIDE.generated.ad`) and companion JSON produced from the same token definition, with build steps noted.
5. Follow-up Tasks Logged: Stories or tasks filed for full implementation, including automation, documentation updates, and QA sign-off.

## Work Breakdown
| # | Task | Outputs | Est. Effort |
|---|------|---------|-------------|
| 1 | Gather source materials (front-end spec, design tokens, Motif guidelines) | Collated references, token list draft | 0.5 day |
| 2 | Build token inventory table | Markdown/CSV inventory, coverage metrics | 1 day |
| 3 | Analyze gaps vs. Motif (shadows, animation, fonts) | Gap report with action items | 0.5 day |
| 4 | Evaluate tooling options (Python generator vs. make targets) | Trade-off notes, selected approach | 0.5 day |
| 5 | Prototype generation pipeline | Script or tool config, generated `.ad` output + JSON, usage notes | 1 day |
| 6 | Document recommendations and next steps | Spike summary, backlog follow-ups, success criteria | 0.5 day |

## Milestones & Timeline
- Week 1: Complete Tasks 1–2.
- Week 2: Deliver gap analysis (Task 3) and tooling evaluation (Task 4).
- Week 3: Produce prototype pipeline outputs (Task 5).
- Week 4: Compile spike report and backlog follow-ups (Task 6).

## Risks & Considerations
- Motif lacks modern animation and blur shadows; tokens must translate to light/dark border cues instead of layered shadows.
- Helvetica/Courier availability varies across IRIX installations; typography tokens need fallbacks defined via XLFD.
- Iconography relies on bitmap exports rather than vector assets; pipeline must track asset paths alongside color tokens.
- Accessibility requires contrast validation; integrate contrast checks into the generator to prevent regression.

## Deliverables
- `docs/architecture/token-prototype/tokens.sample.json` updated to reflect canonical values.
- Generation script (`generate_tokens.py`) enhanced to emit Motif resources and validation reports only.
- Spike summary documenting decisions, gaps, and subsequent user stories.
