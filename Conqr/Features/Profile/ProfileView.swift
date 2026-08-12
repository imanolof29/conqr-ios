//
//  ProfileView.swift
//  Conqr
//
//  Created by Imanol Ortiz on 12/08/2026.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            Text("Profile")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                        }
                    }
                }
        }
    }
}

#Preview {
    ProfileView()
}
