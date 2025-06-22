# AGENTS – Webbing Dev Agents Guide (v0.2, June 2025)

Welcome, autonomous helpers 👋  
Your mission is to evolve **Webbing**, a macOS menu-bar multi-clipboard for **power users** who never want to use the mouse.

## Core Principles

1. **All-hotkey UX** – All clipboard actions and navigation are driven by dedicated global shortcuts. No textfields, no popups, no cursor movement.
2. **Reliability** – Shortcuts must work in any app, including fullscreen and non-Cocoa (Electron, browsers).
3. **Zero-footprint feedback** – Any action that changes app state (slot navigation, etc) must show HUD confirmation for under 1 second and never take keyboard focus from the user’s target app.
4. **Security** – All clipboard contents are stored locally; no network activity or telemetry.

---

## Current Global Hotkey Map

| Action                        | Key combo           | ID |
|-------------------------------|---------------------|----|
| Copy selection to slot        | ⌃⌥⌘C               | 1  |
| Paste from slot               | ⌃⌥⌘V               | 2  |
| Previous slot (wraps)         | ⌃⌥⌘[               | 3  |
| Next slot (wraps)             | ⌃⌥⌘]               | 4  |
| Reset slot (to 0)             | ⌃⌥⌘\\              | 5  |

- Slot index (0-9) is displayed by a brief, centered HUD overlay (`HUDView`)—never an input popup.

---

## Implementation Details

- **Copy** (⌃⌥⌘C):  
  First tries to invoke the system Copy action on the frontmost app (Cocoa responder chain). If this fails, falls back to synthesizing ⌘C via `CGEvent`. After a brief delay, saves clipboard to current slot index.

- **Paste** (⌃⌥⌘V):  
  Copies contents of the current slot to the system clipboard and simulates ⌘V.

- **Slot Navigation** (⌃⌥⌘[ / ] / \\):  
  Increments, decrements, or resets the current slot index (0–9, wraps around). Every change triggers a quick HUDView flash (see `MenuBarController.flash(index:)`).

- **No Text Input**:  
  User never types numbers or uses a textfield. Only hotkeys drive the slot state.

---

## Code Conventions

- Swift 5.10 (2025), SwiftUI + AppKit.
- Keep `HotkeyManager` and HUD logic small and testable.
- No unnecessary window focus changes.  
- Tests for slot navigation, persistence, hotkey dispatch.

---

## Branch Strategy

- `main`: stable.
- `dev/*`: new features, bugfixes.

---

## Tasks & Maintenance

| Recurrence | Task |
|------------|------|
| Daily      | Run unit tests & integration tests. |
| Weekly     | Check for deprecated APIs in new Xcode betas. |
| On commit  | Run swiftformat, swiftlint. |
| Release    | Bump version and notarize app. |

---

## FAQ

**Why not a popup for slot choice?**  
→ Interactivity via textfields would risk stealing keyboard focus, breaking flow, or causing UI lag. Hotkeys and HUD overlays offer the fastest, most ergonomic experience.

**Why use synthesized ⌘C/⌘V?**  
→ Not all apps participate in the responder chain. Synthesizing keys ensures Webbing works in browsers, VSCode, and everywhere else.

**Can this support more than 10 slots?**  
→ Not in v0.2, but agents should propose ergonomic ways to do so with minimal extra hotkey burden.

---

## Backlog/Future Ideas

- Configurable slot count (and shortcut layers).
- Support for images/files.
- Export/import.
- “Favorites” slots.

---

Happy coding & keep it snappy! 🚀

