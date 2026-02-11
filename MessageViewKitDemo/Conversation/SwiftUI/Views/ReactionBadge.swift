//
// ReactionBadge.swift
// Conversation
//
// Small badge displaying emoji reaction count below message bubble
//

import SwiftUI

// MARK: - Reaction Badge

/// A small badge showing emoji and reaction count
public struct ReactionBadge: View {
    // MARK: - Properties

    let summary: ReactionSummary
    let onTap: () -> Void

    // MARK: - Initialization

    public init(summary: ReactionSummary, onTap: @escaping () -> Void) {
        self.summary = summary
        self.onTap = onTap
    }

    // MARK: - Body

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 2) {
                Text(summary.emoji)
                    .font(.system(size: 14))

                if summary.count > 1 {
                    Text("\(summary.count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        Color.gray.opacity(0.3),
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reaction Badges Container

/// Container view for displaying multiple reaction badges
public struct ReactionBadgesView: View {
    // MARK: - Properties

    let reactions: [Reaction]
    let currentUserId: String
    let onBadgeTap: (String) -> Void

    // MARK: - Initialization

    public init(
        reactions: [Reaction],
        currentUserId: String,
        onBadgeTap: @escaping (String) -> Void
    ) {
        self.reactions = reactions
        self.currentUserId = currentUserId
        self.onBadgeTap = onBadgeTap
    }

    // MARK: - Body

    public var body: some View {
        let summaries = ReactionSummary.summarize(reactions, currentUserId: currentUserId)

        if !summaries.isEmpty {
            HStack(spacing: 4) {
                ForEach(summaries) { summary in
                    ReactionBadge(summary: summary) {
                        onBadgeTap(summary.emoji)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ReactionBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Single reaction
            ReactionBadge(
                summary: ReactionSummary(
                    emoji: "👍",
                    reactions: [
                        Reaction(emoji: "👍", reactorId: "user1", reactorDisplayName: "Alice")
                    ],
                    currentUserId: "me"
                ),
                onTap: {}
            )

            // Multiple reactions, user reacted
            ReactionBadge(
                summary: ReactionSummary(
                    emoji: "❤️",
                    reactions: [
                        Reaction(emoji: "❤️", reactorId: "me", reactorDisplayName: "Me"),
                        Reaction(emoji: "❤️", reactorId: "user1", reactorDisplayName: "Alice")
                    ],
                    currentUserId: "me"
                ),
                onTap: {}
            )

            // Multiple badges
            ReactionBadgesView(
                reactions: [
                    Reaction(emoji: "👍", reactorId: "user1", reactorDisplayName: "Alice"),
                    Reaction(emoji: "❤️", reactorId: "me", reactorDisplayName: "Me"),
                    Reaction(emoji: "😂", reactorId: "user2", reactorDisplayName: "Bob"),
                    Reaction(emoji: "😂", reactorId: "user3", reactorDisplayName: "Carol")
                ],
                currentUserId: "me",
                onBadgeTap: { emoji in
                    print("Tapped: \(emoji)")
                }
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
