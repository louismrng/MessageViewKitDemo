//
// ReactionDetailsSheet.swift
// Conversation
//
// Sheet showing who reacted to a message, grouped by emoji
//

import SwiftUI

// MARK: - Reaction Details Sheet

/// A sheet displaying all reactions on a message, grouped by emoji
public struct ReactionDetailsSheet: View {
    // MARK: - Properties

    let reactions: [Reaction]
    let currentUserId: String
    let onRemoveReaction: (Reaction) -> Void
    let onDismiss: () -> Void

    @State private var selectedEmoji: String?

    // MARK: - Computed Properties

    private var summaries: [ReactionSummary] {
        ReactionSummary.summarize(reactions, currentUserId: currentUserId)
    }

    // MARK: - Initialization

    public init(
        reactions: [Reaction],
        currentUserId: String,
        selectedEmoji: String? = nil,
        onRemoveReaction: @escaping (Reaction) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.reactions = reactions
        self.currentUserId = currentUserId
        self._selectedEmoji = State(initialValue: selectedEmoji)
        self.onRemoveReaction = onRemoveReaction
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Emoji tabs
                emojiTabBar

                Divider()

                // Reactors list
                reactorsList
            }
            .navigationTitle("Reactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
        .onAppear {
            if selectedEmoji == nil, let first = summaries.first {
                selectedEmoji = first.emoji
            }
        }
    }

    // MARK: - Emoji Tab Bar

    private var emojiTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(summaries) { summary in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedEmoji = summary.emoji
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(summary.emoji)
                                .font(.system(size: 24))

                            Text("\(summary.count)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedEmoji == summary.emoji ? Color.blue.opacity(0.1) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Reactors List

    private var reactorsList: some View {
        let selectedSummary = summaries.first { $0.emoji == selectedEmoji }
        let reactionsToShow = selectedSummary?.reactions ?? []

        return List {
            ForEach(reactionsToShow) { reaction in
                HStack {
                    // Avatar placeholder
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(reaction.reactorDisplayName?.prefix(1) ?? "?"))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.secondary)
                        )

                    // Name
                    VStack(alignment: .leading, spacing: 2) {
                        Text(reaction.reactorDisplayName ?? "Unknown")
                            .font(.body)

                        if reaction.reactorId == currentUserId {
                            Text("You")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Remove button for own reactions
                    if reaction.reactorId == currentUserId {
                        Button(role: .destructive) {
                            onRemoveReaction(reaction)
                        } label: {
                            Text("Remove")
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
struct ReactionDetailsSheet_Previews: PreviewProvider {
    static var previews: some View {
        ReactionDetailsSheet(
            reactions: [
                Reaction(emoji: "👍", reactorId: "user1", reactorDisplayName: "Alice"),
                Reaction(emoji: "👍", reactorId: "me", reactorDisplayName: "Me"),
                Reaction(emoji: "❤️", reactorId: "user2", reactorDisplayName: "Bob"),
                Reaction(emoji: "😂", reactorId: "user3", reactorDisplayName: "Carol"),
                Reaction(emoji: "😂", reactorId: "user1", reactorDisplayName: "Alice")
            ],
            currentUserId: "me",
            onRemoveReaction: { reaction in
                print("Remove: \(reaction.emoji)")
            },
            onDismiss: {
                print("Dismissed")
            }
        )
    }
}
#endif
