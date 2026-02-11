//
// TypingIndicator.swift
// Conversation
//
// Animated typing indicator with three bouncing dots
//

import SwiftUI

// MARK: - Typing Indicator View

/// Animated typing indicator showing three dots.
/// The dots animate with staggered scale and opacity.
public struct TypingIndicator: View {
    // MARK: - State

    @State private var isAnimating = false

    // MARK: - Body

    public init() {}

    public var body: some View {
        HStack(alignment: .center) {
            bubbleContent
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer(minLength: 60)
        }
        .padding(.horizontal, 12)
        .onAppear {
            isAnimating = true
        }
    }

    // MARK: - Subviews

    private var bubbleContent: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 0.8 : 1.0)
                    .opacity(isAnimating ? 0.3 : 1.0)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: isAnimating
                    )
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TypingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TypingIndicator()
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
