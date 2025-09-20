# State Model: Remote Connection Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Connected
    Connected --> Degraded: latency > threshold
    Degraded --> Reconnecting: retry scheduled
    Reconnecting --> Connected: retry success
    Reconnecting --> Offline: retries exhausted
    Offline --> Reconnecting: manual retry
    Offline --> Connected: network restored (auto)
    Connected --> Offline: host maintenance / auth failure

    state Reconnecting {
        [*] --> Attempt1
        Attempt1 --> Attempt2: failure
        Attempt2 --> Attempt3: failure
        Attempt3 --> [*]: success
        Attempt3 --> Exhausted: failure
    }

    Exhausted --> Offline
```

**Triggers**
- `latency > threshold` emitted by health monitor.
- `retry scheduled` when attempt count < 3.
- `retries exhausted` when attempt count hits maxAttempts.
- `manual retry` fired from banner CTA; resets attempt counter.

**Outputs**
- UI events: status pill update, connection banner variant, analytics events (`connection_status_changed`, `connection_retry_*`).
- Logs: health monitor writes to resilience channel with attempt details.
