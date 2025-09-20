# Microcopy Library: Remote Resilience UI

Use these strings verbatim unless localization or legal review requires changes. Keep `<host>` placeholders dynamic.

## Status Pill
| State | Copy | Notes |
|-------|------|-------|
| Connected | `Connected` | Keep short for badge legibility |
| Degraded | `Degraded` | Indicates elevated latency |
| Reconnecting | `Reconnecting…` | Include ellipsis to signal active process |
| Offline | `Offline` | Used when connection manager abandons retries |

## Connection Banners
| Scenario | Title | Body | Actions |
|----------|-------|------|---------|
| Host Drop | `Lost connection to <host>` | `We will retry automatically. You can switch hosts or open troubleshooting for manual steps.` | `Retry` (primary), `Switch Host`, `Open Guide` |
| Retrying | `Retrying… (2 of 3)` | `Attempt 2 will complete in <eta>. Logs are paused until the connection is restored.` | `Cancel Retries`, `Switch Host` |
| Offline | `You are offline` | `Changes will queue locally. Continue editing or work offline until connectivity returns.` | `Work Offline`, `Queue Sync` |
| Failure | `Retries exhausted` | `We could not reach <host>. Switch hosts or review troubleshooting.` | `Switch Host`, `Open Guide` |

## Tooltips & Helper Text
| Element | Copy |
|---------|------|
| Disabled Build Button | `Build unavailable while connection is unstable.` |
| Disabled Deploy Button | `Deploy disabled until remote session recovers.` |
| Offline Badge | `Unsynced changes` |
| Retry Progress | `Attempt <current> of <total>` |
| Command Palette Offline Option | `Queue Sync – Push pending files when connectivity returns.` |

## Modal & Toast Copy
| Component | Copy |
|-----------|------|
| Deploy Confirmation Title | `Deploy to <host>?` |
| Deploy Confirmation Body | `Build <buildId> will restart remote sessions. Confirm prerequisites before proceeding.` |
| Confirmation Suppress Toggle | `Don’t show again this session` |
| Undo Toast Title | `Deploy sent to <host>` |
| Undo Toast Body | `Undo available for <seconds>s. View details for rollback steps.` |
| Conflict Modal Title | `Sync conflict detected` |
| Conflict Modal Body | `<file> changed remotely while you were offline. Choose how to proceed.` |
| Merge Tool Action | `Open Merge Tool` |

## Empty & Recovery States
| Surface | Copy |
|---------|------|
| Offline Queue Empty | `All changes synced. You’re now up to date on <host>.` |
| Retry Success Toast | `Connection restored` / `We resumed streaming logs and cleared the retry queue.` |
| Retry Failure Toast | `Still offline` / `We’ll keep watching for connectivity. Try switching hosts if urgency is high.` |

## Voice & Tone Guidelines
- Empathetic and action-oriented; avoid blame language.
- Keep sentences short (≤18 words) with present tense where possible.
- Provide reassurance about data safety when offline or retrying.
