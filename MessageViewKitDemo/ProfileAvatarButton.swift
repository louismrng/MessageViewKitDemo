//
// ProfileAvatarButton.swift
// MessageViewKitDemo
//
// Circular profile avatar button for the navigation bar (Signal-style)
//

import SwiftUI

/// A circular profile avatar button used in the navigation bar.
/// Displays user initials or a placeholder, similar to Signal's profile button.
struct ProfileAvatarButton: View {
    let action: () -> Void
    let size: CGFloat

    init(size: CGFloat = 28, action: @escaping () -> Void) {
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.blue)
                .frame(width: size, height: size)
                .overlay(
                    Text("profile.initials")
                        .font(.system(size: size * 0.4, weight: .medium))
                        .foregroundColor(.white)
                )
        }
        .accessibilityLabel("profile.settings_label")
    }
}

#Preview {
    ProfileAvatarButton(action: {})
}
