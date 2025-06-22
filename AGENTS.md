# AGENTS – Webbing Dev Agents Guide

Welcome, autonomous helpers 👋  Your mission is to evolve **Webbing**, a macOS menu‑bar multi‑clipboard.

## Core Objectives
1. **Reliability** – Hotkeys must work 100 % of the time, even while other apps are fullscreen.
2. **Keyboard‑only UX** – No mouse required for the critical save/paste workflow.
3. **Minimal Footprint** – Idle CPU < 1 %, memory < 40 MB.
4. **Security & Privacy** – Clipboard contents live only in local storage (UserDefaults plist) and never leave the device.

## Code Conventions
- Swift‑5.10, SwiftUI + AppKit interop.
- 100 char line‑length max.
- Prefer structs & value types unless shared mutable state.
- Unit tests for every model & controller public API.
- Use dependency injection for testability.

## Branch Strategy
- `main` → stable, release‑ready.
- `dev/*` → feature branches. Open PRs with at least one reviewer.

## Continuous Tasks for Agents
| Recurrence | Task |
|------------|------|
| Daily      | Run unit tests & report failures. |
| Weekly     | Scan APIs for deprecations on latest Xcode beta. |
| On commit  | Lint code (`swiftformat` + `swiftlint`). |
| Release    | Bump CFBundleShortVersion & build notarized DMG. |

## Future Backlog Ideas
- Rich data types (images, files).
- iCloud sync of slots.
- Slot naming & previews.
- Keyboard Maestro / Alfred plugin.

Happy coding! ✨
