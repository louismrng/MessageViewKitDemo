//
// ContextMenuOverlay.swift
// Conversation
//
// Full-screen overlay for context menu with blur background
//

import SwiftUI

// MARK: - Context Menu Overlay

/// Full-screen overlay displaying reaction picker and context menu for a message
public struct ContextMenuOverlay: View {
    // MARK: - Environment

    @Environment(\.conversationStyle) private var style

    // MARK: - Properties

    let message: AnyMessage
    let sourceFrame: CGRect
    let currentUserId: String
    let onReact: (String) -> Void
    let onAction: (ContextMenuAction) -> Void
    let onDismiss: () -> Void

    // MARK: - State

    @State private var appeared = false
    @State private var showingEmojiKeyboard = false
    @State private var bubbleHeight: CGFloat = 0

    // MARK: - Layout Constants

    private let pickerHeight: CGFloat = 50
    private let menuHeight: CGFloat = 264  // 6 items × 44pt each
    private let spacing: CGFloat = 12
    private let edgePadding: CGFloat = 16

    // MARK: - Initialization

    public init(
        message: AnyMessage,
        sourceFrame: CGRect,
        currentUserId: String = "me",
        onReact: @escaping (String) -> Void,
        onAction: @escaping (ContextMenuAction) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.message = message
        self.sourceFrame = sourceFrame
        self.currentUserId = currentUserId
        self.onReact = onReact
        self.onAction = onAction
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background - tap to dismiss
                Group {
                    Color.clear
                        .background(.ultraThinMaterial)
                }
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

                // Content positioned based on source frame
                VStack(spacing: spacing) {
                    // Reaction picker
                    ReactionPicker(
                        onSelectEmoji: { emoji in
                            onReact(emoji)
                            dismiss()
                        },
                        onMore: {
                            showingEmojiKeyboard = true
                        },
                        onDismiss: {}
                    )

                    // Message bubble preview
                    messageBubblePreview
                        .padding(.horizontal, 12)
                        .background(
                            GeometryReader { bubbleGeometry in
                                Color.clear
                                    .onAppear {
                                        bubbleHeight = bubbleGeometry.size.height
                                    }
                            }
                        )

                    // Context menu
                    MessageContextMenu(
                        message: message,
                        onAction: { action in
                            onAction(action)
                            dismiss()
                        }
                    )
                }
                .scaleEffect(appeared ? 1.0 : 0.95)
                .opacity(appeared ? 1.0 : 0.0)
                .position(
                    x: geometry.size.width / 2,
                    y: calculateVerticalPosition(in: geometry)
                )
            }
        }
        .onAppear {
            triggerHaptic()
            withAnimation(.easeOut(duration: 0.25)) {
                appeared = true
            }
        }
        .overlay {
            if showingEmojiKeyboard {
                EmojiKeyboardPicker(
                    onSelectEmoji: { emoji in
                        showingEmojiKeyboard = false
                        onReact(emoji)
                        dismiss()
                    },
                    onDismiss: {
                        showingEmojiKeyboard = false
                    }
                )
                .frame(width: 1, height: 1)
            }
        }
    }

    // MARK: - Position Calculation

    private func calculateVerticalPosition(in geometry: GeometryProxy) -> CGFloat {
        let effectiveBubbleHeight = bubbleHeight > 0 ? bubbleHeight : sourceFrame.height

        // Total VStack height: [picker] - [spacing] - [bubble] - [spacing] - [menu]
        let totalVStackHeight = pickerHeight + spacing + effectiveBubbleHeight + spacing + menuHeight

        // Calculate ideal position (keeps bubble at original location)
        let aboveBubble = pickerHeight + spacing + effectiveBubbleHeight / 2
        let belowBubble = effectiveBubbleHeight / 2 + spacing + menuHeight
        let vstackCenterOffset = (belowBubble - aboveBubble) / 2
        let idealCenterY = sourceFrame.midY + vstackCenterOffset

        // Calculate bounds for VStack center position
        let minCenterY = totalVStackHeight / 2 + edgePadding
        let maxCenterY = geometry.size.height - totalVStackHeight / 2 - edgePadding

        // Clamp to keep entire VStack visible
        return min(max(idealCenterY, minCenterY), maxCenterY)
    }

    // MARK: - Message Bubble Preview

    @ViewBuilder
    private var messageBubblePreview: some View {
        HStack {
            if message.isOutgoing {
                Spacer(minLength: 60)
            }

            if message.image != nil {
                ImageBubble(message: message)
            } else {
                TextBubble(message: message)
            }

            if !message.isOutgoing {
                Spacer(minLength: 60)
            }
        }
    }

    // MARK: - Dismiss

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            appeared = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }

    // MARK: - Haptic Feedback

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - Preview

#if DEBUG
struct ContextMenuOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ContextMenuOverlay(
            message: AnyMessage(MockMessage(
                bodyText: "Hello! This is a test message.",
                isOutgoing: true,
                deliveryStatus: .delivered
            )),
            sourceFrame: CGRect(x: 100, y: 400, width: 200, height: 60),
            onReact: { emoji in
                print("React: \(emoji)")
            },
            onAction: { action in
                print("Action: \(action.title)")
            },
            onDismiss: {
                print("Dismissed")
            }
        )
    }
}
#endif
