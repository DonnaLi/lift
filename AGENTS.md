# AGENTS.md

## Cursor Cloud specific instructions

### Platform constraint (read first)

`Lift` is a **SwiftUI iOS app** (target `IPHONEOS_DEPLOYMENT_TARGET = 26.2`). Every source file
under `lift/` imports Apple-proprietary frameworks — `SwiftUI`, `SwiftData`, `UIKit`, and `Combine`.
These frameworks ship **only** with Xcode and the Apple SDKs, which run **only on macOS**.

Cursor Cloud Agent VMs run **Linux (Ubuntu)**. As a result, on this VM you **cannot**:

- Build the app — `xcodebuild` is macOS-only and is not present.
- Run the app — the iOS Simulator (`simctl`) exists only on macOS; there is no device.
- Lint/type-check the sources — even a fully installed open-source Swift toolchain on Linux
  fails with `error: no such module 'SwiftUI'` / `'SwiftData'` because those modules do not
  exist outside the Apple SDKs.
- Run automated tests — the project has no test target, and any test would import the same
  Apple frameworks.

This is a hard platform incompatibility, not a missing dependency. No `apt`/toolchain install
makes this iOS app buildable on Linux. Do not add Swift/`xcodebuild` steps to the update script;
they cannot succeed here.

### How to actually develop / run this app

Use a **macOS machine with Xcode 15+** (see `README.md`):

1. Open `Lift.xcodeproj` in Xcode.
2. Select an iOS 17+ simulator (or a connected device).
3. Press Run (Cmd+R).

### What can be done on the Linux Cloud VM

- Read, search, and edit the Swift source files (`lift/*.swift`) and project config.
- Reason about the code. Note that no compilation/lint/test feedback is available here, so
  changes to Swift code cannot be verified on this VM — verify on macOS/Xcode.
