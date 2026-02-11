//
// SectionHeader.swift
// ChatList
//
// SwiftUI view for section headers (Pinned/Chats)
//

import SwiftUI

// MARK: - Section Header View

/// A section header for the chat list (e.g., "PINNED", "CHATS").
public struct SectionHeader: View {
    @Environment(\.chatListStyle) private var style

    let title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(style.secondaryTextColor)
                .tracking(0.5)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .background(style.backgroundColor)
    }
}

// MARK: - Predefined Headers

public extension SectionHeader {
    /// Header for the pinned section
    static var pinned: SectionHeader {
        SectionHeader(title: "Pinned")
    }

    /// Header for the chats section
    static var chats: SectionHeader {
        SectionHeader(title: "Chats")
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        SectionHeader.pinned
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 60)

        SectionHeader.chats
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 120)
    }
    .chatListStyle(.default)
}
