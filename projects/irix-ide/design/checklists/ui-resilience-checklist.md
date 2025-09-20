# UI Review Checklist: Remote Resilience

Use before handing off or releasing recovery-related UI.

## Connection Signals
- [ ] Status pill updates across header, status bar, and logs simultaneously.
- [ ] Connection banner text matches backend state (host name, attempt count).
- [ ] Retry progress indicator reflects actual schedule.
- [ ] Offline badge only appears on tabs with unsynced changes.

## Interaction & Controls
- [ ] Disabled build/deploy controls provide tooltip explaining why.
- [ ] `Retry`, `Work Offline`, and `Switch Host` buttons reachable via keyboard.
- [ ] Command palette opens with focus in search input and closes via `Esc`.
- [ ] Destructive confirmation sheet focuses secondary (`Cancel`) button by default.
- [ ] Undo toast pauses countdown on hover/focus and supports keyboard dismissal.

## Content & Messaging
- [ ] Banner copy ≤160 characters and uses action verbs.
- [ ] Tooltips, modals, and toasts include host context (e.g., `octane`).
- [ ] Conflict modal diff preview highlights additions/removals with legend reference.
- [ ] Recovery events log to activity feed with timestamps.

## Accessibility
- [ ] Live regions announce connection state changes and retry attempts.
- [ ] All actionable elements meet 44px target size.
- [ ] Color is not the only indicator of state (icon/text included).
- [ ] Screen reader order mirrors visual priority.

## Analytics & QA Hooks
- [ ] Events for `connection_retry_started`, `connection_retry_success`, `work_offline_selected`, `undo_clicked` emitted.
- [ ] Error logging captures failure reason when retries exhaust.
- [ ] QA test cases updated to cover offline queue, conflicts, undo path.

Sign-off:
- Designer: ____________________ Date: ___________
- Engineer: ____________________ Date: ___________
- QA: __________________________ Date: ___________
