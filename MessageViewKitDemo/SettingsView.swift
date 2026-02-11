//
// SettingsView.swift
// MessageViewKitDemo
//
// Pure SwiftUI settings view
//

import SwiftUI

/// Pure SwiftUI settings view with grouped list.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: String?
    @State private var showingAlert = false

    private let sections: [(title: String, items: [String])] = [
        ("Account", ["Profile", "Privacy", "Notifications"]),
        ("App", ["Appearance", "Chats", "Storage"]),
        ("About", ["Help", "About", "Debug"])
    ]

    var body: some View {
        List {
            ForEach(sections, id: \.title) { section in
                Section(section.title) {
                    ForEach(section.items, id: \.self) { item in
                        Button {
                            selectedItem = item
                            showingAlert = true
                        } label: {
                            HStack {
                                Text(item)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .alert(selectedItem ?? "", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This is a placeholder for the \(selectedItem ?? "") settings screen.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .navigationTitle("Settings")
    }
}
