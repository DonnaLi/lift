//
//  SettingsView.swift
//  liftify
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("useKg") private var useKg = true

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(spacing: 0) {
                    SettingsRow(
                        icon: "sun.max.fill",
                        title: "Appearance",
                        value: darkMode ? "Dark" : "Light",
                        showToggle: true,
                        toggleOn: $darkMode
                    )
                    Divider()
                        .padding(.leading, 52)
                    SettingsRow(
                        icon: "scalemass.fill",
                        title: "Units",
                        value: useKg ? "kg" : "lbs",
                        showToggle: true,
                        toggleOn: $useKg
                    )
                    Divider()
                        .padding(.leading, 52)
                    SettingsRow(
                        icon: nil,
                        title: "Storage",
                        value: "Local",
                        showToggle: false,
                        toggleOn: .constant(false)
                    )
                    Divider()
                        .padding(.leading, 52)
                    SettingsRow(
                        icon: nil,
                        title: "Version",
                        value: "1.0.0",
                        showToggle: false,
                        toggleOn: .constant(false)
                    )
                }
                .background(LiftDesign.cardBackground(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadius))

                Button {} label: {
                    Text("Reset All Data")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(LiftDesign.destructiveRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LiftDesign.destructiveBackground)
                        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadiusSmall))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, LiftDesign.screenPadding)
            .padding(.top, 16)
            .padding(.bottom, LiftDesign.bottomPadding)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(LiftDesign.background.ignoresSafeArea())
    }
}

struct SettingsRow: View {
    let icon: String?
    let title: String
    let value: String
    let showToggle: Bool
    @Binding var toggleOn: Bool

    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(LiftDesign.textSecondary)
                    .frame(width: 24, alignment: .center)
            }
            Text(title)
                .font(.body)
                .foregroundStyle(LiftDesign.textPrimary)
            Spacer()
            if showToggle {
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(LiftDesign.textSecondary)
                Toggle("", isOn: $toggleOn)
                    .labelsHidden()
            } else {
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(LiftDesign.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    SettingsView()
}
