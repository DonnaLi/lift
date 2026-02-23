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
    static let background = Color(uiColor: .systemBackground)
    static let backgroundAlt = Color(uiColor: .secondarySystemBackground)
    static let cardBackground = Color(uiColor: .secondarySystemBackground)
    static let cardBackgroundSubtle = Color(uiColor: .tertiarySystemBackground)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let accentBlue = Color.blue
    static let accentOrange = Color.orange
    static let successGreen = Color(red: 0.85, green: 0.95, blue: 0.85)
    static let checkmarkGreen = Color.green
    static let destructiveRed = Color(red: 0.8, green: 0.2, blue: 0.2)
    static let destructiveBackground = Color(red: 1.0, green: 0.9, blue: 0.9)
    static let borderLight = Color(uiColor: .separator)
    static let trophyGold = Color(red: 0.85, green: 0.65, blue: 0.2)
    static let heatmapEmpty = Color(uiColor: .tertiarySystemFill)
    static let heatmapLow = Color(uiColor: .quaternaryLabel)
    static let heatmapHigh = Color(uiColor: .secondaryLabel)

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
