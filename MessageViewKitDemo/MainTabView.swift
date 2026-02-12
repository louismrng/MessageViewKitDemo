//
// MainTabView.swift
// MessageViewKitDemo
//
// Root SwiftUI view with TabView containing tabs.
//

import SwiftUI

/// The root view for the app with tab bar.
/// Contains Messages, Contacts, Call Log, Storage, and Settings tabs.
struct MainTabView: View {
    @StateObject private var dataProvider = MockDataProvider()
    @State private var selectedTab: Tab = .messages

    enum Tab {
        case messages, contacts, callLog, storage, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ChatListTab(dataProvider: dataProvider)
                .tag(Tab.messages)
                .tabItem {
                    Label("tab.messages", systemImage: "message")
                }

            NavigationStack {
                ContactsPlaceholderView()
                    .navigationTitle("tab.contacts")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tag(Tab.contacts)
            .tabItem {
                Label("tab.contacts", systemImage: "person.2")
            }

            NavigationStack {
                CallLogPlaceholderView()
                    .navigationTitle("tab.call_log")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tag(Tab.callLog)
            .tabItem {
                Label("tab.call_log", systemImage: "phone.arrow.up.right")
            }

            NavigationStack {
                StoragePlaceholderView()
                    .navigationTitle("tab.storage")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tag(Tab.storage)
            .tabItem {
                Label("tab.storage", systemImage: "externaldrive")
            }

            NavigationStack {
                SettingsTabView()
                    .navigationTitle("tab.settings")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tag(Tab.settings)
            .tabItem {
                Label("tab.settings", systemImage: "gear")
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dataProvider.startSimulation()
            }
        }
    }
}

#Preview {
    MainTabView()
}

#Preview("Arabic RTL") {
    MainTabView()
        .arabicPreview()
}
