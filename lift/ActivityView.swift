//
//  ActivityView.swift
//  liftify
//

import SwiftUI

struct ActivityView: View {
    private let activityMonths = ["Sep", "Oct", "Nov", "Dec", "Jan", "Feb"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)

    private let recentCheckIns: [(date: String, workout: String, showDot: Bool)] = [
        ("Feb 22", "Chest + Tricep", false),
        ("Feb 16", "Back + Bicep + Legs", true),
        ("Feb 13", "Chest + Tricep", false),
        ("Feb 9", "Back + Bicep + Legs", true),
        ("Feb 2", "Back + Bicep + Legs", true),
        ("Feb 1", "Chest + Tricep", false),
        ("Jan 30", "Chest + Tricep", false),
        ("Jan 26", "Back + Bicep + Legs", true),
        ("Jan 25", "Chest + Tricep", false),
        ("Jan 19", "Back + Bicep + Legs", true),
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Activity")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                activityHeatmapCard
                recentCheckInsSection
            }
            .padding(.horizontal, LiftDesign.screenPadding)
            .padding(.top, 16)
            .padding(.bottom, LiftDesign.bottomPadding)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(LiftDesign.background.ignoresSafeArea())
    }

    private var activityHeatmapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(activityMonths, id: \.self) { month in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(month)
                                .font(.caption2)
                                .foregroundStyle(LiftDesign.textSecondary)
                            LazyVGrid(columns: columns, spacing: 3) {
                                ForEach(0..<daysInMonth(month), id: \.self) { idx in
                                    Circle()
                                        .fill(activityColor(month: month, index: idx))
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                        .frame(minWidth: 44)
                    }
                }
                .padding(.horizontal, 4)
            }
            HStack(spacing: 12) {
                Spacer()
                activityLegendItem(color: LiftDesign.heatmapEmpty, text: "0")
                activityLegendItem(color: LiftDesign.heatmapLow, text: "1")
                activityLegendItem(color: LiftDesign.heatmapHigh, text: "2+")
            }
            .font(.caption2)
            .foregroundStyle(LiftDesign.textSecondary)
        }
        .padding(LiftDesign.cardPadding)
        .background(LiftDesign.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadius))
    }

    private func daysInMonth(_ month: String) -> Int {
        switch month {
        case "Sep", "Nov": return 30
        case "Oct", "Dec", "Jan": return 31
        case "Feb": return 28
        default: return 30
        }
    }

    private func activityColor(month: String, index: Int) -> Color {
        let seed = (month.hashValue + index) % 5
        if seed == 0 { return LiftDesign.heatmapHigh }
        if seed <= 2 { return LiftDesign.heatmapLow }
        return LiftDesign.heatmapEmpty
    }

    private func activityLegendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(text)
        }
    }

    private var recentCheckInsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LiftDesign.sectionLabel("RECENT CHECK-INS")

            VStack(spacing: 0) {
                ForEach(Array(recentCheckIns.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .center, spacing: 12) {
                        if item.showDot {
                            Circle()
                                .fill(LiftDesign.heatmapHigh)
                                .frame(width: 6, height: 6)
                        } else {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 6, height: 6)
                        }
                        Text(item.date)
                            .font(.subheadline)
                            .foregroundStyle(LiftDesign.textSecondary)
                            .frame(width: 52, alignment: .leading)
                        Text(item.workout)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(LiftDesign.textPrimary)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(LiftDesign.checkmarkGreen)
                            .font(.title3)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                }
            }
            .background(LiftDesign.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadius))

            Button {} label: {
                Text("Show More")
                    .font(.subheadline)
                    .foregroundStyle(LiftDesign.accentBlue)
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    ActivityView()
}
