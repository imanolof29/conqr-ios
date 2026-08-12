//
//  ConqrApp.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI
import SwiftData

@main
struct ConqrApp: App {
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
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
                } else {
                    LoginView()
                }
            }
            .environment(authManager)
        }
        .modelContainer(for: [ActivityRecord.self, RouteLocation.self])
    }
}
