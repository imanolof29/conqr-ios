//
//  ConqrMapView.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI
import MapKit

struct ConqrMapView: View {
    @State private var locationService = LocationService()
    @State private var showActivitySheet: Bool = false

    var body: some View {
        NavigationStack {
            Map(position: $locationService.cameraPosition) {
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .onAppear {
                locationService.requestPermission()
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
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showActivitySheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showActivitySheet) {
                ActivitySelector()
                    .presentationDetents([.medium])
            }
        }
    }
    
    @ViewBuilder
    private func ActivitySelector() -> some View {
        VStack {
            HStack {
                ForEach(ActivityType.allCases, id: \.self) { activity in
                    VStack {
                        Text(activity.description)
                    }
                }
            }
            Button {
                showActivitySheet = false
            }label: {
                Text("Iniciar")
            }
        }
    }
    
}

#Preview {
    ConqrMapView()
}
