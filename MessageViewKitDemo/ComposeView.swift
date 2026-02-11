//
// ComposeView.swift
// MessageViewKitDemo
//
// Pure SwiftUI compose view for starting new conversations
//

import SwiftUI

/// Pure SwiftUI compose view with contact list.
struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedContact: String?
    @State private var showingConfirmation = false

    private let contacts = [
        "Alice Johnson",
        "Bob Smith",
        "Carol Williams",
        "David Brown",
        "Eve Davis",
        "Frank Miller",
        "Grace Wilson",
        "Henry Moore"
    ]

    private var filteredContacts: [String] {
        if searchText.isEmpty {
            return contacts
        }
        return contacts.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List(filteredContacts, id: \.self) { contact in
            Button {
                selectedContact = contact
                showingConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    Text(contact)
                        .foregroundStyle(.primary)
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search contacts...")
        .navigationTitle("New Message")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Start Conversation", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Start") {
                dismiss()
            }
        } message: {
            Text("Would you like to start a conversation with \(selectedContact ?? "")?")
        }
    }
}

#Preview {
    NavigationStack {
        ComposeView()
    }
}
