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
    @State private var selectedItem: SettingsItem?
    @State private var showingAlert = false

    private struct SettingsItem: Identifiable {
        let id: String // localization key
        var localizedTitle: String {
            String(localized: String.LocalizationValue(id))
        }
    }

    private struct SettingsSection: Identifiable {
        let id: String // localization key
        let items: [SettingsItem]
        var localizedTitle: String {
            String(localized: String.LocalizationValue(id))
        }
    }

    private let sections: [SettingsSection] = [
        SettingsSection(id: "settings.section.account", items: [
            SettingsItem(id: "settings.item.profile"),
            SettingsItem(id: "settings.item.privacy"),
            SettingsItem(id: "settings.item.notifications"),
        ]),
        SettingsSection(id: "settings.section.app", items: [
            SettingsItem(id: "settings.item.appearance"),
            SettingsItem(id: "settings.item.chats"),
            SettingsItem(id: "settings.item.storage"),
        ]),
        SettingsSection(id: "settings.section.about", items: [
            SettingsItem(id: "settings.item.help"),
            SettingsItem(id: "settings.item.about"),
            SettingsItem(id: "settings.item.debug"),
        ]),
    ]

    var body: some View {
        List {
            ForEach(sections) { section in
                Section(section.localizedTitle) {
                    ForEach(section.items) { item in
                        Button {
                            selectedItem = item
                            showingAlert = true
                        } label: {
                            HStack {
                                Text(item.localizedTitle)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .alert(selectedItem?.localizedTitle ?? "", isPresented: $showingAlert) {
            Button("common.ok", role: .cancel) { }
        } message: {
            Text(String(localized: "settings.placeholder_alert", defaultValue: "This is a placeholder for the \(selectedItem?.localizedTitle ?? "") settings screen."))
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .navigationTitle("tab.settings")
    }
}

#Preview("Arabic RTL") {
    NavigationStack {
        SettingsView()
            .navigationTitle("tab.settings")
    }
    .arabicPreview()
}
