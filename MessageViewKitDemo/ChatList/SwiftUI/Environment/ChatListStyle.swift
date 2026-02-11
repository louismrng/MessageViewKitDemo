//
// ChatListStyle.swift
// ChatList
//
// SwiftUI style struct and environment key for style propagation
//

import SwiftUI
import UIKit

// MARK: - SwiftUI Style Struct

/// SwiftUI-native style struct bridged from ChatListStyleProvider.
/// This provides SwiftUI Color values for use in SwiftUI views.
public struct ChatListStyle {
    // MARK: - Colors

    /// Primary text color (thread names)
    public let primaryTextColor: Color

    /// Secondary text color (snippets, dates)
    public let secondaryTextColor: Color

    /// Background color for the list
    public let backgroundColor: Color

    /// Background color for selected cells
    public let selectedBackgroundColor: Color

    /// Accent color (unread badge, etc.)
    public let accentColor: Color

    /// Destructive color (failed message indicator)
    public let destructiveColor: Color

    /// Mute icon tint color
    public let muteIconColor: Color

    // MARK: - Typography

    /// Font for thread names
    public let nameFont: Font

    /// Font for message snippets
    public let snippetFont: Font

    /// Font for date/time labels
    public let dateFont: Font

    /// Font for unread count badge
    public let unreadBadgeFont: Font

    // MARK: - Layout

    /// Avatar size in points
    public let avatarSize: CGFloat

    /// Spacing between avatar and content
    public let avatarContentSpacing: CGFloat

    /// Vertical padding for cells
    public let cellVerticalPadding: CGFloat

    /// Badge/icon size
    public let iconSize: CGFloat

    // MARK: - Initialization

    /// Initialize from a ChatListStyleProvider (bridges UIKit to SwiftUI)
    public init(from provider: ChatListStyleProvider) {
        self.primaryTextColor = Color(provider.primaryTextColor)
        self.secondaryTextColor = Color(provider.secondaryTextColor)
        self.backgroundColor = Color(provider.backgroundColor)
        self.selectedBackgroundColor = Color(provider.selectedBackgroundColor)
        self.accentColor = Color(provider.accentColor)
        self.destructiveColor = Color(provider.destructiveColor)
        self.muteIconColor = Color(provider.muteIconColor)
        self.nameFont = Font(provider.nameFont)
        self.snippetFont = Font(provider.snippetFont)
        self.dateFont = Font(provider.dateFont)
        self.unreadBadgeFont = Font(provider.unreadBadgeFont)
        self.avatarSize = provider.avatarSize
        self.avatarContentSpacing = provider.avatarContentSpacing
        self.cellVerticalPadding = provider.cellVerticalPadding
        self.iconSize = provider.iconSize
    }

    /// Initialize with explicit SwiftUI values
    public init(
        primaryTextColor: Color = .primary,
        secondaryTextColor: Color = .secondary,
        backgroundColor: Color = Color(UIColor.systemBackground),
        selectedBackgroundColor: Color = Color(UIColor.systemGray4),
        accentColor: Color = .blue,
        destructiveColor: Color = .red,
        muteIconColor: Color = .secondary,
        nameFont: Font = .headline,
        snippetFont: Font = .subheadline,
        dateFont: Font = .subheadline,
        unreadBadgeFont: Font = .footnote,
        avatarSize: CGFloat = 56.0,
        avatarContentSpacing: CGFloat = 12.0,
        cellVerticalPadding: CGFloat = 12.0,
        iconSize: CGFloat = 16.0
    ) {
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.backgroundColor = backgroundColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.accentColor = accentColor
        self.destructiveColor = destructiveColor
        self.muteIconColor = muteIconColor
        self.nameFont = nameFont
        self.snippetFont = snippetFont
        self.dateFont = dateFont
        self.unreadBadgeFont = unreadBadgeFont
        self.avatarSize = avatarSize
        self.avatarContentSpacing = avatarContentSpacing
        self.cellVerticalPadding = cellVerticalPadding
        self.iconSize = iconSize
    }

    // MARK: - Default Style

    /// Default style matching ChatListDefaultStyle
    public static let `default` = ChatListStyle(from: ChatListDefaultStyle.shared)
}

// MARK: - Style Helpers

public extension ChatListStyle {
    /// Get text color for message status
    func statusIconColor(for status: MessageStatus) -> Color {
        switch status {
        case .failed:
            return destructiveColor
        case .pending:
            return secondaryTextColor
        default:
            return secondaryTextColor
        }
    }

    /// Get status icon color for read receipts (blue for read/viewed)
    func readReceiptColor(for status: MessageStatus) -> Color {
        switch status {
        case .read, .viewed:
            return accentColor
        default:
            return statusIconColor(for: status)
        }
    }
}

// MARK: - Environment Key

private struct ChatListStyleKey: EnvironmentKey {
    static let defaultValue: ChatListStyle = .default
}

public extension EnvironmentValues {
    /// The ChatList style for this view hierarchy
    var chatListStyle: ChatListStyle {
        get { self[ChatListStyleKey.self] }
        set { self[ChatListStyleKey.self] = newValue }
    }
}

// MARK: - View Extension

public extension View {
    /// Sets the ChatList style for this view and its descendants.
    ///
    /// Usage:
    /// ```swift
    /// ChatListView(viewModel: viewModel)
    ///     .chatListStyle(ChatListStyle(accentColor: .green))
    /// ```
    func chatListStyle(_ style: ChatListStyle) -> some View {
        environment(\.chatListStyle, style)
    }

    /// Sets the ChatList style from a ChatListStyleProvider.
    ///
    /// Usage:
    /// ```swift
    /// ChatListView(viewModel: viewModel)
    ///     .chatListStyle(from: MyCustomStyleProvider())
    /// ```
    func chatListStyle(from provider: ChatListStyleProvider) -> some View {
        environment(\.chatListStyle, ChatListStyle(from: provider))
    }
}
