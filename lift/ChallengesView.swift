//
//  ChallengesView.swift
//  liftify
//

import SwiftUI

struct ChallengesView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private let challenges: [(emoji: String, title: String, days: Int)] = [
        ("🔥", "3-Day Streak", 3),
        ("⚡", "7-Day Streak", 7),
        ("💪", "14-Day Streak", 14),
        ("🏆", "30-Day Streak", 30),
        ("👑", "60-Day Streak", 60),
        ("✨", "100-Day Streak", 100),
    ]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Challenges")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(LiftDesign.textPrimary)
                        Text("Start a streak challenge and keep your momentum going.")
                            .font(.subheadline)
                            .foregroundStyle(LiftDesign.textSecondary)
                    }

                    VStack(spacing: 12) {
                        ForEach(Array(challenges.enumerated()), id: \.offset) { _, challenge in
                            challengeCard(emoji: challenge.emoji, title: challenge.title, description: "Work out \(challenge.days) days in a row")
                        }
                    }
                }
                .padding(.horizontal, LiftDesign.screenPadding)
                .padding(.top, 16)
                .padding(.bottom, LiftDesign.bottomPadding)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(LiftDesign.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(LiftDesign.accentBlue)
                }
            }
        }
    }

    private func challengeCard(emoji: String, title: String, description: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text(emoji)
                .font(.title2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(LiftDesign.textPrimary)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(LiftDesign.textSecondary)
            }
            Spacer()
            Button {} label: {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.caption)
                    Text("Start")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundStyle(LiftDesign.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(uiColor: .tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LiftDesign.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadius))
    }
}

#Preview {
    ChallengesView()
}
