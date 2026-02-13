//
// UnreadBadge.swift
// ChatList
//
// SwiftUI view for the unread message count badge
//

import SwiftUI

// MARK: - Unread Badge View

/// A pill-shaped badge showing the unread message count.
public struct UnreadBadge: View {
    @Environment(\.chatListStyle) private var style

    let count: UInt

    public init(count: UInt) {
        self.count = count
    }

    public var body: some View {
        Text(badgeText)
            .font(style.unreadBadgeFont)
            .foregroundColor(.white)
            .padding(.horizontal, horizontalPadding)
            .frame(minWidth: minWidth, minHeight: minHeight)
            .background(
                Capsule()
                    .fill(style.accentColor)
            )
    }

    private var badgeText: String {
        if count == 0 {
            // Thread is marked unread but count is unknown
            return " "
        } else if count > 999 {
            return "999+"
        } else {
            return "\(count)"
        }
    }

    private var minWidth: CGFloat {
        // Ensure badge is at least as wide as it is tall (circular for single digit)
        minHeight
    }

    private var minHeight: CGFloat {
        // Based on font line height
        20
    }

    private var horizontalPadding: CGFloat {
        count == 0 ? 4 : 6
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            UnreadBadge(count: 1)
            UnreadBadge(count: 9)
            UnreadBadge(count: 42)
            UnreadBadge(count: 999)
            UnreadBadge(count: 1500)
        }

        HStack(spacing: 16) {
            UnreadBadge(count: 0) // Marked unread, no count
        }
    }
    .padding()
    .chatListStyle(.default)
}

#Preview("Arabic RTL") {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            UnreadBadge(count: 1)
            UnreadBadge(count: 9)
            UnreadBadge(count: 42)
            UnreadBadge(count: 999)
            UnreadBadge(count: 1500)
        }

        HStack(spacing: 16) {
            UnreadBadge(count: 0)
        }
    }
    .padding()
    .chatListStyle(.default)
    .arabicPreview()
}
