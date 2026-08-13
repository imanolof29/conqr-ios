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
    // Single NetworkClient for the whole app — created once here, then
    // handed to AuthManager and exposed via environment for everything else.
    private let networkClient: NetworkClient
    @State private var authManager: AuthManager

    init() {
        let networkClient = NetworkClient()
        self.networkClient = networkClient
        _authManager = State(initialValue: AuthManager(client: networkClient))
    }

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
            .environment(\.networkClient, networkClient)
        }
        .modelContainer(for: [ActivityRecord.self, RouteLocation.self])
    }
}
