//
//  WorkoutListView.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

struct WorkoutListView: View {

    private let service: RemoteTrackingServicing = RemoteTrackingService()

    @State private var workouts: [WorkoutDTO] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && workouts.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if workouts.isEmpty {
                    ContentUnavailableView(
                        "Sin entrenamientos",
                        systemImage: "figure.run.circle",
                        description: Text("Inicia un entrenamiento desde el mapa para verlo aquí.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(workouts) { workout in
                                WorkoutRow(workout: workout)
                            }
                        }
                        .padding(16)
                    }
                    .refreshable { await load() }
                }
            }
            .navigationTitle("Entrenamientos")
            .task { await load() }
            .alert(
                "Entrenamientos",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { } }
                ),
                presenting: errorMessage
            ) { _ in
                Button("OK") {}
            } message: { message in
                Text(message)
            }
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            workouts = try await service.listWorkouts().sorted { $0.startedAt > $1.startedAt }
        } catch {
            errorMessage = (error as? NetworkError)?.userMessage ?? error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    WorkoutListView()
}
