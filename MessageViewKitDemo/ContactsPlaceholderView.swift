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

                Text("Contacts")
                    .font(.title2)
                    .foregroundColor(.primary)

                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Contacts")
        }
    }
}

#Preview {
    ContactsPlaceholderView()
}
