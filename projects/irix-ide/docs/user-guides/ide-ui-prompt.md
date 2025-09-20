# IRIX IDE UI Generation Prompt

Use this prompt with tools like Figma AI, v0, or Lovable to generate concept mockups aligned with our architecture and PRD.

```
Design a desktop IDE interface for "IRIX IDE" focused on remote development workflows.

Context:
- Primary users are macOS developers who sync/build/debug code on SGI IRIX hosts.
- Secondary users are IRIX on-box maintainers who expect Motif/Indigo Magic styling when UI renders natively on IRIX.
- Key workflows: project bootstrap (select host, initialize project), remote edit/build loop with live logs, remote debugging sessions.

Layout Requirements:
1. Left navigation rail with sections: Dashboard, Editor, Remote Hosts, Build & Logs, Debugger, Settings. Support icon-only collapsed state.
2. Editor view: project tree panel, tabbed code editor, context panel (git status/docs). Status bar showing host connection, branch, sync state.
3. Build & Logs view: queue timeline, log viewer with filters, metrics sidebar (duration, success rate).
4. Remote Hosts view: list of hosts with health indicators, detail pane with resource graphs and quick actions.
5. Debugger view: toolbar (play/step), source pane with breakpoint gutter, variable inspector, call stack, console output.

Visual Direction:
- macOS SwiftUI aesthetic (SF Pro font, primary accent #0A84FF, dark theme backgrounds #1E1E1E).
- Integrate Indigo Magic-inspired slate (#4F5B66) for IRIX panels/terminals.
- Use SF Symbols or monochrome icons; ensure 4.5:1 contrast.

Interaction Details:
- Display real-time sync/build indicators (pills, progress bars).
- Provide space for modal overlays (host config forms, connection warnings).
- Include toast notifications for deploy success/error.

Output:
- Produce dashboard, editor, build/log, and debugger screens in desktop layout.
- Supply color/typography tokens and spacing system.
- Note responsive adaptations (collapsed nav, stacked panels for tablets).

Accessibility & Performance:
- Highlight focus states, keyboard shortcuts, and high-contrast palette.
- Show how logs/diagnostics are surfaced without overwhelming the user.
```

Include screenshots in `projects/irix-ide/docs/user-guides/screenshots/` when mockups are generated.
