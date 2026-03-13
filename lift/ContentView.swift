//
//  ContentView.swift
//  liftify
//
//  Created by Donna Li on 2026-02-22.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Home")
                }
                .tag(0)
            ActivityView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Activity")
                }
                .tag(1)
            PersonalRecordsView()
                .tabItem {
                    Image(systemName: "trophy")
                    Text("Records")
                }
                .tag(2)
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }
                .tag(3)
            SettingsView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Settings")
                }
                .tag(4)
        }
        .tint(LiftDesign.accentBlue)
        .tabViewStyle(.automatic)
    }
}

// MARK: - Home View (Dashboard) — matches LIFT Workout Tracker layout
struct HomeView: View {
    @EnvironmentObject var store: RoutineStore
    @Binding var selectedTab: Int
    @State private var showNewRoutine = false

    private let greeting: String = {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 17 { return "Good afternoon" }
        return "Good evening"
    }()

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: LiftDesign.sectionSpacing) {
                    appTitleAndHeader
                    todaysWorkoutSection
                    myRoutinesSection
                    statsSection
                    workoutHistorySection
                }
                .padding(.horizontal, LiftDesign.screenPadding)
                .padding(.top, 16)
                .padding(.bottom, LiftDesign.bottomPadding)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(LiftDesign.backgroundAlt.ignoresSafeArea())
            .onAppear { store.refreshTodaysRoutineFromSchedule() }
        }
        .sheet(isPresented: $showNewRoutine) {
            NewRoutineView(onCreate: { routine in
                store.addRoutine(routine)
                showNewRoutine = false
            }, onDismiss: { showNewRoutine = false })
        }
    }

    private var appTitleAndHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            LiftAppTitle(showSubtitle: true)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(LiftDesign.textPrimary)
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundStyle(LiftDesign.textSecondary)
                }
                Spacer()
                HStack(spacing: 12) {
                    CircleButton(icon: "line.3.horizontal.decrease.circle")
                    Button {
                        showNewRoutine = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundStyle(LiftDesign.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(LiftDesign.borderLight)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    private var todaysWorkoutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            LiftDesign.sectionLabel("TODAY'S WORKOUT")
            if let routine = store.todaysRoutine {
                TodayWorkoutCard(
                    title: routine.name,
                    detail: routineScheduleDetail(routine),
                    isCheckedIn: store.isCheckedInToday,
                    onCheckIn: { store.toggleCheckInToday() }
                )
            } else {
                TodayWorkoutCard(
                    title: "No routine",
                    detail: "Tap + to add a routine",
                    isCheckedIn: false,
                    onCheckIn: { }
                )
            }
        }
    }

    private func routineScheduleDetail(_ routine: Routine) -> String {
        let days = routine.scheduleDays.map(\.shortLabel).joined(separator: ", ")
        return "\(days) • \(routine.checkInCount)"
    }

    private var myRoutinesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            LiftDesign.sectionLabel("MY ROUTINES")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Array(store.routines.enumerated()), id: \.element.id) { index, routine in
                        NavigationLink(destination: RoutineDetailView(routine: routine)) {
                            RoutineCard(
                                routine: routine,
                                number: index + 1,
                                isTodaysAndCheckedIn: store.isTodaysRoutineAndCheckedIn(routine)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(icon: "flame.fill", value: "\(store.todaysRoutine?.currentStreak ?? 0)", label: "Streak", iconColor: LiftDesign.accentOrange)
            StatCard(icon: "calendar", value: "\(store.checkInsThisWeek)", label: "This Week", iconColor: LiftDesign.textSecondary)
            StatCard(icon: "trophy.fill", value: "\(store.bestStreak)", label: "Best Streak", iconColor: LiftDesign.textSecondary)
        }
    }

    private var workoutHistorySection: some View {
        Button {
            selectedTab = 1
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    LiftDesign.sectionLabel("WORKOUT HISTORY")
                    Spacer()
                    HStack(spacing: 6) {
                        Text("\(store.checkInsThisWeek) this week")
                            .font(.caption)
                            .foregroundStyle(LiftDesign.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(LiftDesign.borderLight)
                            .clipShape(Capsule())
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(LiftDesign.textSecondary)
                    }
                }
                WorkoutHeatmapView()
            }
        }
        .buttonStyle(.plain)
    }

}

// MARK: - Circle Button
struct CircleButton: View {
    let icon: String
    var body: some View {
        Button {} label: {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(LiftDesign.textPrimary)
                .frame(width: 44, height: 44)
                .background(LiftDesign.borderLight)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Check-in Button (black/white when unchecked per theme, green when checked; tap toggles)
struct CheckInButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let isCheckedIn: Bool
    let action: () -> Void

    private var uncheckedBackground: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    private var uncheckedForeground: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    private var checkedForeground: Color {
        colorScheme == .dark ? Color.white : LiftDesign.textPrimary
    }

    var body: some View {
        Button(action: action) {
            Group {
                if isCheckedIn {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .fontWeight(.semibold)
                            .foregroundStyle(checkedForeground)
                        Text("Checked In")
                            .fontWeight(.semibold)
                    }
                } else {
                    Text("Check In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isCheckedIn ? LiftDesign.successGreen : uncheckedBackground)
            .foregroundStyle(isCheckedIn ? checkedForeground : uncheckedForeground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Today Workout Card
struct TodayWorkoutCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let detail: String
    let isCheckedIn: Bool
    let onCheckIn: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                    HStack(spacing: 4) {
                        Text(detail)
                            .font(.subheadline)
                            .foregroundStyle(LiftDesign.textSecondary)
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(LiftDesign.accentOrange)
                    }
                }
                Spacer()
                Button {} label: {
                    Image(systemName: "pencil")
                        .font(.subheadline)
                        .foregroundStyle(LiftDesign.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(LiftDesign.cardBackgroundSubtle)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            CheckInButton(isCheckedIn: isCheckedIn, action: onCheckIn)
        }
        .padding(LiftDesign.cardPadding)
        .background(LiftDesign.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadius))
    }
}

// MARK: - Routine Card
struct RoutineCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let routine: Routine
    let number: Int
    let isTodaysAndCheckedIn: Bool

    private var detail: String {
        let days = routine.scheduleDays.map(\.shortLabel).joined(separator: ", ")
        return "\(days) • \(routine.checkInCount)"
    }

    private var numberCircleFill: Color {
        colorScheme == .dark ? Color(uiColor: .secondarySystemBackground) : Color.black
    }
    private var numberCircleText: Color {
        colorScheme == .dark ? Color.primary : .white
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(numberCircleFill)
                        .frame(width: 36, height: 36)
                    Text("\(number)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(numberCircleText)
                }
                Spacer()
                if isTodaysAndCheckedIn {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(LiftDesign.checkmarkGreen)
                } else {
                    Button {} label: {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundStyle(LiftDesign.textPrimary)
                            .frame(width: 28, height: 28)
                            .background(LiftDesign.cardBackgroundSubtle)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            Text(routine.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(LiftDesign.textPrimary)
                .lineLimit(2)
            HStack(spacing: 4) {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(LiftDesign.textSecondary)
                Image(systemName: "flame.fill")
                    .font(.caption2)
                    .foregroundStyle(LiftDesign.accentOrange)
            }
        }
        .padding(16)
        .frame(width: 160, height: 140)
        .background(LiftDesign.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadius))
    }
}

// MARK: - Stat Card
struct StatCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let value: String
    let label: String
    var iconColor: Color = LiftDesign.textSecondary

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(LiftDesign.textPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(LiftDesign.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(LiftDesign.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadius))
    }
}

// MARK: - Workout Heatmap (calendar-based, store-driven)
struct WorkoutHeatmapView: View {
    @EnvironmentObject var store: RoutineStore
    @Environment(\.colorScheme) private var colorScheme
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let calendar = Calendar.current

    private var monthInfos: [(label: String, cellLevels: [Int])] {
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(Array(monthInfos.enumerated()), id: \.offset) { _, info in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(info.label)
                            .font(.caption2)
                            .foregroundStyle(LiftDesign.textSecondary)
                        LazyVGrid(columns: columns, spacing: 4) {
                            ForEach(Array(info.cellLevels.enumerated()), id: \.offset) { _, level in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(LiftDesign.heatmapColor(level: level, isDark: colorScheme == .dark))
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                }
            }
            HStack(spacing: 16) {
                heatmapLegendItem(color: LiftDesign.heatmapColor(level: 0, isDark: colorScheme == .dark), text: "0")
                heatmapLegendItem(color: LiftDesign.heatmapColor(level: 1, isDark: colorScheme == .dark), text: "1")
                heatmapLegendItem(color: LiftDesign.heatmapColor(level: 2, isDark: colorScheme == .dark), text: "2+")
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

    private func heatmapLegendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(text)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(RoutineStore.withDefaults())
}
