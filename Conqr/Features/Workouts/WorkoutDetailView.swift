//
//  WorkoutDetailView.swift
//  Conqr
//
//  Created by Imanol Ortiz on 13/08/2026.
//

import SwiftUI
import MapKit

struct WorkoutDetailView: View {
    let workout: ActivityRecord

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    Image(systemName: workout.activityType.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .glassEffect(.regular.tint(workout.activityType.color), in: .circle)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.startDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)

                        Text(workout.status.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(workout.status.color)
                    }

                    Spacer()

                    if !workout.synced {
                        Image(systemName: "icloud.slash")
                            .foregroundStyle(.secondary)
                    }
                }

                let coordinates = workout.coordinates
                if coordinates.count > 1 {
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
                    if let endDate = workout.endDate {
                        Divider()
                        detailRow(
                            icon: "flag.checkered",
                            title: "Finalizado",
                            value: endDate.formatted(date: .abbreviated, time: .shortened)
                        )
                    }
                }
                .padding(16)
                .glassEffect(.regular, in: .rect(cornerRadius: 20))
            }
            .padding(16)
        }
        .navigationTitle("Entrenamiento")
        .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workout: ActivityRecord(type: .run))
    }
    .environment(AuthManager())
}
