//
//  WorkoutRow.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

struct WorkoutRow: View {
    let workout: WorkoutDTO

    private var dateText: String {
        workout.startedAt.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "figure.mixed.cardio")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .glassEffect(.regular.tint(.blue), in: .circle)

            VStack(alignment: .leading, spacing: 4) {
                Text(dateText)
                    .font(.headline)

                HStack(spacing: 10) {
                    Label(workout.formattedDistance, systemImage: "ruler")
                    Label(workout.formattedDuration, systemImage: "clock")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Text(workout.status.title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(workout.status.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .glassEffect(.regular.tint(workout.status.color.opacity(0.18)), in: .capsule)
        }
        .padding(14)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }
}

#Preview {
    let active = WorkoutDTO(
        id: UUID().uuidString,
        status: .active,
        distanceMeters: 1240,
        polyline: nil,
        startedAt: .now.addingTimeInterval(-1800),
        endedAt: nil
    )
    let finished = WorkoutDTO(
        id: UUID().uuidString,
        status: .finished,
        distanceMeters: 5200,
        polyline: nil,
        startedAt: .now.addingTimeInterval(-3600),
        endedAt: .now.addingTimeInterval(-1800)
    )

    return ScrollView {
        VStack(spacing: 12) {
            WorkoutRow(workout: active)
            WorkoutRow(workout: finished)
        }
        .padding()
    }
    .background(.gray.opacity(0.15))
}
