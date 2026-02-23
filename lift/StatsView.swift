//
//  StatsView.swift
//  liftify
//

import SwiftUI

struct StatsView: View {
    @State private var chartMode: ChartMode = .weekly

    private let statsGrid: [(value: String, label: String, showFlame: Bool)] = [
        ("9", "Workouts (30d)", false),
        ("22", "Total Check-ins", false),
        ("1.4", "Avg Weekly Streak", false),
        ("22", "Active Days", false),
        ("1", "Current Streak", true),
        ("0", "Active Challenges", false),
    ]

    private let weeklyLabels = ["12/29", "1/5", "1/12", "1/19", "1/26", "2/2", "2/9", "2/16"]
    private let weeklyValues: [CGFloat] = [1, 2, 3, 2, 4, 3, 5, 7]

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Stats")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                statsGridSection
                checkInActivitySection
            }
            .padding(.horizontal, LiftDesign.screenPadding)
            .padding(.top, 16)
            .padding(.bottom, LiftDesign.bottomPadding)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(LiftDesign.background.ignoresSafeArea())
    }

    private var statsGridSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(Array(statsGrid.enumerated()), id: \.offset) { index, stat in
                StatsGridCard(
                    value: stat.value,
                    label: stat.label,
                    showFlame: stat.showFlame,
                    showTapToView: index == 5
                )
            }
        }
    }

    private var checkInActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            LiftDesign.sectionLabel("CHECK-IN ACTIVITY")

            Picker("", selection: $chartMode) {
                Text("Weekly").tag(ChartMode.weekly)
                Text("Monthly").tag(ChartMode.monthly)
            }
            .pickerStyle(.segmented)
            .padding(4)

            BarChartView(labels: weeklyLabels, values: weeklyValues)
        }
    }
}

enum ChartMode {
    case weekly, monthly
}

struct StatsGridCard: View {
    let value: String
    let label: String
    let showFlame: Bool
    var showTapToView: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                if showFlame {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(LiftDesign.accentOrange)
                }
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(LiftDesign.textPrimary)
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(LiftDesign.textSecondary)
            if showTapToView {
                Button {} label: {
                    HStack(spacing: 4) {
                        Text("Tap to view")
                            .font(.caption)
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                    }
                    .foregroundStyle(LiftDesign.accentBlue)
                }
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(LiftDesign.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadius))
    }
}

struct BarChartView: View {
    let labels: [String]
    let values: [CGFloat]
    private let maxValue: CGFloat = 7

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .trailing, spacing: 8) {
                    ForEach([0, 2, 4, 7].reversed(), id: \.self) { y in
                        Text("\(y)")
                            .font(.caption2)
                            .foregroundStyle(LiftDesign.textSecondary)
                    }
                }
                .frame(width: 20)

                GeometryReader { geo in
                    let width = (geo.size.width - CGFloat(labels.count - 1) * 8) / CGFloat(labels.count)
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(Array(labels.enumerated()), id: \.offset) { index, _ in
                            let h = max(4, values[index] / maxValue * (geo.size.height - 24))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LiftDesign.heatmapHigh)
                                .frame(width: width, height: h)
                        }
                    }
                }
                .frame(height: 120)
            }

            HStack(spacing: 0) {
                ForEach(labels, id: \.self) { label in
                    Text(label)
                        .font(.caption2)
                        .foregroundStyle(LiftDesign.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(LiftDesign.cardPadding)
        .background(LiftDesign.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadius))
    }
}

#Preview {
    StatsView()
}
