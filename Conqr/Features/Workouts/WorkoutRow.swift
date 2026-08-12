//
//  WorkoutRow.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

struct WorkoutRow: View {
    let activity: ActivityRecord

    private var dateText: String {
        activity.startDate.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: activity.activityType.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .glassEffect(.regular.tint(activity.activityType.color), in: .circle)

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.activityType.title)
                    .font(.headline)

                Text(dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    Label(activity.formattedDistance, systemImage: "ruler")
                    Label(activity.formattedDuration, systemImage: "clock")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Text(activity.status.title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(activity.status.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .glassEffect(.regular.tint(activity.status.color.opacity(0.18)), in: .capsule)
        }
        .padding(14)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }
}

#Preview {
    let walk = ActivityRecord(type: .walk, distance: 1240, status: .completed)
    let run = ActivityRecord(type: .run, duration: 1830, distance: 5200, status: .inProgress)

    return ScrollView {
        VStack(spacing: 12) {
            WorkoutRow(activity: walk)
            WorkoutRow(activity: run)
        }
        .padding()
    }
    .background(.gray.opacity(0.15))
}
