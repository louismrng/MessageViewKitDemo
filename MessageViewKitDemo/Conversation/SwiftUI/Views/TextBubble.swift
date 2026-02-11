//
// TextBubble.swift
// Conversation
//
// Text message bubble view for SwiftUI
//

import SwiftUI

// MARK: - Text Bubble View

/// Displays a text message with timestamp and delivery status.
public struct TextBubble: View {
    // MARK: - Environment

    @Environment(\.conversationStyle) private var style

    // MARK: - Properties

    let message: AnyMessage

    // MARK: - Initialization

    public init(message: AnyMessage) {
        self.message = message
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Text content
            Text(message.bodyText ?? "")
                .font(.body)
                .foregroundColor(style.textColor(for: message))
                .fixedSize(horizontal: false, vertical: true)

            // Footer with timestamp and status
            footerView
        }
        .padding(style.bubbleContentInsets)
        .background(style.bubbleColor(for: message))
        .clipShape(RoundedRectangle(cornerRadius: style.bubbleCornerRadius))
    }

    // MARK: - Footer View

    private var footerView: some View {
        HStack(spacing: 4) {
            Text(formattedTime)
                .font(.caption2)
                .foregroundColor(style.footerTextColor(for: message))

            if message.isOutgoing, let iconName = message.deliveryStatus.iconName {
                Image(systemName: iconName)
                    .font(.caption2)
                    .foregroundColor(statusIconColor)
            }
        }
    }

    // MARK: - Helpers

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }

    private var statusIconColor: Color {
        if message.deliveryStatus.isFailure {
            return .red
        }
        return style.footerTextColor(for: message)
    }
}

// MARK: - Preview

#if DEBUG
struct TextBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            // Incoming message
            HStack {
                TextBubble(message: AnyMessage(MockMessage(
                    bodyText: "Hey! How are you?",
                    isOutgoing: false
                )))
                Spacer(minLength: 60)
            }

            // Outgoing message
            HStack {
                Spacer(minLength: 60)
                TextBubble(message: AnyMessage(MockMessage(
                    bodyText: "I'm doing great, thanks!",
                    isOutgoing: true,
                    deliveryStatus: .delivered
                )))
            }

            // Long message
            HStack {
                TextBubble(message: AnyMessage(MockMessage(
                    bodyText: "This is a longer message that should wrap to multiple lines and demonstrate how the bubble expands.",
                    isOutgoing: false
                )))
                Spacer(minLength: 60)
            }

            // Failed message
            HStack {
                Spacer(minLength: 60)
                TextBubble(message: AnyMessage(MockMessage(
                    bodyText: "Failed to send",
                    isOutgoing: true,
                    deliveryStatus: .failed("Network error")
                )))
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
