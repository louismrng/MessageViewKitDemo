//
// ConversationContentView.swift
// Conversation
//
// Main conversation view combining message list and input toolbar
//

import SwiftUI

// MARK: - Context Menu State

private struct ContextMenuState {
    let message: AnyMessage
    let sourceFrame: CGRect
}

// MARK: - Conversation View

/// The main SwiftUI conversation view.
/// Combines message list, typing indicator, and input toolbar.
public struct ConversationContentView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: ConversationViewModel
    @Binding var isContextMenuVisible: Bool

    // MARK: - State

    @State private var contextMenuState: ContextMenuState?
    @FocusState private var isInputFocused: Bool

    // MARK: - Initialization

    public init(viewModel: ConversationViewModel, isContextMenuVisible: Binding<Bool> = .constant(false)) {
        self.viewModel = viewModel
        self._isContextMenuVisible = isContextMenuVisible
    }

    // MARK: - Constants

    private let coordinateSpaceName = "conversationView"

    // MARK: - Body

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Message list
                MessageListView(
                    viewModel: viewModel,
                    isInputFocused: $isInputFocused,
                    coordinateSpaceName: coordinateSpaceName,
                    onLongPress: { message, frame in
                        contextMenuState = ContextMenuState(message: message, sourceFrame: frame)
                    }
                )

                // Input toolbar
                InputToolbar(
                    text: $viewModel.draftText,
                    isFocused: $isInputFocused,
                    onSend: {
                        viewModel.sendMessage()
                    },
                    onEditingChanged: { isEditing in
                        viewModel.setTyping(isEditing)
                    }
                )
            }
            .background(Color(UIColor.systemBackground))

            // Context menu overlay
            if let state = contextMenuState {
                ContextMenuOverlay(
                    message: state.message,
                    sourceFrame: state.sourceFrame,
                    currentUserId: viewModel.currentUserId,
                    onReact: { emoji in
                        viewModel.onReact?(emoji, state.message.id)
                    },
                    onAction: { action in
                        handleContextMenuAction(action, for: state.message)
                    },
                    onDismiss: {
                        contextMenuState = nil
                    }
                )
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
        .onChange(of: contextMenuState != nil) { _, isVisible in
            isContextMenuVisible = isVisible
        }
    }

    // MARK: - Context Menu Action Handler

    private func handleContextMenuAction(_ action: ContextMenuAction, for message: AnyMessage) {
        switch action {
        case .reply:
            viewModel.onReply?(message)
        case .forward:
            viewModel.onForward?(message)
        case .copy:
            if let text = message.bodyText {
                UIPasteboard.general.string = text
            }
            viewModel.onCopy?(message)
        case .select:
            viewModel.onSelect?(message)
        case .info:
            viewModel.onInfo?(message)
        case .delete:
            viewModel.onDelete?(message)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ConversationContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = makePreviewViewModel()

        return NavigationView {
            ConversationContentView(viewModel: viewModel)
                .navigationTitle("Alice")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    static func makePreviewViewModel() -> ConversationViewModel {
        let now = Date()
        let viewModel = ConversationViewModel(messages: [
            MockMessage(
                sortId: 1,
                timestamp: now.addingTimeInterval(-7200),
                bodyText: "Hey! Are you coming to the meeting today?",
                isOutgoing: false,
                authorDisplayName: "Alice"
            ),
            MockMessage(
                sortId: 2,
                timestamp: now.addingTimeInterval(-7000),
                bodyText: "Yes, I'll be there in 10 minutes!",
                isOutgoing: true,
                deliveryStatus: .read
            ),
            MockMessage(
                sortId: 3,
                timestamp: now.addingTimeInterval(-3600),
                bodyText: "Great! See you soon!",
                isOutgoing: false,
                authorDisplayName: "Alice"
            ),
            MockMessage(
                sortId: 4,
                timestamp: now.addingTimeInterval(-1800),
                bodyText: "The meeting went well. Thanks for presenting!",
                isOutgoing: false,
                authorDisplayName: "Alice"
            ),
            MockMessage(
                sortId: 5,
                timestamp: now.addingTimeInterval(-1500),
                bodyText: "Thanks! I was a bit nervous but I think it went okay.",
                isOutgoing: true,
                deliveryStatus: .delivered
            )
        ])

        viewModel.onSendMessage = { text in
            let message = MockMessage(
                sortId: UInt64(viewModel.messages.count + 1),
                timestamp: Date(),
                bodyText: text,
                isOutgoing: true,
                deliveryStatus: .sending
            )
            viewModel.appendMessage(message)
        }

        return viewModel
    }
}
#endif
