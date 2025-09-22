# Backend Coordination Plan – UI/UX Blueprint Follow-ups

Capture the cross-functional actions required to resolve the backend dependencies uncovered while preparing the hi-fi mockups.

## Participants
- **James (Frontend Lead):** Owns design handoff + token integration.
- **Mia (Backend Lead):** Oversees telemetry streaming, log services, command APIs.
- **Leo (DevOps):** Manages SSH profiles, rsync infrastructure, ANSI log normalization.
- **Quinn (QA):** Validates accessibility, telemetry instrumentation.

## Open Topics & Actions

### 1. Command Palette Data Source
- **Issue:** Need clarity whether palette searches only local metadata or also remote project/host APIs.
- **Action:** Mia to confirm availability of `host-index` API by 2025-09-26.
- **Frontend Impact:** Palette UI must display remote results + latencies if API is used.
- **Deliverable:** API contract doc + sample payloads for inclusion in design annotations.

### 2. ANSI Log Rendering Strategy
- **Issue:** Determine mapping for ANSI-colored logs inside Motif terminal without dropping context.
- **Action:** Leo to prototype log normalization script; deliver color mapping table referencing design tokens by 2025-09-27.
- **Frontend Impact:** Update `build-logs` and `terminal` mockups with accurate color chips.
- **Deliverable:** Markdown snippet or JSON palette for integration into token generator.

### 3. Telemetry Streaming Cadence
- **Issue:** Remote Hosts dashboard requires 5–10s streaming updates; design needs final cadence + data shape.
- **Action:** Mia + Leo to finalize SSE vs. polling decision during infra sync (2025-09-28).
- **Frontend Impact:** Telemetry graphs + status strips must annotate expected refresh window.
- **Deliverable:** Architecture note appended to `docs/architecture/future-work.md` plus sample response schema.

### 4. Offline Queue Events
- **Issue:** Offline drawer/status strip requires event hooks for queue size + retry outcomes.
- **Action:** Quinn to pair with backend on event naming by 2025-09-29 and define QA acceptance checkpoints.
- **Frontend Impact:** Mockups will embed event IDs for instrumentation.
- **Deliverable:** Test plan excerpt + update to resilience analytics spec.

## Communication Plan
- Weekly UX/Backend design sync (Mondays 10:00 PT) to review asset updates.
- Shared running agenda in `resources/notebooks/backend-design-sync.md` (create if missing).
- Use project Slack channel `#irix-ide-ux-backend` for interim decisions; pin API payloads.

## Status Tracking
| Item | Owner | Due | Status | Notes |
|------|-------|-----|--------|-------|
| Command palette API decision | Mia | 2025-09-26 | Pending | Provide sample search queries |
| ANSI mapping prototype | Leo | 2025-09-27 | Pending | Compare with existing rsync log colors |
| Telemetry cadence decision | Mia, Leo | 2025-09-28 | Pending | Align with infra capacity |
| Offline queue event schema | Quinn | 2025-09-29 | Pending | Needs QA instrumentation alignment |

Update this document after each sync to capture decisions and link finalized artifacts.
