# LIFT — Workout Tracker
<img width="5488" height="2036" alt="lift" src="https://github.com/user-attachments/assets/955845b5-a437-4f24-802d-e0766096292b" />

A SwiftUI iOS app for tracking workouts, routines, and streaks.

## Features

- **Home** — Today’s workout, my routines, stats (streak, this week, best streak), and workout history with contribution graph
- **Activity** — Contribution heatmap (check-ins by day) and recent check-ins list
- **Records** — Personal records for exercises
- **Stats** — Workouts (30d), total check-ins, streaks, active days, and weekly check-in bar chart; tap “Active Challenges” to open streak challenges
- **Settings** — Appearance (light/dark), units (kg/lbs), storage, version
- **Routine detail** — Progress bar, check-in button, exercises with sets/weight/reps, add set, add exercise
- **New routine** — Create routines with name, schedule days, duration, and exercises

## Requirements

- Xcode 15+
- iOS 17+
- Swift 5

## How to run

1. Open `Lift.xcodeproj` in Xcode.
2. Choose an iOS simulator (e.g. iPhone 17) or a connected device.
3. Press **Run** (⌘R).

## Project structure

```
Lift/
├── Lift.xcodeproj/
└── lift/
    ├── liftifyApp.swift      # App entry, RoutineStore, color scheme
    ├── ContentView.swift     # Tab bar, Home, TodayWorkoutCard, RoutineCard, CheckInButton, etc.
    ├── RoutineStore.swift    # Routines, check-ins, stats APIs
    ├── RoutineDetailView.swift
    ├── NewRoutineView.swift
    ├── ActivityView.swift    # Contribution graph, recent check-ins
    ├── StatsView.swift       # Stats grid, bar chart, Challenges sheet
    ├── ChallengesView.swift   # Streak challenges (3–100 day)
    ├── PersonalRecordsView.swift
    ├── SettingsView.swift
    ├── LiftDesign.swift      # Colors, spacing, card styling, heatmap
    └── Assets.xcassets/
```

## License

Private / educational use.
