//
// ContactsPlaceholderView.swift
// MessageViewKitDemo
//
// Placeholder view for the Contacts tab
//

import SwiftUI

/// Placeholder view for the Contacts tab.
/// Will be replaced with actual contacts functionality later.
struct ContactsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "person.2")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                Text("tab.contacts")
                    .font(.title2)
                    .foregroundColor(.primary)

                Text("placeholder.coming_soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("tab.contacts")
        }
    }
}

#Preview {
    ContactsPlaceholderView()
}
