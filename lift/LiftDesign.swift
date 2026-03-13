//
//  LiftDesign.swift
//  liftify
//
//  Design tokens aligned with LIFT — Workout Tracker (React reference).
//

import SwiftUI
import UIKit

enum LiftDesign {
    // MARK: - Colors (adaptive for light/dark mode)
    /// Main screen background (black in dark, light gray in light)
    static let background = Color(uiColor: .systemBackground)
    /// Home screen background — same as background so dark mode is black and sections stand out
    static let backgroundAlt = Color(uiColor: .systemBackground)
    /// Card background — elevated surface (light grey in dark mode so cards are visible on black)
    static let cardBackground = Color(uiColor: .tertiarySystemBackground)
    /// Subtle cards / inputs
    static let cardBackgroundSubtle = Color(uiColor: .quaternarySystemFill)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let accentBlue = Color.blue
    static let accentOrange = Color.orange
    /// Darker green for checked-in button so white text/icon stay readable
    static let successGreen = Color(red: 0.18, green: 0.58, blue: 0.28)
    static let checkmarkGreen = Color.green
    static let destructiveRed = Color(red: 0.8, green: 0.2, blue: 0.2)
    static let destructiveBackground = Color(red: 1.0, green: 0.9, blue: 0.9)
    static let borderLight = Color(uiColor: .separator)
    static let trophyGold = Color(red: 0.85, green: 0.65, blue: 0.2)
    static let heatmapEmpty = Color(uiColor: .tertiarySystemFill)
    static let heatmapLow = Color(uiColor: .quaternaryLabel)
    static let heatmapHigh = Color(uiColor: .secondaryLabel)

    /// Card background that is distinct from page background: grey in light mode, elevated in dark.
    static func cardBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(uiColor: .tertiarySystemBackground) : Color(white: 0.96)
    }

    /// Heatmap: 0 = lightest, 1 = medium, 2+ = black (light) / white (dark). Level 0 = no workouts, 1 = one, 2 = two or more.
    static func heatmapColor(level: Int, isDark: Bool) -> Color {
        if isDark {
            switch level {
            case 0: return Color(white: 0.22)
            case 1: return Color(white: 0.45)
            default: return Color(white: 0.85)
            }
        } else {
            switch level {
            case 0: return Color(white: 0.92)
            case 1: return Color(white: 0.55)
            default: return Color(white: 0.2)
            }
        }
    }

    // MARK: - Spacing
    static let screenPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 24
    static let cardPadding: CGFloat = 18
    static let cardRadius: CGFloat = 16
    static let cardRadiusSmall: CGFloat = 14
    static let bottomPadding: CGFloat = 48

    // MARK: - Section label (uppercase, small, gray — like React)
    static func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(textSecondary)
    }
}

// MARK: - App title view (matches "LIFT — Workout Tracker")
struct LiftAppTitle: View {
    var showSubtitle: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("LIFT")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(LiftDesign.textPrimary)
            if showSubtitle {
                Text("Workout Tracker")
                    .font(.caption)
                    .foregroundStyle(LiftDesign.textSecondary)
            }
        }
    }
}
