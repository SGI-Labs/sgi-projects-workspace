# Mockup Export Manifest

Use this directory to store rendered SVG exports that correspond to the source mockup files in `../screens/`. Follow the conventions below so engineering and stakeholders can align exports with the UI inventory.

## Naming Scheme
- `irix/<screen-id>.svg` – Primary export per state for IRIX variant.
- `overlays/<overlay-id>.svg` – Shared overlays.
- Additional states can append suffixes (e.g., `_offline`, `_warning`).

> Temporary note: until hi-fi SVGs are produced from the design tool, placeholder `.svg` files live beside each expected export. Replace them with the final assets while retaining the same basename.

## Required Exports (Initial)
- `irix/dashboard-default.svg`
- `irix/editor-connected.svg`
- `irix/build-logs.svg`
- `irix/remote-hosts.svg`
- `irix/debugger-session.svg`
- `irix/settings-theme.svg`
- `overlays/deploy-confirmation.svg`
- `overlays/sync-conflict.svg`
- `overlays/offline-work-drawer.svg`

Update this manifest as new states are captured. When exporting, include annotation layers or companion `.annot.json` files that capture callouts and token references.
