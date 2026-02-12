//
// CallLogPlaceholderView.swift
// MessageViewKitDemo
//
// Placeholder view for the Call Log tab
//

import SwiftUI

/// Placeholder view for the Call Log tab.
/// Will be replaced with actual call log functionality later.
struct CallLogPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "phone.arrow.up.right")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                Text("tab.call_log")
                    .font(.title2)
                    .foregroundColor(.primary)

                Text("placeholder.coming_soon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("tab.call_log")
        }
    }
}

#Preview {
    CallLogPlaceholderView()
}
