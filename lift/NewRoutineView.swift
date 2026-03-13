//
//  NewRoutineView.swift
//  liftify
//

import SwiftUI

struct NewRoutineView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var name = ""
    @State private var selectedDays: Set<Weekday> = []
    @State private var durationDays = "30"
    @State private var exerciseNames: [String] = [""]

    let onCreate: (Routine) -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 24) {
                    routineNameSection
                    scheduleSection
                    durationSection
                    exercisesSection
                    createButton
                }
                .padding(LiftDesign.screenPadding)
                .padding(.bottom, 32)
            }
            .background(LiftDesign.background.ignoresSafeArea())
            .navigationTitle("New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body)
                            .foregroundStyle(LiftDesign.textPrimary)
                    }
                }
            }
        }
    }

    private var routineNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            LiftDesign.sectionLabel("ROUTINE NAME")
            TextField("e.g. Chest + Tricep", text: $name)
                .textFieldStyle(.roundedBorder)
                .padding(.vertical, 4)
        }
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            LiftDesign.sectionLabel("SCHEDULE")
            HStack(spacing: 12) {
                ForEach(Weekday.allCases, id: \.rawValue) { day in
                    dayButton(day)
                }
            }
        }
    }

    private func dayButton(_ day: Weekday) -> some View {
        let isSelected = selectedDays.contains(day)
        let selectedBg = colorScheme == .dark ? Color(uiColor: .secondarySystemBackground) : Color.black
        let selectedFg = colorScheme == .dark ? Color.primary : Color.white
        return Button {
            if isSelected {
                selectedDays.remove(day)
            } else {
                selectedDays.insert(day)
            }
        } label: {
            Text(day.shortLabel)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 36, height: 36)
                .background(isSelected ? selectedBg : LiftDesign.borderLight)
                .foregroundStyle(isSelected ? selectedFg : LiftDesign.textPrimary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            LiftDesign.sectionLabel("DURATION (DAYS)")
            TextField("30", text: $durationDays)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .padding(.vertical, 4)
        }
    }

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LiftDesign.sectionLabel("EXERCISES")
            ForEach(Array(exerciseNames.enumerated()), id: \.offset) { index, _ in
                HStack(spacing: 12) {
                    TextField("Exercise name", text: $exerciseNames[index])
                        .textFieldStyle(.roundedBorder)
                    if exerciseNames.count > 1 {
                        Button {
                            exerciseNames.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle")
                                .foregroundStyle(LiftDesign.destructiveRed)
                        }
                    }
                }
            }
            Button {
                exerciseNames.append("")
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                    Text("Add exercise")
                        .font(.subheadline)
                }
                .foregroundStyle(LiftDesign.accentBlue)
            }
        }
    }

    private var createButton: some View {
        Button {
            createRoutine()
        } label: {
            let primaryBg = colorScheme == .dark ? Color(uiColor: .secondarySystemBackground) : Color.black
            let primaryFg = colorScheme == .dark ? Color.primary : Color.white
            Text("Create Routine")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(canCreate ? primaryFg : LiftDesign.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canCreate ? primaryBg : LiftDesign.borderLight)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(!canCreate)
    }

    private var canCreate: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && !selectedDays.isEmpty
    }

    private func createRoutine() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !selectedDays.isEmpty else { return }
        let days = Array(selectedDays).sorted(by: { $0.rawValue < $1.rawValue })
        let duration = Int(durationDays) ?? 30
        let exercises = exerciseNames
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { Exercise(name: $0, personalRecordWeight: nil, sets: []) }
        let routine = Routine(
            name: trimmedName,
            scheduleDays: days,
            durationDays: max(1, duration),
            exercises: exercises.isEmpty ? [Exercise(name: "Exercise 1", personalRecordWeight: nil, sets: [])] : exercises,
            checkInDates: []
        )
        onCreate(routine)
    }
}

#Preview {
    NewRoutineView(
        onCreate: { _ in },
        onDismiss: { }
    )
}
