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
                    Label("Messages", systemImage: "message")
                }

            NavigationStack {
                ContactsPlaceholderView()
                    .navigationTitle("Contacts")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tag(Tab.contacts)
            .tabItem {
                Label("Contacts", systemImage: "person.2")
            }

            NavigationStack {
                CallLogPlaceholderView()
                    .navigationTitle("Call Log")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tag(Tab.callLog)
            .tabItem {
                Label("Call Log", systemImage: "phone.arrow.up.right")
            }

            NavigationStack {
                StoragePlaceholderView()
                    .navigationTitle("Storage")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tag(Tab.storage)
            .tabItem {
                Label("Storage", systemImage: "externaldrive")
            }

            NavigationStack {
                SettingsTabView()
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tag(Tab.settings)
            .tabItem {
                Label("Settings", systemImage: "gear")
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
