//
// MockDataProvider.swift
// MessageViewKitDemo
//
// Combined mock data provider for threads () and messages ()
//

import Foundation
import Combine

// MARK: - Mock Data Provider

/// A combined mock data provider that supplies both thread and message data.
/// Demonstrates how to wire data sources to both ChatList and Conversation.
public class MockDataProvider: ObservableObject {

    // MARK: - Published Properties

    @Published public private(set) var threads: [MockThread] = []

    // MARK: - Private Properties

    private var updateTimer: Timer?
    private var typingTimers: [String: Timer] = [:]
    private var messageStore: [String: [MockMessage]] = [:]

    // MARK: - Initialization

    public init() {
        loadInitialData()
    }

    deinit {
        stopSimulation()
    }

    // MARK: - Data Loading

    public func loadInitialData() {
        threads = Self.generateMockThreads()
        messageStore = Self.generateMockMessages(for: threads)
    }

    // MARK: - Thread Operations

    public func archiveThread(id: String) {
        threads.removeAll { $0.uniqueId == id }
        messageStore.removeValue(forKey: id)
    }

    public func deleteThread(id: String) {
        threads.removeAll { $0.uniqueId == id }
        messageStore.removeValue(forKey: id)
    }

    public func toggleMute(threadId: String) {
        guard let index = threads.firstIndex(where: { $0.uniqueId == threadId }) else { return }
        let thread = threads[index]
        threads[index] = MockThread(
            uniqueId: thread.uniqueId,
            displayName: thread.displayName,
            isGroup: thread.isGroup,
            isPinned: thread.isPinned,
            isMuted: !thread.isMuted,
            hasUnreadMessages: thread.hasUnreadMessages,
            unreadCount: thread.unreadCount,
            lastMessageDate: thread.lastMessageDate,
            lastMessageSnippet: thread.lastMessageSnippet,
            lastMessageStatus: thread.lastMessageStatus,
            isTyping: thread.isTyping,
            isBlocked: thread.isBlocked,
            hasPendingMessageRequest: thread.hasPendingMessageRequest,
            isNoteToSelf: thread.isNoteToSelf
        )
    }

    public func toggleRead(threadId: String) {
        guard let index = threads.firstIndex(where: { $0.uniqueId == threadId }) else { return }
        let thread = threads[index]
        let newHasUnread = !thread.hasUnreadMessages
        threads[index] = MockThread(
            uniqueId: thread.uniqueId,
            displayName: thread.displayName,
            isGroup: thread.isGroup,
            isPinned: thread.isPinned,
            isMuted: thread.isMuted,
            hasUnreadMessages: newHasUnread,
            unreadCount: newHasUnread ? 1 : 0,
            lastMessageDate: thread.lastMessageDate,
            lastMessageSnippet: thread.lastMessageSnippet,
            lastMessageStatus: thread.lastMessageStatus,
            isTyping: thread.isTyping,
            isBlocked: thread.isBlocked,
            hasPendingMessageRequest: thread.hasPendingMessageRequest,
            isNoteToSelf: thread.isNoteToSelf
        )
    }

    public func markAsRead(threadId: String) {
        guard let index = threads.firstIndex(where: { $0.uniqueId == threadId }) else { return }
        let thread = threads[index]
        guard thread.hasUnreadMessages else { return }
        threads[index] = MockThread(
            uniqueId: thread.uniqueId,
            displayName: thread.displayName,
            isGroup: thread.isGroup,
            isPinned: thread.isPinned,
            isMuted: thread.isMuted,
            hasUnreadMessages: false,
            unreadCount: 0,
            lastMessageDate: thread.lastMessageDate,
            lastMessageSnippet: thread.lastMessageSnippet,
            lastMessageStatus: thread.lastMessageStatus,
            isTyping: thread.isTyping,
            isBlocked: thread.isBlocked,
            hasPendingMessageRequest: thread.hasPendingMessageRequest,
            isNoteToSelf: thread.isNoteToSelf
        )
    }

    // MARK: - Message Operations

    /// Get messages for a specific thread
    public func messagesForThread(threadId: String) -> [MockMessage] {
        return messageStore[threadId] ?? []
    }

    /// Add a new outgoing message to a thread
    public func addMessage(_ message: MockMessage, toThread threadId: String) {
        if messageStore[threadId] == nil {
            messageStore[threadId] = []
        }
        messageStore[threadId]?.append(message)

        // Update thread's last message
        updateThreadLastMessage(threadId: threadId, text: message.bodyText ?? "Photo", isOutgoing: true)
    }

    /// Update an existing message (e.g., for delivery status changes)
    public func updateMessage(_ message: MockMessage, inThread threadId: String) {
        guard let index = messageStore[threadId]?.firstIndex(where: { $0.uniqueId == message.uniqueId }) else { return }
        messageStore[threadId]?[index] = message
    }

    // MARK: - Reaction Operations

    /// Add a reaction to a message
    public func addReaction(emoji: String, toMessage messageId: String, inThread threadId: String, reactorId: String = "me", reactorDisplayName: String? = "Me") {
        guard let messageIndex = messageStore[threadId]?.firstIndex(where: { $0.uniqueId == messageId }) else { return }
        let message = messageStore[threadId]![messageIndex]

        // Check if user already reacted with this emoji
        if message.reactions.contains(where: { $0.emoji == emoji && $0.reactorId == reactorId }) {
            return
        }

        let reaction = Reaction(
            emoji: emoji,
            reactorId: reactorId,
            reactorDisplayName: reactorDisplayName
        )

        let updatedMessage = MockMessage(
            uniqueId: message.uniqueId,
            sortId: message.sortId,
            timestamp: message.timestamp,
            bodyText: message.bodyText,
            image: message.image,
            isOutgoing: message.isOutgoing,
            deliveryStatus: message.deliveryStatus,
            authorId: message.authorId,
            authorDisplayName: message.authorDisplayName,
            reactions: message.reactions + [reaction]
        )
        messageStore[threadId]?[messageIndex] = updatedMessage
    }

    /// Remove a reaction from a message
    public func removeReaction(_ reaction: Reaction, fromMessage messageId: String, inThread threadId: String) {
        guard let messageIndex = messageStore[threadId]?.firstIndex(where: { $0.uniqueId == messageId }) else { return }
        let message = messageStore[threadId]![messageIndex]

        let updatedReactions = message.reactions.filter { $0.id != reaction.id }

        let updatedMessage = MockMessage(
            uniqueId: message.uniqueId,
            sortId: message.sortId,
            timestamp: message.timestamp,
            bodyText: message.bodyText,
            image: message.image,
            isOutgoing: message.isOutgoing,
            deliveryStatus: message.deliveryStatus,
            authorId: message.authorId,
            authorDisplayName: message.authorDisplayName,
            reactions: updatedReactions
        )
        messageStore[threadId]?[messageIndex] = updatedMessage
    }

    private func updateThreadLastMessage(threadId: String, text: String, isOutgoing: Bool) {
        guard let index = threads.firstIndex(where: { $0.uniqueId == threadId }) else { return }
        let thread = threads[index]

        let snippet: Snippet = .message(text: text)
        let status: MessageStatus? = isOutgoing ? .sent : nil

        threads[index] = MockThread(
            uniqueId: thread.uniqueId,
            displayName: thread.displayName,
            isGroup: thread.isGroup,
            isPinned: thread.isPinned,
            isMuted: thread.isMuted,
            hasUnreadMessages: thread.hasUnreadMessages,
            unreadCount: thread.unreadCount,
            lastMessageDate: Date(),
            lastMessageSnippet: snippet,
            lastMessageStatus: status,
            isTyping: thread.isTyping,
            isBlocked: thread.isBlocked,
            hasPendingMessageRequest: thread.hasPendingMessageRequest,
            isNoteToSelf: thread.isNoteToSelf
        )
    }

    // MARK: - Simulation

    /// Start simulating real-time updates (new messages, typing indicators)
    public func startSimulation() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 8...15), repeats: true) { [weak self] _ in
            self?.simulateIncomingMessage()
        }
        simulateTypingIndicators()
    }

    /// Stop the simulation
    public func stopSimulation() {
        updateTimer?.invalidate()
        updateTimer = nil
        typingTimers.values.forEach { $0.invalidate() }
        typingTimers.removeAll()
    }

    private func simulateIncomingMessage() {
        guard !threads.isEmpty else { return }

        let randomIndex = Int.random(in: 0..<threads.count)
        let thread = threads[randomIndex]

        guard !thread.isNoteToSelf else { return }

        let newSnippets: [Snippet] = [
            .message(text: "Hey, what's up?"),
            .message(text: "Did you see that?"),
            .message(text: "Can you call me?"),
            .message(text: "Thanks!"),
            .message(text: "See you later!"),
            .message(text: "Sounds good!"),
        ]

        let newSnippet = thread.isGroup
            ? Snippet.groupMessage(text: newSnippets.randomElement()!.text, senderName: ["Alice", "Bob", "Carol"].randomElement()!)
            : newSnippets.randomElement()!

        threads[randomIndex] = MockThread(
            uniqueId: thread.uniqueId,
            displayName: thread.displayName,
            isGroup: thread.isGroup,
            isPinned: thread.isPinned,
            isMuted: thread.isMuted,
            hasUnreadMessages: true,
            unreadCount: thread.unreadCount + 1,
            lastMessageDate: Date(),
            lastMessageSnippet: newSnippet,
            lastMessageStatus: nil,
            isTyping: false,
            isBlocked: thread.isBlocked,
            hasPendingMessageRequest: thread.hasPendingMessageRequest,
            isNoteToSelf: thread.isNoteToSelf
        )

        // Also add to message store
        let messageText = newSnippet.text
        let newMessage = MockMessage(
            sortId: UInt64(Date().timeIntervalSince1970 * 1000),
            timestamp: Date(),
            bodyText: messageText,
            isOutgoing: false,
            authorId: thread.uniqueId,
            authorDisplayName: thread.displayName
        )
        messageStore[thread.uniqueId]?.append(newMessage)
    }

    private func simulateTypingIndicators() {
        guard threads.count > 2 else { return }

        let eligibleThreads = threads.filter { !$0.isNoteToSelf && !$0.isTyping }
        guard let thread = eligibleThreads.randomElement(),
              let index = threads.firstIndex(where: { $0.uniqueId == thread.uniqueId }) else { return }

        threads[index] = MockThread(
            uniqueId: thread.uniqueId,
            displayName: thread.displayName,
            isGroup: thread.isGroup,
            isPinned: thread.isPinned,
            isMuted: thread.isMuted,
            hasUnreadMessages: thread.hasUnreadMessages,
            unreadCount: thread.unreadCount,
            lastMessageDate: thread.lastMessageDate,
            lastMessageSnippet: thread.lastMessageSnippet,
            lastMessageStatus: thread.lastMessageStatus,
            isTyping: true,
            isBlocked: thread.isBlocked,
            hasPendingMessageRequest: thread.hasPendingMessageRequest,
            isNoteToSelf: thread.isNoteToSelf
        )

        let timer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 2...4), repeats: false) { [weak self] _ in
            self?.stopTyping(threadId: thread.uniqueId)

            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 5...12)) {
                self?.simulateTypingIndicators()
            }
        }
        typingTimers[thread.uniqueId] = timer
    }

    private func stopTyping(threadId: String) {
        guard let index = threads.firstIndex(where: { $0.uniqueId == threadId }) else { return }
        let thread = threads[index]
        threads[index] = MockThread(
            uniqueId: thread.uniqueId,
            displayName: thread.displayName,
            isGroup: thread.isGroup,
            isPinned: thread.isPinned,
            isMuted: thread.isMuted,
            hasUnreadMessages: thread.hasUnreadMessages,
            unreadCount: thread.unreadCount,
            lastMessageDate: thread.lastMessageDate,
            lastMessageSnippet: thread.lastMessageSnippet,
            lastMessageStatus: thread.lastMessageStatus,
            isTyping: false,
            isBlocked: thread.isBlocked,
            hasPendingMessageRequest: thread.hasPendingMessageRequest,
            isNoteToSelf: thread.isNoteToSelf
        )
        typingTimers.removeValue(forKey: threadId)
    }

    // MARK: - Mock Data Generation

    private static func generateMockThreads() -> [MockThread] {
        let contacts = [
            ("Alice Johnson", false),
            ("Bob Smith", false),
            ("Carol Williams", false),
            ("David Brown", false),
            ("Eve Davis", false),
            ("Frank Miller", false),
            ("Jack Black", false),
            ("Joe Smith", false),
            ("Karen White", false),
            ("Lisa Johnson", false),
        ]

        let groups = [
            ("Family Chat", true),
            ("Work Team", true),
            ("Book Club", true),
        ]

        let snippets: [Snippet] = [
            .message(text: "Hey! How are you doing today?"),
            .message(text: "Did you see the game last night?"),
            .message(text: "Can you send me that file?"),
            .message(text: "Thanks for your help!"),
            .message(text: "Let's meet up soon"),
        ]

        let groupSnippets: [(String, String)] = [
            ("Meeting tomorrow at 3pm", "Bob"),
            ("Who's bringing the snacks?", "Carol"),
            ("Great job everyone!", "Alice"),
        ]

        var threads: [MockThread] = []

        // Contacts
        for i in 0..<contacts.count {
            let (name, _) = contacts[i]
            threads.append(MockThread(
                displayName: name,
                hasUnreadMessages: i % 3 == 0,
                unreadCount: i % 3 == 0 ? UInt.random(in: 1...10) : 0,
                lastMessageDate: Date().addingTimeInterval(Double(-i * 3600)),
                lastMessageSnippet: snippets[i % snippets.count],
                lastMessageStatus: [.sent, .delivered, .read].randomElement()
            ))
        }

        // Groups
        for (i, (name, _)) in groups.enumerated() {
            let (text, sender) = groupSnippets[i % groupSnippets.count]
            threads.append(MockThread(
                displayName: name,
                isGroup: true,
                isMuted: i == 1,
                hasUnreadMessages: i == 0,
                unreadCount: i == 0 ? 3 : 0,
                lastMessageDate: Date().addingTimeInterval(Double(-(i + 6) * 3600)),
                lastMessageSnippet: .groupMessage(text: text, senderName: sender)
            ))
        }

        // Note to Self
        threads.append(MockThread(
            displayName: "Note to Self",
            lastMessageDate: Date().addingTimeInterval(-86400),
            lastMessageSnippet: .draft(text: "Shopping list: milk, eggs, bread"),
            isNoteToSelf: true
        ))

        return threads
    }

    private static func generateMockMessages(for threads: [MockThread]) -> [String: [MockMessage]] {
        var store: [String: [MockMessage]] = [:]
        let now = Date()
        let calendar = Calendar.current

        for thread in threads {
            var messages: [MockMessage] = []

            // Generate 5-10 messages per thread
            let messageCount = Int.random(in: 5...10)
            for i in 0..<messageCount {
                let isOutgoing = Bool.random()
                let timeOffset = -(messageCount - i) * 600 // 10 min apart
                let timestamp = calendar.date(byAdding: .second, value: timeOffset, to: now)!

                let sampleTexts = [
                    "Hey, how are you?",
                    "I'm good, thanks for asking!",
                    "Did you see the news today?",
                    "Yes, it's pretty interesting.",
                    "Let's catch up soon!",
                    "Sounds great!",
                    "What time works for you?",
                    "How about 3pm?",
                    "Perfect, see you then!",
                    "Great, looking forward to it!"
                ]

                // Add sample reactions to some messages
                var reactions: [Reaction] = []
                if i == 2 || i == 5 {
                    // Add reactions from other users
                    reactions.append(Reaction(emoji: "👍", reactorId: "user1", reactorDisplayName: "Alice"))
                    if i == 5 {
                        reactions.append(Reaction(emoji: "❤️", reactorId: "user2", reactorDisplayName: "Bob"))
                        reactions.append(Reaction(emoji: "😂", reactorId: "user3", reactorDisplayName: "Carol"))
                    }
                }
                if i == 3 {
                    // Add a reaction from the current user
                    reactions.append(Reaction(emoji: "❤️", reactorId: "me", reactorDisplayName: "Me"))
                }

                let message = MockMessage(
                    sortId: UInt64(i + 1),
                    timestamp: timestamp,
                    bodyText: sampleTexts[i % sampleTexts.count],
                    isOutgoing: isOutgoing,
                    deliveryStatus: isOutgoing ? [.sent, .delivered, .read].randomElement()! : .sent,
                    authorId: isOutgoing ? "me" : thread.uniqueId,
                    authorDisplayName: isOutgoing ? "Me" : thread.displayName,
                    reactions: reactions
                )
                messages.append(message)
            }

            store[thread.uniqueId] = messages
        }

        return store
    }
}

// MARK: - Helper Extension

private extension Snippet {
    var text: String {
        switch self {
        case .message(let text): return text
        case .groupMessage(let text, _): return text
        case .draft(let text): return text
        default: return ""
        }
    }
}
