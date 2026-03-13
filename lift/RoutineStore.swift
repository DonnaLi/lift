//
//  RoutineStore.swift
//  liftify
//

import Combine
import Foundation
import SwiftUI

// MARK: - Weekday
enum Weekday: Int, CaseIterable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    var id: Int { rawValue }
    var shortLabel: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
}

// MARK: - SetEntry
struct SetEntry: Identifiable {
    let id = UUID()
    var weight: String
    var reps: String
}

// MARK: - Exercise
struct Exercise: Identifiable {
    let id = UUID()
    var name: String
    var personalRecordWeight: Double?
    var sets: [SetEntry]
}

// MARK: - Routine
struct Routine: Identifiable {
    let id = UUID()
    var name: String
    var scheduleDays: [Weekday]
    var durationDays: Int
    var exercises: [Exercise]
    var checkInDates: [Date]

    var checkInCount: Int { checkInDates.count }
    var completionPercent: Int {
        guard durationDays > 0 else { return 0 }
        return min(100, Int((Double(checkInCount) / Double(durationDays)) * 100))
    }
    var currentStreak: Int {
        let cal = Calendar.current
        let sorted = checkInDates.sorted(by: >)
        var streak = 0
        var check = Date()
        for d in sorted {
            if cal.isDate(d, inSameDayAs: check) { continue }
            if cal.isDate(cal.date(byAdding: .day, value: -1, to: check)!, inSameDayAs: d) {
                streak += 1
                check = d
            } else { break }
        }
        return streak
    }
}

// MARK: - RoutineStore
@MainActor
final class RoutineStore: ObservableObject {
    @Published var routines: [Routine] = []
    @Published var todaysRoutineId: UUID?
    @Published var isCheckedInToday: Bool = false

    private let calendar = Calendar.current

    var todaysRoutine: Routine? {
        guard let id = todaysRoutineId else { return nil }
        return routines.first { $0.id == id }
    }

    /// Today's weekday (1 = Sunday, 2 = Monday, ...)
    private var todayWeekday: Weekday? {
        let comp = calendar.component(.weekday, from: Date())
        return Weekday(rawValue: comp)
    }

    /// Whether this routine is scheduled for today
    func isScheduledToday(_ routine: Routine) -> Bool {
        guard let today = todayWeekday else { return false }
        return routine.scheduleDays.contains(today)
    }

    /// Whether this routine is the designated "today's workout" and has been checked in
    func isTodaysRoutineAndCheckedIn(_ routine: Routine) -> Bool {
        guard routine.id == todaysRoutineId else { return false }
        return isCheckedInToday
    }

    func checkInToday() {
        guard !isCheckedInToday else { return }
        isCheckedInToday = true
        if let id = todaysRoutineId, let idx = routines.firstIndex(where: { $0.id == id }) {
            routines[idx].checkInDates.append(Date())
        }
    }

    func uncheckInToday() {
        guard isCheckedInToday else { return }
        isCheckedInToday = false
        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: Date())
        if let id = todaysRoutineId, let idx = routines.firstIndex(where: { $0.id == id }) {
            if let lastToday = routines[idx].checkInDates.lastIndex(where: { cal.isDate($0, inSameDayAs: startOfToday) }) {
                routines[idx].checkInDates.remove(at: lastToday)
            }
        }
    }

    func toggleCheckInToday() {
        if isCheckedInToday {
            uncheckInToday()
        } else {
            checkInToday()
        }
    }

    func addRoutine(_ routine: Routine) {
        routines.append(routine)
    }

    func deleteRoutine(id: UUID) {
        routines.removeAll { $0.id == id }
        if todaysRoutineId == id {
            todaysRoutineId = nil
            isCheckedInToday = false
        }
    }

    func updateRoutine(_ routine: Routine) {
        guard let idx = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        routines[idx] = routine
    }

    /// Set today's routine from schedule (call from Home onAppear so opening a card doesn't change it)
    func refreshTodaysRoutineFromSchedule() {
        todaysRoutineId = routines.first(where: { isScheduledToday($0) })?.id ?? routines.first?.id
    }

    /// Number of check-ins on the given calendar day (across all routines).
    func checkInCount(for date: Date) -> Int {
        let startOfDay = calendar.startOfDay(for: date)
        return routines.reduce(0) { sum, r in
            sum + r.checkInDates.filter { calendar.isDate($0, inSameDayAs: startOfDay) }.count
        }
    }

    /// Check-ins in the last 7 days across all routines
    var checkInsThisWeek: Int {
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return routines.reduce(0) { sum, r in
            sum + r.checkInDates.filter { $0 >= weekAgo }.count
        }
    }

    /// Check-ins in the last 30 days across all routines
    var checkInsInLast30Days: Int {
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return routines.reduce(0) { sum, r in
            sum + r.checkInDates.filter { $0 >= thirtyDaysAgo }.count
        }
    }

    /// Total check-ins across all routines
    var totalCheckIns: Int {
        routines.reduce(0) { sum, r in sum + r.checkInDates.count }
    }

    /// Number of unique calendar days with at least one check-in in the last 30 days
    var activeDaysInLast30: Int {
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        var dayStarts: Set<Date> = []
        for r in routines {
            for d in r.checkInDates where d >= thirtyDaysAgo {
                dayStarts.insert(calendar.startOfDay(for: d))
            }
        }
        return dayStarts.count
    }

    /// Last N weeks of check-in counts (week starts on calendar's first weekday). Returns (label, count) for bar chart.
    func weeklyCheckInData(numberOfWeeks: Int = 8) -> [(label: String, count: Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        var result: [(label: String, count: Int)] = []
        let now = Date()
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else { return result }
        for offset in (0..<numberOfWeeks).reversed() {
            guard let weekBegin = calendar.date(byAdding: .weekOfYear, value: -offset, to: weekStart) else { continue }
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekBegin) ?? weekBegin
            let count = routines.reduce(0) { sum, r in
                sum + r.checkInDates.filter { $0 >= weekBegin && $0 < weekEnd }.count
            }
            result.append((formatter.string(from: weekBegin), count))
        }
        return result
    }

    var bestStreak: Int {
        routines.map(\.currentStreak).max() ?? 0
    }

    /// Current streak for today's routine
    var currentStreak: Int {
        todaysRoutine?.currentStreak ?? 0
    }

    /// Approximate average weekly check-ins over the last 30 days (e.g. total / 4)
    var avgWeeklyStreak: Int {
        guard checkInsInLast30Days > 0 else { return 0 }
        return max(1, checkInsInLast30Days / 4)
    }

    /// Seed with default routines for demo
    static func withDefaults() -> RoutineStore {
        let store = RoutineStore()
        let chest = Routine(
            name: "Chest + Tricep",
            scheduleDays: [.sunday, .friday],
            durationDays: 30,
            exercises: [
                Exercise(name: "Bench Press", personalRecordWeight: 185, sets: [
                    SetEntry(weight: "135", reps: "10"),
                    SetEntry(weight: "155", reps: "8"),
                    SetEntry(weight: "185", reps: "6")
                ]),
                Exercise(name: "Incline DB Press", personalRecordWeight: 70, sets: [
                    SetEntry(weight: "50", reps: "12"),
                    SetEntry(weight: "60", reps: "10"),
                    SetEntry(weight: "70", reps: "8")
                ]),
                Exercise(name: "Cable Fly", personalRecordWeight: 40, sets: [
                    SetEntry(weight: "30", reps: "12"),
                    SetEntry(weight: "40", reps: "10")
                ]),
                Exercise(name: "Tricep Pushdown", personalRecordWeight: 60, sets: [
                    SetEntry(weight: "40", reps: "15"),
                    SetEntry(weight: "50", reps: "12"),
                    SetEntry(weight: "60", reps: "10")
                ]),
                Exercise(name: "Overhead Extension", personalRecordWeight: 45, sets: [
                    SetEntry(weight: "35", reps: "12"),
                    SetEntry(weight: "45", reps: "10")
                ])
            ],
            checkInDates: []
        )
        let back = Routine(
            name: "Back + Bicep + Legs",
            scheduleDays: [.monday],
            durationDays: 30,
            exercises: [
                Exercise(name: "Deadlift", personalRecordWeight: 315, sets: []),
                Exercise(name: "Barbell Row", personalRecordWeight: 135, sets: []),
                Exercise(name: "Barbell Curl", personalRecordWeight: 85, sets: [])
            ],
            checkInDates: []
        )
        store.routines = [chest, back]
        store.todaysRoutineId = store.routines.first(where: { store.isScheduledToday($0) })?.id ?? store.routines.first?.id
        store.isCheckedInToday = false
        return store
    }
}
