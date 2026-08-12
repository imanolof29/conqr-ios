//
//  ConqrApp.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

@main
struct ConqrApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ConqrMapView()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                WorkoutListView()
                    .tabItem {
                        Label("Workouts", systemImage: "list.bullet")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
        }
    }
}
