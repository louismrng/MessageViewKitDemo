//
// ImageBubble.swift
// Conversation
//
// Image message bubble view for SwiftUI
//

import SwiftUI

// MARK: - Image Bubble View

/// Displays an image message with timestamp and delivery status overlay.
public struct ImageBubble: View {
    // MARK: - Constants

    private static let minAspectRatio: CGFloat = 0.5
    private static let maxAspectRatio: CGFloat = 2.0

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
        ZStack(alignment: .bottomTrailing) {
            // Image content
            imageContent

            // Overlay footer
            footerOverlay
                .padding(8)
        }
        .clipShape(RoundedRectangle(cornerRadius: style.bubbleCornerRadius))
    }

    // MARK: - Image Content

    @ViewBuilder
    private var imageContent: some View {
        if let uiImage = message.image {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(clampedAspectRatio(for: uiImage), contentMode: .fit)
        } else {
            // Placeholder for missing image
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(1.0, contentMode: .fit)
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
        }
    }

    // MARK: - Footer Overlay

    private var footerOverlay: some View {
        HStack(spacing: 4) {
            Text(formattedTime)
                .font(.caption2)
                .foregroundColor(.white)

            if message.isOutgoing, let iconName = message.deliveryStatus.iconName {
                Image(systemName: iconName)
                    .font(.caption2)
                    .foregroundColor(statusIconColor)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.5))
        .clipShape(Capsule())
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
        return .white
    }

    private func clampedAspectRatio(for image: UIImage) -> CGFloat {
        guard image.size.height > 0 else { return 1.0 }
        let ratio = image.size.width / image.size.height
        return min(max(ratio, Self.minAspectRatio), Self.maxAspectRatio)
    }
}

// MARK: - Preview

#if DEBUG
struct ImageBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            // Incoming image
            HStack {
                ImageBubble(message: AnyMessage(MockMessage(
                    image: UIImage(systemName: "photo.fill")?
                        .withConfiguration(UIImage.SymbolConfiguration(pointSize: 100)),
                    isOutgoing: false
                )))
                .frame(width: 200)
                Spacer()
            }

            // Outgoing image
            HStack {
                Spacer()
                ImageBubble(message: AnyMessage(MockMessage(
                    image: UIImage(systemName: "photo.fill")?
                        .withConfiguration(UIImage.SymbolConfiguration(pointSize: 100)),
                    isOutgoing: true,
                    deliveryStatus: .delivered
                )))
                .frame(width: 200)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
