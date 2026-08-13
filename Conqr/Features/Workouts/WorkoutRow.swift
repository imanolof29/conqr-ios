//
//  WorkoutRow.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

struct WorkoutRow: View {
    let workout: ActivityRecord

    private var dateText: String {
        workout.startDate.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: workout.activityType.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .glassEffect(.regular.tint(workout.activityType.color), in: .circle)

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
    let active = ActivityRecord(type: .run, status: .inProgress)
    let finished = ActivityRecord(
        type: .walk,
        startDate: .now.addingTimeInterval(-3600),
        endDate: .now.addingTimeInterval(-1800),
        duration: 1800,
        distance: 5200,
        status: .completed
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
