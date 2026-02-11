//
// Style.swift
// ChatList
//
// Extracted from Signal iOS - Styling configuration for chat list
//

import UIKit

// MARK: - Chat List Style Protocol

/// Defines the visual styling for chat list view.
/// Implement this to customize the appearance of the chat list.
public protocol ChatListStyleProvider {
    // MARK: - Colors

    /// Primary text color (thread names)
    var primaryTextColor: UIColor { get }

    /// Secondary text color (snippets, dates)
    var secondaryTextColor: UIColor { get }

    /// Background color for the list
    var backgroundColor: UIColor { get }

    /// Background color for selected cells
    var selectedBackgroundColor: UIColor { get }

    /// Accent color (unread badge, etc.)
    var accentColor: UIColor { get }

    /// Destructive color (failed message indicator)
    var destructiveColor: UIColor { get }

    /// Mute icon tint color
    var muteIconColor: UIColor { get }

    /// Whether dark theme is enabled
    var isDarkTheme: Bool { get }

    // MARK: - Typography

    /// Font for thread names
    var nameFont: UIFont { get }

    /// Font for message snippets
    var snippetFont: UIFont { get }

    /// Font for date/time labels
    var dateFont: UIFont { get }

    /// Font for unread count badge
    var unreadBadgeFont: UIFont { get }

    // MARK: - Layout

    /// Avatar size in points
    var avatarSize: CGFloat { get }

    /// Spacing between avatar and content
    var avatarContentSpacing: CGFloat { get }

    /// Vertical padding for cells
    var cellVerticalPadding: CGFloat { get }

    /// Badge/icon size
    var iconSize: CGFloat { get }
}

// MARK: - Default Style Implementation

/// Default styling that mimics Signal's chat list appearance
public class ChatListDefaultStyle: ChatListStyleProvider {

    public static let shared = ChatListDefaultStyle()

    private init() {}

    // MARK: - Colors

    public var primaryTextColor: UIColor {
        .label
    }

    public var secondaryTextColor: UIColor {
        .secondaryLabel
    }

    public var backgroundColor: UIColor {
        .systemBackground
    }

    public var selectedBackgroundColor: UIColor {
        .systemGray4
    }

    public var accentColor: UIColor {
        .systemBlue
    }

    public var destructiveColor: UIColor {
        .systemRed
    }

    public var muteIconColor: UIColor {
        .secondaryLabel
    }

    public var isDarkTheme: Bool {
        UITraitCollection.current.userInterfaceStyle == .dark
    }

    // MARK: - Typography

    public var nameFont: UIFont {
        .preferredFont(forTextStyle: .headline)
    }

    public var snippetFont: UIFont {
        .preferredFont(forTextStyle: .subheadline)
    }

    public var dateFont: UIFont {
        .preferredFont(forTextStyle: .subheadline)
    }

    public var unreadBadgeFont: UIFont {
        .preferredFont(forTextStyle: .footnote)
    }

    // MARK: - Layout

    public var avatarSize: CGFloat { 56.0 }

    public var avatarContentSpacing: CGFloat { 12.0 }

    public var cellVerticalPadding: CGFloat { 12.0 }

    public var iconSize: CGFloat { 16.0 }
}

// MARK: - Style Helpers

public extension ChatListStyleProvider {
    /// Get text color for message status
    func statusIconColor(for status: MessageStatus) -> UIColor {
        switch status {
        case .failed:
            return destructiveColor
        case .pending:
            return secondaryTextColor
        default:
            return secondaryTextColor
        }
    }
}
