# Usability Test Plan: Remote Resilience Workflows

## Objectives
1. Validate whether operators understand connection banners and recovery guidance.
2. Assess confidence in continuing work during offline states and resolving sync conflicts.
3. Measure clarity and perceived safety of destructive action confirmation + undo patterns.

## Research Questions
- Do users recognize what triggered a host drop and what action to take?
- Can they discover `Work Offline` and successfully queue changes?
- How quickly do they resolve a sync conflict without external help?
- Does the undo toast feel trustworthy and easy to act on within 5 seconds?

## Participants
- 6 macOS engineers who regularly work with remote build servers (3 novice to IRIX, 3 experienced).
- 2 IRIX maintainers who manage on-box sessions (if available for contrast).
- Remote moderated sessions via Zoom; participants use provided prototype or instrumented build.

## Methodology
- Session length: 45 minutes (5 intro, 30 tasks, 10 debrief).
- Moderator observes using think-aloud protocol.
- Screen/audio recorded; event telemetry captured if using prototype build.

## Test Environment
- High-fidelity prototype in Figma or instrumented desktop build with recovery flows enabled.
- Logging harness to simulate host drop, retry failures, offline queue, conflict scenario.
- Stable network with ability to toggle latency/packet loss for realism.

## Tasks
1. **Detect Host Drop** – Notice connection loss, interpret banner, choose an action (Retry vs Switch Host).
2. **Continue Offline** – With retries failing, continue editing, queue sync, and explain confidence level.
3. **Resolve Conflict** – On reconnect, handle conflicting file using modal options.
4. **Deploy Safely** – Execute deploy, review confirmation checklist, and use undo toast within countdown.
5. **Review Logs** – After recovery, navigate to log history and summarize what happened.

## Success Metrics
- Task completion rate ≥ 80% without moderator intervention.
- Average time to select correct response to host drop ≤ 30 seconds.
- SUS (System Usability Scale) score ≥ 75.
- Confidence rating (1-5) improves from pre- to post-session by at least 1 point on average.
- Undo interaction: >60% of participants attempt or acknowledge countdown explicitly.

## Data Collection
- Notes on quotes, observed behaviors, points of confusion.
- Telemetry: button clicks, time on task, undo usage.
- Post-task ratings (1-5) for clarity, trust, frustration.
- Post-session SUS questionnaire + open-ended feedback.

## Logistics
- Timeline: Recruit within 1 week; conduct sessions over 3 days; synthesize findings within 2 days after last session.
- Responsibilities: Moderator (UX), Notetaker (PM), Engineer on-call for prototype support.
- Incentive: $150 gift card per participant.

## Risks & Mitigations
- **Prototype instability:** Prepare backup click-through prototype.
- **Limited IRIX experts:** Use diary study follow-up if maintainers unavailable.
- **Undo timer confusion:** Extend to 8 seconds in prototype if early sessions fail repeatedly, note for analysis.

## Deliverables
- Highlight reel videos (per scenario).
- Insight summary with severity scoring and recommended design tweaks.
- Updated backlog items for engineering handoff.
