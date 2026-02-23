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

    func setTodaysRoutine(id: UUID?) {
        todaysRoutineId = id
    }

    /// Check-ins in the last 7 days across all routines
    var checkInsThisWeek: Int {
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return routines.reduce(0) { sum, r in
            sum + r.checkInDates.filter { $0 >= weekAgo }.count
        }
    }

    var bestStreak: Int {
        routines.map(\.currentStreak).max() ?? 0
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
