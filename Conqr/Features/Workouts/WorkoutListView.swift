//
//  WorkoutListView.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI
import SwiftData

struct WorkoutListView: View {

    // Backend has no "list workouts" endpoint — local SwiftData is the
    // source of truth for history; ActivityRecord.synced/remoteID tracks
    // whether each one made it to the server.
    @Query(sort: \ActivityRecord.startDate, order: .reverse) private var workouts: [ActivityRecord]

    var body: some View {
        NavigationStack {
            Group {
                if workouts.isEmpty {
                    ContentUnavailableView(
                        "Sin entrenamientos",
                        systemImage: "figure.run.circle",
                        description: Text("Inicia un entrenamiento desde el mapa para verlo aquí.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(workouts) { workout in
                                NavigationLink {
                                    WorkoutDetailView(workout: workout)
                                } label: {
                                    WorkoutRow(workout: workout)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Entrenamientos")
        }
    }
}

#Preview {
    WorkoutListView()
        .environment(AuthManager())
}
