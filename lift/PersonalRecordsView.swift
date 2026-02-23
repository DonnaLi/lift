//
//  PersonalRecordsView.swift
//  liftify
//

import SwiftUI

struct PersonalRecordItem: Identifiable {
    let id = UUID()
    let rank: Int
    let exercise: String
    let detail: String
    let weight: Int
    let trophyColor: Color?
}

struct PersonalRecordsView: View {
    @AppStorage("useKg") private var useKg = true

    private let records: [PersonalRecordItem] = [
        PersonalRecordItem(rank: 1, exercise: "Deadlift", detail: "Feb 16 · 4 reps", weight: 143, trophyColor: LiftDesign.trophyGold),
        PersonalRecordItem(rank: 2, exercise: "Squat", detail: "Feb 16 · 6 reps", weight: 125, trophyColor: Color(white: 0.6)),
        PersonalRecordItem(rank: 3, exercise: "Bench Press", detail: "Feb 22 · 6 reps", weight: 84, trophyColor: Color(red: 0.6, green: 0.4, blue: 0.25)),
        PersonalRecordItem(rank: 4, exercise: "Barbell Row", detail: "Feb 16 · 6 reps", weight: 70, trophyColor: nil),
        PersonalRecordItem(rank: 5, exercise: "Barbell Curl", detail: "Feb 16 · 8 reps", weight: 39, trophyColor: nil),
        PersonalRecordItem(rank: 6, exercise: "Incline DB Press", detail: "Feb 22 · 8 reps", weight: 32, trophyColor: nil),
        PersonalRecordItem(rank: 7, exercise: "Tricep Pushdown", detail: "Feb 22 · 10 reps", weight: 27, trophyColor: nil),
        PersonalRecordItem(rank: 8, exercise: "Overhead Extension", detail: "Feb 22 · 10 reps", weight: 20, trophyColor: nil),
    ]

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 10) {
                    Image(systemName: "trophy.fill")
                        .font(.title2)
                        .foregroundStyle(LiftDesign.trophyGold)
                    Text("Personal Records")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(LiftDesign.textPrimary)
                }

                VStack(spacing: 12) {
                    ForEach(records) { record in
                        PersonalRecordCard(item: record, unitLabel: useKg ? "kg" : "lbs")
                    }
                }
            }
            .padding(.horizontal, LiftDesign.screenPadding)
            .padding(.top, 16)
            .padding(.bottom, LiftDesign.bottomPadding)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(LiftDesign.background.ignoresSafeArea())
    }
}

struct PersonalRecordCard: View {
    let item: PersonalRecordItem
    var unitLabel: String = "kg"

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            if let color = item.trophyColor {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.3))
                        .frame(width: 40, height: 40)
                    Image(systemName: "trophy.fill")
                        .font(.body)
                        .foregroundStyle(color)
                }
            } else {
                ZStack {
                    Circle()
                        .fill(LiftDesign.borderLight)
                        .frame(width: 40, height: 40)
                    Text("\(item.rank)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(LiftDesign.textPrimary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.exercise)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(LiftDesign.textPrimary)
                Text(item.detail)
                    .font(.subheadline)
                    .foregroundStyle(LiftDesign.textSecondary)
            }
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(item.weight)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(LiftDesign.textPrimary)
                Text(unitLabel)
                    .font(.subheadline)
                    .foregroundStyle(LiftDesign.textPrimary)
            }
        }
        .padding(16)
        .background(LiftDesign.cardBackgroundSubtle)
        .clipShape(RoundedRectangle(cornerRadius: LiftDesign.cardRadiusSmall))
    }
}

#Preview {
    PersonalRecordsView()
}
