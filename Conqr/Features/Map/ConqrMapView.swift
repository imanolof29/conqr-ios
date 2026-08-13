//
//  ConqrMapView.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI
import MapKit

struct ConqrMapView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.networkClient) private var networkClient

    @State private var locationService = LocationService()
    @State private var workoutTracker: WorkoutTracker?
    @State private var territoryStore: TerritoryStore?
    @State private var showActivitySheet: Bool = false

    var body: some View {
        NavigationStack {
            Map(position: $locationService.cameraPosition) {
                UserAnnotation()

                ForEach(territoryStore?.all ?? []) { territory in
                    MapPolygon(coordinates: territory.coordinates)
                        .foregroundStyle(color(for: territory).opacity(0.35))
                        .stroke(color(for: territory), lineWidth: 1)
                }

                if let activity = workoutTracker?.activeActivity {
                    MapPolyline(coordinates: activity.coordinates)
                        .stroke(.blue, lineWidth: 4)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                territoryStore?.refresh(for: context.region)
            }
            .onChange(of: workoutTracker?.lastConquest) { _, _ in
                territoryStore?.refreshCurrentRegion()
            }
            .onChange(of: locationService.currentLocation?.timestamp) { _, _ in
                let location = locationService.currentLocation
                guard let location, territoryStore?.hasFetched == false else { return }
                territoryStore?.refresh(
                    for: MKCoordinateRegion(
                        center: location.coordinate,
                        latitudinalMeters: 1600,
                        longitudinalMeters: 1600
                    )
                )
            }
            .onAppear {
                locationService.requestPermission()
                if workoutTracker == nil {
                    workoutTracker = WorkoutTracker(
                        locationService: locationService,
                        modelContext: modelContext,
                        remoteTrackingService: RemoteTrackingService(client: networkClient)
                    )
                }
                if territoryStore == nil {
                    territoryStore = TerritoryStore(
                        service: RemoteTerritoryService(client: networkClient)
                    )
                }
            }
            .alert(
                "Location",
                isPresented: Binding(
                    get: { locationService.lastError != nil },
                    set: { if !$0 { } }
                ),
                presenting: locationService.lastError
            ) { _ in
                Button("OK") {}
            } message: { error in
                Text(error.errorDescription ?? "Unknown error")
            }
            .alert(
                "Tracking",
                isPresented: Binding(
                    get: { workoutTracker?.connectionError != nil },
                    set: { if !$0 { } }
                ),
                presenting: workoutTracker?.connectionError
            ) { _ in
                Button("OK") {}
            } message: { message in
                Text(message)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if workoutTracker?.isActive == true {
                        Button("Finalizar") {
                            workoutTracker?.finish()
                        }
                    } else {
                        Button {
                            showActivitySheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showActivitySheet) {
                ActivitySelectorSheet { activityType in
                    workoutTracker?.start(type: activityType)
                    showActivitySheet = false
                }
                .presentationDetents([.medium])
            }
        }
    }

    private func color(for territory: TerritoryDTO) -> Color {
        territory.ownerId == TokenStorage.shared.currentUserId ? .blue : .red
    }
}

#Preview {
    ConqrMapView()
        .environment(AuthManager(client: NetworkClient()))
        .environment(\.networkClient, NetworkClient())
}
