//
// ConversationStyle.swift
// Conversation
//
// SwiftUI style struct and environment key for style propagation
//

import SwiftUI
import UIKit

// MARK: - SwiftUI Style Struct

/// SwiftUI-native style struct bridged from ConversationStyleProvider.
/// This provides SwiftUI Color values for use in SwiftUI views.
public struct ConversationStyle {
    // MARK: - Colors

    /// Background color for outgoing message bubbles
    public let outgoingBubbleColor: Color

    /// Background color for incoming message bubbles
    public let incomingBubbleColor: Color

    /// Text color for outgoing messages
    public let outgoingTextColor: Color

    /// Text color for incoming messages
    public let incomingTextColor: Color

    /// Secondary text color (timestamps, status)
    public let secondaryTextColor: Color

    // MARK: - Layout

    /// Maximum width for message content (relative to view width)
    public let maxMessageWidthRatio: CGFloat

    /// Bubble corner radius
    public let bubbleCornerRadius: CGFloat

    /// Spacing between messages from same sender
    public let compactMessageSpacing: CGFloat

    /// Spacing between messages from different senders
    public let standardMessageSpacing: CGFloat

    /// Content insets within bubble
    public let bubbleContentInsets: EdgeInsets

    // MARK: - Initialization

    /// Initialize from a ConversationStyleProvider (bridges UIKit colors to SwiftUI)
    public init(from provider: ConversationStyleProvider) {
        self.outgoingBubbleColor = Color(provider.outgoingBubbleColor)
        self.incomingBubbleColor = Color(provider.incomingBubbleColor)
        self.outgoingTextColor = Color(provider.outgoingTextColor)
        self.incomingTextColor = Color(provider.incomingTextColor)
        self.secondaryTextColor = Color(provider.secondaryTextColor)
        self.maxMessageWidthRatio = provider.maxMessageWidthRatio
        self.bubbleCornerRadius = provider.bubbleCornerRadius
        self.compactMessageSpacing = provider.compactMessageSpacing
        self.standardMessageSpacing = provider.standardMessageSpacing
        self.bubbleContentInsets = EdgeInsets(
            top: provider.bubbleContentInsets.top,
            leading: provider.bubbleContentInsets.left,
            bottom: provider.bubbleContentInsets.bottom,
            trailing: provider.bubbleContentInsets.right
        )
    }

    /// Initialize with explicit SwiftUI colors
    public init(
        outgoingBubbleColor: Color = .blue,
        incomingBubbleColor: Color = Color(UIColor.systemGray5),
        outgoingTextColor: Color = .white,
        incomingTextColor: Color = .primary,
        secondaryTextColor: Color = .secondary,
        maxMessageWidthRatio: CGFloat = 0.75,
        bubbleCornerRadius: CGFloat = 18.0,
        compactMessageSpacing: CGFloat = 2.0,
        standardMessageSpacing: CGFloat = 12.0,
        bubbleContentInsets: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    ) {
        self.outgoingBubbleColor = outgoingBubbleColor
        self.incomingBubbleColor = incomingBubbleColor
        self.outgoingTextColor = outgoingTextColor
        self.incomingTextColor = incomingTextColor
        self.secondaryTextColor = secondaryTextColor
        self.maxMessageWidthRatio = maxMessageWidthRatio
        self.bubbleCornerRadius = bubbleCornerRadius
        self.compactMessageSpacing = compactMessageSpacing
        self.standardMessageSpacing = standardMessageSpacing
        self.bubbleContentInsets = bubbleContentInsets
    }

    // MARK: - Default Style

    /// Default style matching ConversationDefaultStyle
    public static let `default` = ConversationStyle(from: ConversationDefaultStyle.shared)
}

// MARK: - Style Helpers

public extension ConversationStyle {
    /// Get bubble color for a message
    func bubbleColor(for message: Message) -> Color {
        message.isOutgoing ? outgoingBubbleColor : incomingBubbleColor
    }

    /// Get text color for a message
    func textColor(for message: Message) -> Color {
        message.isOutgoing ? outgoingTextColor : incomingTextColor
    }

    /// Get footer text color for a message (timestamp, status)
    func footerTextColor(for message: Message) -> Color {
        message.isOutgoing ? outgoingTextColor.opacity(0.7) : secondaryTextColor
    }

    /// Calculate max message width for given view width
    func maxMessageWidth(for viewWidth: CGFloat) -> CGFloat {
        viewWidth * maxMessageWidthRatio
    }
}

// MARK: - Environment Key

private struct ConversationStyleKey: EnvironmentKey {
    static let defaultValue: ConversationStyle = .default
}

public extension EnvironmentValues {
    /// The Conversation style for this view hierarchy
    var conversationStyle: ConversationStyle {
        get { self[ConversationStyleKey.self] }
        set { self[ConversationStyleKey.self] = newValue }
    }
}

// MARK: - View Extension

public extension View {
    /// Sets the Conversation style for this view and its descendants.
    ///
    /// Usage:
    /// ```swift
    /// ConversationContentView(viewModel: viewModel)
    ///     .conversationStyle(ConversationStyle(outgoingBubbleColor: .green))
    /// ```
    func conversationStyle(_ style: ConversationStyle) -> some View {
        environment(\.conversationStyle, style)
    }

    /// Sets the Conversation style from a ConversationStyleProvider.
    ///
    /// Usage:
    /// ```swift
    /// ConversationContentView(viewModel: viewModel)
    ///     .conversationStyle(from: MyCustomStyleProvider())
    /// ```
    func conversationStyle(from provider: ConversationStyleProvider) -> some View {
        environment(\.conversationStyle, ConversationStyle(from: provider))
    }
}
