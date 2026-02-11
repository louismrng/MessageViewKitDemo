//
// StoragePlaceholderView.swift
// MessageViewKitDemo
//
// Placeholder view for the Storage tab
//

import SwiftUI

/// Placeholder view for the Storage tab.
/// Will be replaced with actual storage management functionality later.
struct StoragePlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "externaldrive")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                Text("Storage")
                    .font(.title2)
                    .foregroundColor(.primary)

                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Storage")
        }
    }
}

#Preview {
    StoragePlaceholderView()
}
