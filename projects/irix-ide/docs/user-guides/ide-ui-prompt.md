# IRIX IDE UI Generation Prompt

Use this prompt with tools like Figma AI, v0, or Lovable to generate concept mockups aligned with our architecture and PRD.

```
Design a desktop IDE interface for "IRIX IDE" focused on remote development workflows within the IRIX Interactive Desktop.

Context:
- Primary users are IRIX developers who edit/build/debug code on local and remote SGI hosts.
- UI must adhere to Motif/Indigo Magic styling with magic-carpet icons, etched borders, and status strip messaging.
- Key workflows: project bootstrap (Toolchest launch, initialize project), remote edit/build loop with live logs, remote debugging sessions.

Layout Requirements:
1. Left navigation rail with sections: Dashboard, Editor, Remote Hosts, Build & Logs, Debugger, Settings. Support icon-only collapsed state.
2. Editor view: project tree panel, tabbed code editor, context panel (git status/docs). Status strip showing host connection, branch, sync state.
3. Build & Logs view: queue timeline, log viewer with filters, metrics sidebar (duration, success rate).
4. Remote Hosts view: list of hosts with health indicators, detail pane with resource graphs and quick actions.
5. Debugger view: toolbar (play/step), source pane with breakpoint gutter, variable inspector, call stack, console output.

Visual Direction:
- Indigo Magic-inspired palette (#4F5B66 surfaces, #6699CC accents) with Helvetica/Courier typography.
- Monochrome iconography consistent with IRIX guidelines; ensure 4.5:1 contrast.

Interaction Details:
- Display real-time sync/build indicators (pills, progress bars, status strip messages).
- Provide space for modal overlays (host config forms, connection warnings).
- Include notifications surfaced via status strip and optional drawer.

Output:
- Produce dashboard, editor, build/log, and debugger screens in desktop layout.
- Supply color/typography tokens and spacing system.
- Note adaptations for collapsed navigation or multi-desk scenarios.

Accessibility & Performance:
- Highlight focus states, keyboard shortcuts, and high-contrast palette.
- Show how logs/diagnostics are surfaced without overwhelming the user.
```

Include screenshots in `projects/irix-ide/docs/user-guides/screenshots/` when mockups are generated.
