//
// EmptyInboxView.swift
// ChatList
//
// SwiftUI view for the empty inbox state
//

import SwiftUI

// MARK: - Empty Inbox View

/// View shown when there are no threads to display.
public struct EmptyInboxView: View {
    @Environment(\.chatListStyle) private var style

    let isFiltered: Bool
    let onClearFilter: (() -> Void)?

    public init(isFiltered: Bool = false, onClearFilter: (() -> Void)? = nil) {
        self.isFiltered = isFiltered
        self.onClearFilter = onClearFilter
    }

    public var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: iconName)
                .font(.system(size: 64))
                .foregroundColor(style.secondaryTextColor.opacity(0.5))

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(style.primaryTextColor)

            Text(subtitle)
                .font(.body)
                .foregroundColor(style.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if isFiltered, let onClearFilter = onClearFilter {
                Button(action: onClearFilter) {
                    Text("chat_list.empty.clear_filter")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(style.accentColor)
                }
                .padding(.top, 8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(style.backgroundColor)
    }

    private var iconName: String {
        isFiltered ? "line.3.horizontal.decrease.circle" : "bubble.left.and.bubble.right"
    }

    private var title: String {
        isFiltered
            ? String(localized: "chat_list.empty.no_results")
            : String(localized: "chat_list.empty.no_conversations")
    }

    private var subtitle: String {
        if isFiltered {
            return String(localized: "chat_list.empty.filter_subtitle")
        } else {
            return String(localized: "chat_list.empty.default_subtitle")
        }
    }
}

// MARK: - Preview

#Preview("Empty Inbox") {
    EmptyInboxView()
        .chatListStyle(.default)
}

#Preview("Filtered Empty") {
    EmptyInboxView(isFiltered: true) {
        print("Clear filter tapped")
    }
    .chatListStyle(.default)
}
