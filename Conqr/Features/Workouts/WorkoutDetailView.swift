//
//  WorkoutDetailView.swift
//  Conqr
//
//  Created by Imanol Ortiz on 13/08/2026.
//

import SwiftUI
import MapKit

struct WorkoutDetailView: View {
    let workoutId: String

    @Environment(AuthManager.self) private var authManager

    @State private var workout: WorkoutDTO?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let workout {
                content(for: workout)
            } else if let errorMessage {
                ContentUnavailableView(
                    "No se pudo cargar",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Entrenamiento")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func content(for workout: WorkoutDTO) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    Image(systemName: "figure.mixed.cardio")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .glassEffect(.regular.tint(.blue), in: .circle)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.startedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)

                        Text(workout.status.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(workout.status.color)
                    }

                    Spacer()
                }

                if let coordinates = routeCoordinates(workout.polyline), coordinates.count > 1 {
                    Map(initialPosition: .region(region(fitting: coordinates))) {
                        MapPolyline(coordinates: coordinates)
                            .stroke(.blue, lineWidth: 4)
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }

                VStack(spacing: 0) {
                    detailRow(icon: "ruler", title: "Distancia", value: workout.formattedDistance)
                    Divider()
                    detailRow(icon: "clock", title: "Duración", value: workout.formattedDuration)
                    if let endedAt = workout.endedAt {
                        Divider()
                        detailRow(
                            icon: "flag.checkered",
                            title: "Finalizado",
                            value: endedAt.formatted(date: .abbreviated, time: .shortened)
                        )
                    }
                }
                .padding(16)
                .glassEffect(.regular, in: .rect(cornerRadius: 20))
            }
            .padding(16)
        }
    }

    private func routeCoordinates(_ polyline: String?) -> [CLLocationCoordinate2D]? {
        guard let polyline, !polyline.isEmpty else { return nil }
        return PolylineDecoder.decode(polyline)
    }

    private func region(fitting coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        let lats = coordinates.map(\.latitude)
        let lngs = coordinates.map(\.longitude)
        let minLat = lats.min() ?? 0
        let maxLat = lats.max() ?? 0
        let minLng = lngs.min() ?? 0
        let maxLng = lngs.max() ?? 0

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLng + maxLng) / 2)
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.4, 0.005),
            longitudeDelta: max((maxLng - minLng) * 1.4, 0.005)
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.headline)
        }
        .padding(.vertical, 10)
    }

    private func load() async {
        errorMessage = nil
        do {
            let service = RemoteTrackingService(client: authManager.makeAPIClient())
            workout = try await service.getWorkoutById(id: workoutId)
        } catch {
            errorMessage = (error as? NetworkError)?.userMessage ?? error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workoutId: UUID().uuidString)
    }
    .environment(AuthManager())
}
