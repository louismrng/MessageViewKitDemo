//
// Style.swift
// Conversation
//
// Extracted from Signal iOS - Styling configuration for message bubbles
//

import UIKit

// MARK: - Conversation Style Protocol

/// Defines the visual styling for conversation view.
/// Replaces Signal's ConversationStyle with a protocol-based approach.
public protocol ConversationStyleProvider {
    // MARK: - Colors

    /// Background color for outgoing message bubbles
    var outgoingBubbleColor: UIColor { get }

    /// Background color for incoming message bubbles
    var incomingBubbleColor: UIColor { get }

    /// Text color for outgoing messages
    var outgoingTextColor: UIColor { get }

    /// Text color for incoming messages
    var incomingTextColor: UIColor { get }

    /// Secondary text color (timestamps, status)
    var secondaryTextColor: UIColor { get }

    /// Whether dark theme is enabled
    var isDarkTheme: Bool { get }

    // MARK: - Layout

    /// Maximum width for message content (relative to view width)
    var maxMessageWidthRatio: CGFloat { get }

    /// Bubble corner radius
    var bubbleCornerRadius: CGFloat { get }

    /// Spacing between messages from same sender
    var compactMessageSpacing: CGFloat { get }

    /// Spacing between messages from different senders
    var standardMessageSpacing: CGFloat { get }

    /// Content insets within bubble
    var bubbleContentInsets: UIEdgeInsets { get }
}

// MARK: - Default Style Implementation

/// Default styling that mimics Signal's appearance
public class ConversationDefaultStyle: ConversationStyleProvider {

    public static let shared = ConversationDefaultStyle()

    private init() {}

    // MARK: - Colors

    public var outgoingBubbleColor: UIColor {
        UIColor.systemBlue
    }

    public var incomingBubbleColor: UIColor {
        isDarkTheme
            ? UIColor(white: 0.25, alpha: 1.0)
            : UIColor(white: 0.9, alpha: 1.0)
    }

    public var outgoingTextColor: UIColor {
        .white
    }

    public var incomingTextColor: UIColor {
        isDarkTheme ? .white : .black
    }

    public var secondaryTextColor: UIColor {
        .secondaryLabel
    }

    public var isDarkTheme: Bool {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
        return false
    }

    // MARK: - Layout

    public var maxMessageWidthRatio: CGFloat { 0.75 }

    public var bubbleCornerRadius: CGFloat { 18.0 }

    public var compactMessageSpacing: CGFloat { 2.0 }

    public var standardMessageSpacing: CGFloat { 12.0 }

    public var bubbleContentInsets: UIEdgeInsets {
        UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }
}

// MARK: - Style Helpers

public extension ConversationStyleProvider {

    /// Get bubble color for a message
    func bubbleColor(for message: Message) -> UIColor {
        message.isOutgoing ? outgoingBubbleColor : incomingBubbleColor
    }

    /// Get text color for a message
    func textColor(for message: Message) -> UIColor {
        message.isOutgoing ? outgoingTextColor : incomingTextColor
    }

    /// Calculate max message width for given view width
    func maxMessageWidth(for viewWidth: CGFloat) -> CGFloat {
        viewWidth * maxMessageWidthRatio
    }
}
