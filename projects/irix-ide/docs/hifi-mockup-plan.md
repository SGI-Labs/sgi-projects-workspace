# High-Fidelity Mockup Execution Plan

## Objective
Produce a cohesive set of high-fidelity mockups for the IRIX IDE that align with the approved UI/UX blueprint, satisfy Story 1.4 follow-ups, and provide engineering-ready references for component development across IRIX Motif surfaces.

## Tooling & Sources
- **Primary mockup workflow:** Repository-managed vector/bitmap files (SVG/PNG) stored under `projects/irix-ide/docs/user-guides/mockups/`; author using preferred local tooling (Illustrator, Inkscape, etc.).
- **Token reference:** `projects/irix-ide/docs/architecture/token-prototype/` and resilience design kit assets.
- **Component inventory:** `projects/irix-ide/docs/front-end-component-inventory.md` (treat as authoritative for reusable components).
- **Blueprint baseline:** `projects/irix-ide/docs/front-end-spec.md` (wireframes, flows, state diagrams).

## Deliverable Checklist
- [ ] Repository-based source files for each major view (`Dashboard`, `Editor`, `Remote Hosts`, `Build & Logs`, `Debugger`, `Settings`).
- [ ] Shared component templates (symbols/masters) aligned with the inventory for reuse across files.
- [ ] Critical states per screen captured (see Screen Matrix below).
- [ ] Exported PNG/SVG snapshots saved under `projects/irix-ide/docs/user-guides/mockups/exports/` mirroring source file names.
- [ ] Annotation layer describing interactions, accessibility cues, and token usage.
- [ ] Review notes logged after stakeholder walkthrough.

## Screen Matrix & State Coverage
| Screen | Mandatory States | Notes |
|--------|------------------|-------|
| Dashboard | Default metrics, Warning card, Status strip notification | Illustrate activity feed + quick actions |
| Editor | Connected/synced, Offline pending sync, Deploy confirmation overlay, Diff view | Highlight command palette invocation and diagnostics panel |
| Remote Hosts | Host list (mixed health), Host detail with processes, Retry countdown | Include palette alignment with Indigo Magic |
| Build & Logs | Queue with running build, Failure log with diagnostics, Filtered history | Show log reconnection banner + copy controls |
| Debugger | Breakpoint hit, Variable inspector open, Lost connection modal | Depict gdbserver attach flow |
| Settings | Appearance tab, Key bindings tab, Theme preview panel | Showcase scheme toggles and restart banner |
| Modals/Sheets | Deploy confirmation, Sync conflict resolver, Offline work drawer | Provide component-focused frames |

## File Organization
- **Source Directory Structure:**
  1. `foundations/` – Token swatches, typography guides, icon references.
  2. `components/` – Master component files per inventory family.
  3. `flows/` – Annotated user flows composed from high-fidelity frames.
  4. `screens/irix/` – IRIX hi-fi frames.
  5. `overlays/` – Modals, toasts, banners, offline drawers, and other transient states.

- **Export Directory:** `projects/irix-ide/docs/user-guides/mockups/exports/<section>/<frame-name>.svg`

## Annotation Standards
- Use annotation layers or sidecar markdown files referencing spec sections (e.g., `Spec §3.1`).
- Include inline color/token tags (e.g., `token: color.status.degraded`).
- Label interactive controls with keyboard shortcuts and status-strip messaging.
- Document motion behavior referencing `projects/irix-ide/docs/front-end-spec.md#animation--micro-interactions`.

## Review Workflow
1. Designer prepares `foundations/` and `components/` source files using token JSON as reference.
2. Create initial IRIX hi-fi screen files; review internally with design + product.
3. Conduct cross-functional review (design, product, engineering, QA). Capture notes in review log (see template below).
4. Update Story 1.4 change log or successor story with review outcomes and links to assets.

### Review Log Template
```
| Date | Participants | Scope | Decisions | Follow-ups |
|------|--------------|-------|-----------|------------|
```

## Timelines & Milestones (Suggested)
- **Week 1:** Foundations + Component source files ready for review.
- **Week 2:** Core hi-fi screens (Dashboard, Editor, Build & Logs) completed.
- **Week 3:** Remaining screens + modals; annotate flows.
- **Week 4:** Export assets + document annotations.
- **Week 5:** Stakeholder review & iteration; deliver final exports.

## Risks & Mitigations
- **Token drift:** Lock token references via shared styles; cross-check with generator outputs weekly.
- **Variant divergence:** Schedule joint review when introducing new telemetry states to ensure parity.
- **Performance considerations:** Validate heavy panels (logs, debugger) with actual data density to prevent unrealistic layouts.
- **Tooling access:** Confirm all stakeholders have access to chosen mockup tooling ahead of component reviews.

## Hand-off Requirements
- Export manifest listing frame → file mapping.
- Embed prototype links (if applicable) for flows demonstrating micro-interactions.
- Align with engineering to tag component stories based on inventory coverage.
- Archive review feedback and resolution status in project knowledge base.

## Next Actions
1. Establish repository directories (`projects/irix-ide/docs/user-guides/mockups/...`) and invite stakeholders to shared storage/workflow.
2. Build `foundations/` source file referencing component inventory and token exports.
3. Schedule mid-sprint review to inspect first set of hi-fi frames.
