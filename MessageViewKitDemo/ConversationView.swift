//
// ConversationView.swift
// MessageViewKitDemo
//
// Pure SwiftUI conversation view wrapping ConversationContentView
//

import SwiftUI

/// Pure SwiftUI conversation view that wraps the  conversation UI.
struct ConversationView: View {
    let threadId: String
    let threadName: String
    let dataProvider: MockDataProvider

    @StateObject private var viewModel: ConversationViewModel
    @State private var showingInfo = false
    @State private var isContextMenuVisible = false

    init(threadId: String, threadName: String, dataProvider: MockDataProvider) {
        self.threadId = threadId
        self.threadName = threadName
        self.dataProvider = dataProvider

        let messages = dataProvider.messagesForThread(threadId: threadId)
        _viewModel = StateObject(wrappedValue: ConversationViewModel(messages: messages))
    }

    var body: some View {
        ConversationContentView(viewModel: viewModel, isContextMenuVisible: $isContextMenuVisible)
            .conversationStyle(.default)
            .navigationTitle(threadName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .alert("Thread Info", isPresented: $showingInfo) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Thread ID: \(threadId)\nName: \(threadName)\nMessages: \(viewModel.messages.count)")
            }
            .modifier(PreiOS26TabBarHiddenModifier())
            .onAppear {
                setupSendHandler()
            }
    }

    // MARK: - Setup

    private func setupSendHandler() {
        viewModel.onSendMessage = { [weak dataProvider] text in
            guard let dataProvider = dataProvider else { return }

            // Create a sending message
            let messageId = UUID().uuidString
            let message = MockMessage(
                uniqueId: messageId,
                sortId: UInt64(Date().timeIntervalSince1970 * 1000),
                timestamp: Date(),
                bodyText: text,
                isOutgoing: true,
                deliveryStatus: .sending
            )

            // Add to view model
            viewModel.appendMessage(message)

            // Add to data provider
            dataProvider.addMessage(message, toThread: threadId)

            // Simulate delivery after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let deliveredMessage = MockMessage(
                    uniqueId: messageId,
                    sortId: message.sortId,
                    timestamp: message.timestamp,
                    bodyText: text,
                    isOutgoing: true,
                    deliveryStatus: .delivered
                )
                viewModel.updateMessage(deliveredMessage)
                dataProvider.updateMessage(deliveredMessage, inThread: threadId)
            }

            // Simulate read after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                let readMessage = MockMessage(
                    uniqueId: messageId,
                    sortId: message.sortId,
                    timestamp: message.timestamp,
                    bodyText: text,
                    isOutgoing: true,
                    deliveryStatus: .read
                )
                viewModel.updateMessage(readMessage)
                dataProvider.updateMessage(readMessage, inThread: threadId)
            }
        }

        viewModel.onTypingStateChanged = { isTyping in
            print("User \(isTyping ? "started" : "stopped") typing in thread: \(threadId)")
        }

        // Reaction handlers
        viewModel.onReact = { [weak dataProvider, weak viewModel] emoji, messageId in
            guard let dataProvider = dataProvider, let viewModel = viewModel else {
                print("DEBUG: onReact - dataProvider or viewModel is nil")
                return
            }

            print("DEBUG: onReact called with emoji=\(emoji) messageId=\(messageId)")

            // Add reaction to data provider
            dataProvider.addReaction(emoji: emoji, toMessage: messageId, inThread: threadId)

            // Refresh view model with updated messages
            let updatedMessages = dataProvider.messagesForThread(threadId: threadId)
            print("DEBUG: Got \(updatedMessages.count) messages, reactions on target: \(updatedMessages.first { $0.uniqueId == messageId }?.reactions.count ?? -1)")
            viewModel.setMessages(updatedMessages)
            print("DEBUG: Called setMessages, viewModel.messages.count = \(viewModel.messages.count)")
        }

        viewModel.onRemoveReaction = { [weak dataProvider, weak viewModel] reaction, messageId in
            guard let dataProvider = dataProvider, let viewModel = viewModel else { return }

            // Remove reaction from data provider
            dataProvider.removeReaction(reaction, fromMessage: messageId, inThread: threadId)

            // Refresh view model with updated messages
            let updatedMessages = dataProvider.messagesForThread(threadId: threadId)
            viewModel.setMessages(updatedMessages)
        }
    }
}

private struct PreiOS26TabBarHiddenModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
        } else {
            content.toolbar(.hidden, for: .tabBar)
        }
    }
}

#Preview {
    NavigationStack {
        ConversationView(
            threadId: "preview",
            threadName: "Alice",
            dataProvider: MockDataProvider()
        )
    }
}
