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

    @State private var locationService = LocationService()
    @State private var workoutTracker: WorkoutTracker?
    @State private var showActivitySheet: Bool = false

    var body: some View {
        NavigationStack {
            Map(position: $locationService.cameraPosition) {
                UserAnnotation()

                if let activity = workoutTracker?.activeActivity {
                    MapPolyline(coordinates: activity.coordinates)
                        .stroke(.blue, lineWidth: 4)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .onAppear {
                locationService.requestPermission()
                if workoutTracker == nil {
                    workoutTracker = WorkoutTracker(locationService: locationService, modelContext: modelContext)
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
}

#Preview {
    ConqrMapView()
}
