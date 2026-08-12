//
//  ConqrApp.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

@main
struct ConqrApp: App {
    @AppStorage(AppSettingsKeys.loggedIn) private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
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
    }
}
