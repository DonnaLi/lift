//
//  ActivityView.swift
//  liftify
//

import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var store: RoutineStore
    @Environment(\.colorScheme) private var colorScheme
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
    private let calendar = Calendar.current

    private var activityMonthInfos: [(label: String, cellLevels: [Int])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return (0..<3).reversed().compactMap { offset -> (String, [Int])? in
            guard let date = calendar.date(byAdding: .month, value: -offset, to: Date()) else { return nil }
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let label = formatter.string(from: date)
            let levels = heatmapLevels(year: year, month: month)
            return (label, levels)
        }
    }

    private var recentCheckIns: [(date: String, workout: String, showDot: Bool)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let all: [(Date, String)] = store.routines.flatMap { r in
            r.checkInDates.map { ($0, r.name) }
        }
        let sorted = all.sorted { $0.0 > $1.0 }
        return sorted.prefix(10).map { (date: formatter.string(from: $0.0), workout: $0.1, showDot: true) }
    }

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
                    ForEach(Array(activityMonthInfos.enumerated()), id: \.offset) { _, info in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(info.label)
                                .font(.caption2)
                                .foregroundStyle(LiftDesign.textSecondary)
                            LazyVGrid(columns: columns, spacing: 5) {
                                ForEach(Array(info.cellLevels.enumerated()), id: \.offset) { _, level in
                                    Circle()
                                        .fill(LiftDesign.heatmapColor(level: level, isDark: colorScheme == .dark))
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                        .frame(minWidth: 56)
                    }
                }
                .padding(.horizontal, 4)
            }
            HStack(spacing: 12) {
                Spacer()
                activityLegendItem(color: LiftDesign.heatmapColor(level: 0, isDark: colorScheme == .dark), text: "0")
                activityLegendItem(color: LiftDesign.heatmapColor(level: 1, isDark: colorScheme == .dark), text: "1")
                activityLegendItem(color: LiftDesign.heatmapColor(level: 2, isDark: colorScheme == .dark), text: "2+")
            }
            .font(.caption2)
            .foregroundStyle(LiftDesign.textSecondary)
        }
        .padding(LiftDesign.cardPadding)
        .background(LiftDesign.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadius))
    }

    private func heatmapLevels(year: Int, month: Int) -> [Int] {
        guard let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else { return [] }
        let daysInMonth = range.count
        let weekday = calendar.component(.weekday, from: firstDay)
        let leading = weekday - 1
        let totalCells = ((leading + daysInMonth + 6) / 7) * 7
        return (0..<totalCells).map { i in
            if i < leading { return 0 }
            let day = i - leading + 1
            if day > daysInMonth { return 0 }
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) else { return 0 }
            let count = store.checkInCount(for: date)
            return min(2, count)
        }
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
            .background(LiftDesign.cardBackground(for: colorScheme))
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
        .environmentObject(RoutineStore.withDefaults())
}
