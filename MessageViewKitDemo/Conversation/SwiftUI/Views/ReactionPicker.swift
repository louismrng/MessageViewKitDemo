//
// ReactionPicker.swift
// Conversation
//
// Horizontal emoji picker overlay for adding reactions to messages
//

import SwiftUI

// MARK: - Reaction Picker

/// A pill-shaped emoji picker that appears on long-press
public struct ReactionPicker: View {
    // MARK: - Properties

    let onSelectEmoji: (String) -> Void
    let onMore: (() -> Void)?
    let onDismiss: () -> Void

    @State private var appeared = false

    // MARK: - Initialization

    public init(
        onSelectEmoji: @escaping (String) -> Void,
        onMore: (() -> Void)? = nil,
        onDismiss: @escaping () -> Void
    ) {
        self.onSelectEmoji = onSelectEmoji
        self.onMore = onMore
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(ReactionEmoji.allCases) { emoji in
                Button {
                    triggerHaptic()
                    onSelectEmoji(emoji.rawValue)
                } label: {
                    Text(emoji.rawValue)
                        .font(.system(size: 28))
                }
                .buttonStyle(.plain)
            }

            // "More" button for full emoji keyboard
            if onMore != nil {
                Divider()
                    .frame(height: 24)

                Button {
                    triggerHaptic()
                    onMore?()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color(.systemGray5))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(appeared ? 1.0 : 0.5)
        .opacity(appeared ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                appeared = true
            }
            triggerHaptic()
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
struct ReactionPicker_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .ignoresSafeArea()

            ReactionPicker(
                onSelectEmoji: { emoji in
                    print("Selected: \(emoji)")
                },
                onDismiss: {
                    print("Dismissed")
                }
            )
        }
    }
}
#endif
