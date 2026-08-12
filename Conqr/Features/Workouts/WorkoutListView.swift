//
//  WorkoutListView.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI
import SwiftData

struct WorkoutListView: View {

    @Query(sort: \ActivityRecord.startDate, order: .reverse)
    private var records: [ActivityRecord]

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    ContentUnavailableView(
                        "Sin entrenamientos",
                        systemImage: "figure.run.circle",
                        description: Text("Inicia un entrenamiento desde el mapa para verlo aquí.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(records) { record in
                                WorkoutRow(activity: record)
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
        .modelContainer(for: [ActivityRecord.self, RouteLocation.self], inMemory: true)
}
