//
//  StatsView.swift
//  liftify
//

import SwiftUI

struct StatsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var store: RoutineStore
    @State private var chartMode: ChartMode = .weekly
    @State private var showChallenges = false

    private var statsGrid: [(value: String, label: String, showFlame: Bool)] {
        [
            ("\(store.checkInsInLast30Days)", "Workouts (30d)", false),
            ("\(store.totalCheckIns)", "Total Check-ins", false),
            ("\(store.avgWeeklyStreak)", "Avg Weekly Streak", false),
            ("\(store.activeDaysInLast30)", "Active Days", false),
            ("\(store.currentStreak)", "Current Streak", true),
            ("0", "Active Challenges", false),
        ]
    }

    private var weeklyChartLabels: [String] {
        store.weeklyCheckInData(numberOfWeeks: 8).map(\.label)
    }

    private var weeklyChartValues: [CGFloat] {
        store.weeklyCheckInData(numberOfWeeks: 8).map { CGFloat($0.count) }
    }

    private var barChartMaxValue: CGFloat {
        let vals = weeklyChartValues
        guard !vals.isEmpty else { return 1 }
        return max(1, vals.max() ?? 1)
    }

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
        .sheet(isPresented: $showChallenges) {
            ChallengesView()
        }
    }

    private var statsGridSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(Array(statsGrid.enumerated()), id: \.offset) { index, stat in
                StatsGridCard(
                    value: stat.value,
                    label: stat.label,
                    showFlame: stat.showFlame,
                    showTapToView: index == 5,
                    onTapToView: index == 5 ? { showChallenges = true } : nil
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

            BarChartView(labels: weeklyChartLabels, values: weeklyChartValues, maxValue: barChartMaxValue)
        }
    }
}

enum ChartMode {
    case weekly, monthly
}

struct StatsGridCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let value: String
    let label: String
    let showFlame: Bool
    var showTapToView: Bool = false
    var onTapToView: (() -> Void)? = nil

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
                Button(action: { onTapToView?() }) {
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
        .background(LiftDesign.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadius))
    }
}

struct BarChartView: View {
    @Environment(\.colorScheme) private var colorScheme
    let labels: [String]
    let values: [CGFloat]
    var maxValue: CGFloat = 1

    private var effectiveMax: CGFloat { max(1, maxValue) }

    private var yAxisLabels: [Int] {
        let m = max(1, Int(effectiveMax.rounded()))
        if m <= 2 { return Array(0...m) }
        let step = max(1, m / 3)
        return Array(Set([0, step, min(2 * step, m), m])).sorted()
    }

    var body: some View {
        let yLabels = yAxisLabels
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .trailing, spacing: 8) {
                    ForEach(yLabels.reversed(), id: \.self) { y in
                        Text("\(y)")
                            .font(.caption2)
                            .foregroundStyle(LiftDesign.textSecondary)
                    }
                }
                .frame(width: 20)

                GeometryReader { geo in
                    let width = (geo.size.width - CGFloat(labels.count - 1) * 8) / CGFloat(max(1, labels.count))
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(Array(labels.enumerated()), id: \.offset) { index, _ in
                            let val = index < values.count ? values[index] : 0
                            let h = max(4, val / effectiveMax * (geo.size.height - 24))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.primary)
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
        .background(LiftDesign.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadius))
    }
}

#Preview {
    StatsView()
        .environmentObject(RoutineStore.withDefaults())
}
