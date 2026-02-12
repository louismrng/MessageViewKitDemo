//
// SettingsTabView.swift
// MessageViewKitDemo
//
// Settings tab view using pure SwiftUI SettingsView
//

import SwiftUI

/// The Settings tab containing the settings view.
struct SettingsTabView: View {
    var body: some View {
        NavigationStack {
            SettingsView()
                .navigationTitle("tab.settings")
                .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsTabView()
}
