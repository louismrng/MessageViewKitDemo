//
// Reaction.swift
// Conversation
//
// Message reaction types for emoji reactions on messages
//

import Foundation

// MARK: - Reaction Protocol

/// Represents a single reaction on a message
public struct Reaction: Identifiable, Equatable, Hashable {
    public let id: String
    public let emoji: String
    public let reactorId: String
    public let reactorDisplayName: String?
    public let timestamp: Date

    public init(
        id: String = UUID().uuidString,
        emoji: String,
        reactorId: String,
        reactorDisplayName: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.emoji = emoji
        self.reactorId = reactorId
        self.reactorDisplayName = reactorDisplayName
        self.timestamp = timestamp
    }
}

// MARK: - Reaction Summary

/// Groups reactions by emoji for badge display
public struct ReactionSummary: Identifiable, Equatable {
    public let emoji: String
    public let count: Int
    public let reactions: [Reaction]
    public let currentUserReacted: Bool

    public var id: String { emoji }

    public init(emoji: String, reactions: [Reaction], currentUserId: String) {
        self.emoji = emoji
        self.count = reactions.count
        self.reactions = reactions
        self.currentUserReacted = reactions.contains { $0.reactorId == currentUserId }
    }

    /// Create summaries from a list of reactions
    public static func summarize(_ reactions: [Reaction], currentUserId: String) -> [ReactionSummary] {
        let grouped = Dictionary(grouping: reactions) { $0.emoji }
        return ReactionEmoji.allCases.compactMap { emoji in
            guard let reactions = grouped[emoji.rawValue], !reactions.isEmpty else { return nil }
            return ReactionSummary(emoji: emoji.rawValue, reactions: reactions, currentUserId: currentUserId)
        }
    }
}

// MARK: - Standard Emoji Palette

/// Standard reaction emoji palette (Signal/iMessage style)
public enum ReactionEmoji: String, CaseIterable, Identifiable {
    case heart = "❤️"
    case thumbsUp = "👍"
    case thumbsDown = "👎"
    case laugh = "😂"
    case surprised = "😮"
    case sad = "😢"

    public var id: String { rawValue }
}
