# Future Structural Enhancements

This note tracks upcoming architecture work for `projects/irix-automation/` so the shared repository stays organized as new features ship.

## Pending Tasks
- Introduce `projects/irix-automation/docs/user-guides/irix-build.md` when Story 1.2 lands to host the CLI usage guide.
- Consolidate desktop application build scripts under `projects/irix-automation/tools/build/` (new directory) if legacy assets are restored during future epics.
- Add `projects/irix-automation/tests/common/` if shared fixtures grow beyond the `irix_build` namespace.
- Evaluate adding a QA checklist template aligned with SGI standards once real implementations land and QA gates begin.

## Review Cadence
- Revisit this list at the close of each epic to confirm structure still matches implemented features.
- When new projects are added under `projects/`, create a sibling `future-work.md` tailored to their needs.
