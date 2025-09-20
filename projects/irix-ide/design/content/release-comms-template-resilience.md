# Release Comms Template: Remote Resilience Enhancements

Use this template for release notes, internal announcements, or customer emails.

## Summary
- **Headline:** “Improved Remote Reliability and Recovery for IRIX IDE Users”
- **TL;DR:** Instant host-drop detection, smarter offline editing, and safer deploy flows with undo.

## Highlights
1. **Faster Recovery:** IDE now retries remote connections up to three times with clear status banners.
2. **Offline Editing Support:** You can keep coding while offline; queued changes sync automatically once reconnected.
3. **Safety Net for Deploys:** Confirmation checklist and 5-second undo window reduce risk of accidental deploys.

## Why It Matters
- Reduces downtime during network hiccups.
- Gives teams confidence that destructive actions have guardrails.
- Improves visibility for support/ops with better logging and activity feed entries.

## Call to Action
- Install version `<version>` or refresh IRIX IDE desktop client.
- Review the new workflows (link to mockups or Storybook).
- Share feedback via `#irix-ide-feedback` or support ticket.

## Supporting Links
- Front-end spec: `docs/front-end-spec.md`
- Component spec: `design/component-specs/remote-resilience-components.md`
- Usability report (if available): `<link>`

## Support Notes
- Known issues: `<list if any>`
- Rollback steps: `deploy rollback --last`
- Contact: `<support email / Slack channel>`
