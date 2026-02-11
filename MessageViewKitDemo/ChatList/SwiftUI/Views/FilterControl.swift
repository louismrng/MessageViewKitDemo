//
// FilterControl.swift
// ChatList
//
// SwiftUI view for the unread filter toggle
//

import SwiftUI

// MARK: - Filter Control View

/// A control for filtering the chat list to show only unread conversations.
public struct FilterControl: View {
    @Environment(\.chatListStyle) private var style

    @Binding var filterMode: FilterMode
    let unreadCount: Int

    public init(filterMode: Binding<FilterMode>, unreadCount: Int = 0) {
        self._filterMode = filterMode
        self.unreadCount = unreadCount
    }

    public var body: some View {
        HStack(spacing: 12) {
            filterButton(mode: .none, label: "All")
            filterButton(mode: .unread, label: unreadLabel)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(style.backgroundColor)
    }

    @ViewBuilder
    private func filterButton(mode: FilterMode, label: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                filterMode = mode
            }
        } label: {
            Text(label)
                .font(.subheadline)
                .fontWeight(filterMode == mode ? .semibold : .regular)
                .foregroundColor(filterMode == mode ? .white : style.primaryTextColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(filterMode == mode ? style.accentColor : style.secondaryTextColor.opacity(0.15))
                )
        }
        .buttonStyle(.plain)
    }

    private var unreadLabel: String {
        if unreadCount > 0 {
            return "Unread (\(unreadCount))"
        } else {
            return "Unread"
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var filterMode: FilterMode = .none

        var body: some View {
            VStack {
                FilterControl(filterMode: $filterMode, unreadCount: 5)
                Text("Current filter: \(filterMode == .none ? "All" : "Unread")")
                    .padding()
            }
            .chatListStyle(.default)
        }
    }

    return PreviewWrapper()
}
