//
//  RoutineDetailView.swift
//  liftify
//

import SwiftUI

struct RoutineDetailView: View {
    @EnvironmentObject var store: RoutineStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("useKg") private var useKg = true
    let routine: Routine

    private var currentRoutine: Routine? {
        store.routines.first { $0.id == routine.id }
    }

    var body: some View {
        Group {
            if let r = currentRoutine {
                content(routine: r)
            } else {
                Text("Routine not found")
                    .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") { dismiss() }
                    .foregroundStyle(LiftDesign.textPrimary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.deleteRoutine(id: routine.id)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(LiftDesign.destructiveRed)
                }
            }
        }
    }

    private func content(routine: Routine) -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: LiftDesign.sectionSpacing) {
                header(routine: routine)
                progressCard(routine: routine)
                CheckInButton(isCheckedIn: store.isCheckedInToday, action: { store.toggleCheckInToday() })
                Text("Exercise data is optional")
                    .font(.caption)
                    .foregroundStyle(LiftDesign.textSecondary)
                exercisesSection(routine: routine)
            }
            .padding(.horizontal, LiftDesign.screenPadding)
            .padding(.top, 16)
            .padding(.bottom, LiftDesign.bottomPadding)
        }
        .background(LiftDesign.background.ignoresSafeArea())
    }

    private func header(routine: Routine) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(routine.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(LiftDesign.textPrimary)
            Text(scheduleString(routine))
                .font(.subheadline)
                .foregroundStyle(LiftDesign.textSecondary)
        }
    }

    private func scheduleString(_ routine: Routine) -> String {
        routine.scheduleDays.map(\.shortLabel).joined(separator: ", ")
    }

    private func progressCard(routine: Routine) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.headline)
                .foregroundStyle(LiftDesign.textPrimary)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LiftDesign.borderLight)
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.primary)
                        .frame(width: max(0, geo.size.width * CGFloat(routine.checkInCount) / CGFloat(max(1, routine.durationDays))), height: 10)
                }
            }
            .frame(height: 10)
            Text("\(routine.checkInCount)/\(routine.durationDays) days")
                .font(.subheadline)
                .foregroundStyle(LiftDesign.textSecondary)
            HStack(spacing: 12) {
                miniStat(value: "\(routine.currentStreak)", label: "Streak", icon: "flame.fill")
                miniStat(value: "\(routine.checkInCount)", label: "Check-Ins", icon: nil)
                miniStat(value: "\(routine.completionPercent)%", label: "Completion", icon: nil)
            }
        }
        .padding(LiftDesign.cardPadding)
        .background(LiftDesign.cardBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadius))
    }

    private func miniStat(value: String, label: String, icon: String?) -> some View {
        VStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(LiftDesign.accentOrange)
            }
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(LiftDesign.textPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(LiftDesign.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func exercisesSection(routine: Routine) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            LiftDesign.sectionLabel("EXERCISES")
            ForEach(routine.exercises) { exercise in
                ExerciseCard(
                    exercise: exercise,
                    unitLabel: useKg ? "kg" : "lbs",
                    onUpdate: { updated in
                        guard var r = currentRoutine else { return }
                        guard let idx = r.exercises.firstIndex(where: { $0.id == updated.id }) else { return }
                        r.exercises[idx] = updated
                        store.updateRoutine(r)
                    },
                    onAddSet: {
                        guard var r = currentRoutine else { return }
                        guard let idx = r.exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
                        r.exercises[idx].sets.append(SetEntry(weight: "", reps: ""))
                        store.updateRoutine(r)
                    },
                    onRemoveSet: { setIndex in
                        guard var r = currentRoutine else { return }
                        guard let idx = r.exercises.firstIndex(where: { $0.id == exercise.id }), r.exercises[idx].sets.indices.contains(setIndex) else { return }
                        r.exercises[idx].sets.remove(at: setIndex)
                        store.updateRoutine(r)
                    }
                )
            }
            addExerciseRow(routine: routine)
        }
    }

    private func addExerciseRow(routine: Routine) -> some View {
        AddExerciseRow(onAdd: { name in
            guard var r = currentRoutine else { return }
            r.exercises.append(Exercise(name: name, personalRecordWeight: nil, sets: []))
            store.updateRoutine(r)
        })
    }
}

// MARK: - Exercise Card
struct ExerciseCard: View {
    let exercise: Exercise
    var unitLabel: String = "lbs"
    let onUpdate: (Exercise) -> Void
    let onAddSet: () -> Void
    let onRemoveSet: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "dumbbell.fill")
                    .font(.subheadline)
                    .foregroundStyle(LiftDesign.textSecondary)
                Text(exercise.name)
                    .font(.headline)
                    .foregroundStyle(LiftDesign.textPrimary)
                Spacer()
                if let pr = exercise.personalRecordWeight {
                    Text("PR: \(Int(pr)) \(unitLabel)")
                        .font(.caption)
                        .foregroundStyle(LiftDesign.textSecondary)
                }
            }
            HStack(spacing: 8) {
                Text("Set")
                    .frame(width: 32, alignment: .leading)
                    .font(.caption)
                    .foregroundStyle(LiftDesign.textSecondary)
                Text("Weight (\(unitLabel))")
                    .frame(maxWidth: .infinity)
                    .font(.caption)
                    .foregroundStyle(LiftDesign.textSecondary)
                Text("Reps")
                    .frame(maxWidth: .infinity)
                    .font(.caption)
                    .foregroundStyle(LiftDesign.textSecondary)
                Color.clear.frame(width: 28)
            }
            ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { setIndex, set in
                HStack(spacing: 8) {
                    Text("\(setIndex + 1)")
                        .frame(width: 32, alignment: .leading)
                        .font(.subheadline)
                        .foregroundStyle(LiftDesign.textPrimary)
                    TextField("", text: bindingWeight(setIndex))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                    TextField("", text: bindingReps(setIndex))
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                    Button {
                        onRemoveSet(setIndex)
                    } label: {
                        Image(systemName: "minus.circle")
                            .foregroundStyle(LiftDesign.textSecondary)
                            .frame(width: 28)
                    }
                }
            }
            Button(action: onAddSet) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                    Text("Add set")
                        .font(.caption)
                }
                .foregroundStyle(LiftDesign.textSecondary)
            }
        }
        .padding(LiftDesign.cardPadding)
        .background(LiftDesign.cardBackgroundSubtle)
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadiusSmall))
    }

    private func bindingWeight(_ setIndex: Int) -> Binding<String> {
        Binding(
            get: { exercise.sets[safe: setIndex]?.weight ?? "" },
            set: { new in
                var ex = exercise
                if ex.sets.indices.contains(setIndex) {
                    ex.sets[setIndex].weight = new
                    onUpdate(ex)
                }
            }
        )
    }

    private func bindingReps(_ setIndex: Int) -> Binding<String> {
        Binding(
            get: { exercise.sets[safe: setIndex]?.reps ?? "" },
            set: { new in
                var ex = exercise
                if ex.sets.indices.contains(setIndex) {
                    ex.sets[setIndex].reps = new
                    onUpdate(ex)
                }
            }
        )
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Add Exercise Row
struct AddExerciseRow: View {
    @State private var newName = ""
    let onAdd: (String) -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("New exercise name", text: $newName)
                .textFieldStyle(.roundedBorder)
            Button {
                let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !name.isEmpty {
                    onAdd(name)
                    newName = ""
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(LiftDesign.accentBlue)
            }
        }
        .padding(LiftDesign.cardPadding)
        .background(LiftDesign.cardBackgroundSubtle)
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadiusSmall))
    }
}

#Preview {
    NavigationStack {
        RoutineDetailView(routine: Routine(
            name: "Chest + Tricep",
            scheduleDays: [.sunday, .friday],
            durationDays: 30,
            exercises: [Exercise(name: "Bench Press", personalRecordWeight: 185, sets: [])],
            checkInDates: []
        ))
        .environmentObject(RoutineStore.withDefaults())
    }
}
