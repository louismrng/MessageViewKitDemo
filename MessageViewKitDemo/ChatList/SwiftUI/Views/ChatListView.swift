//
// ChatListView.swift
// ChatList
//
// Main SwiftUI container view for the chat list
//

import SwiftUI

// MARK: - Chat List View

/// The main chat list container view.
/// Displays a scrollable list of threads with pinned and unpinned sections.
public struct ChatListView: View {
    @Environment(\.chatListStyle) private var style

    @ObservedObject var viewModel: ChatListViewModel

    public init(viewModel: ChatListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            style.backgroundColor.ignoresSafeArea()

            if viewModel.isEmpty {
                EmptyInboxView(
                    isFiltered: viewModel.isEmptyDueToFilter,
                    onClearFilter: viewModel.isEmptyDueToFilter ? {
                        viewModel.setFilterMode(.none)
                        viewModel.searchText = ""
                    } : nil
                )
            } else {
                threadList
            }
        }
    }

    // MARK: - Thread List

    private var threadList: some View {
        List(viewModel.filteredThreads) { thread in
            NavigationLink(value: thread.id) {
                ThreadRowContent(thread: thread)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    viewModel.onDeleteThread?(thread.id)
                } label: {
                    Label("", systemImage: "trash")
                }

                Button {
                    viewModel.onArchiveThread?(thread.id)
                } label: {
                    Label("", systemImage: "archivebox")
                }
                .tint(.purple)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    viewModel.onToggleReadThread?(thread.id)
                } label: {
                    if thread.hasUnreadMessages {
                        Label("", systemImage: "envelope.open")
                    } else {
                        Label("", systemImage: "envelope.badge")
                    }
                }
                .tint(.blue)
            }
            .contextMenu {
                contextMenuContent(for: thread)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func contextMenuContent(for thread: AnyThread) -> some View {
        Button {
            viewModel.onToggleMuteThread?(thread.id)
        } label: {
            if thread.isMuted {
                Label("chat_list.action.unmute", systemImage: "bell")
            } else {
                Label("chat_list.action.mute", systemImage: "bell.slash")
            }
        }

        Button {
            viewModel.onToggleReadThread?(thread.id)
        } label: {
            if thread.hasUnreadMessages {
                Label("chat_list.action.mark_as_read", systemImage: "envelope.open")
            } else {
                Label("chat_list.action.mark_as_unread", systemImage: "envelope.badge")
            }
        }

        Button {
            viewModel.onArchiveThread?(thread.id)
        } label: {
            Label("chat_list.action.archive", systemImage: "archivebox")
        }

        Button(role: .destructive) {
            viewModel.onDeleteThread?(thread.id)
        } label: {
            Label("chat_list.action.delete", systemImage: "trash")
        }
    }

}

// MARK: - Preview

#Preview("Chat List") {
    let viewModel = ChatListViewModel()

    let mockThreads: [MockThread] = [
        MockThread(
            displayName: "Alice",
            isPinned: false,
            hasUnreadMessages: true,
            unreadCount: 2,
            lastMessageDate: Date(),
            lastMessageSnippet: .message(text: "Hey! How are you?")
        ),
        MockThread(
            displayName: "Work Group",
            isGroup: true,
            isPinned: false,
            isMuted: true,
            lastMessageDate: Date().addingTimeInterval(-1800),
            lastMessageSnippet: .groupMessage(text: "Meeting at 3pm", senderName: "Bob"),
            lastMessageStatus: .delivered
        ),
        MockThread(
            displayName: "Bob",
            lastMessageDate: Date().addingTimeInterval(-3600),
            lastMessageSnippet: .message(text: "See you tomorrow!"),
            lastMessageStatus: .read
        ),
        MockThread(
            displayName: "Charlie",
            hasUnreadMessages: true,
            unreadCount: 5,
            lastMessageDate: Date().addingTimeInterval(-7200),
            lastMessageSnippet: .message(text: "Check out this link")
        ),
        MockThread(
            displayName: "Note to Self",
            lastMessageDate: Date().addingTimeInterval(-86400),
            lastMessageSnippet: .draft(text: "Shopping list: milk, eggs, bread"),
            isNoteToSelf: true
        )
    ]

    viewModel.setThreads(mockThreads)

    return NavigationStack {
        ChatListView(viewModel: viewModel)
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: .init(get: { viewModel.searchText }, set: { viewModel.searchText = $0 }))
    }
    .chatListStyle(.default)
}

#Preview("Empty State") {
    let viewModel = ChatListViewModel()

    ChatListView(viewModel: viewModel)
        .chatListStyle(.default)
}

#Preview("Arabic RTL") {
    let viewModel = ChatListViewModel()

    let mockThreads: [MockThread] = [
        MockThread(
            displayName: "Alice",
            isPinned: false,
            hasUnreadMessages: true,
            unreadCount: 2,
            lastMessageDate: Date(),
            lastMessageSnippet: .message(text: "Hey! How are you?")
        ),
        MockThread(
            displayName: "Work Group",
            isGroup: true,
            isPinned: false,
            isMuted: true,
            lastMessageDate: Date().addingTimeInterval(-1800),
            lastMessageSnippet: .groupMessage(text: "Meeting at 3pm", senderName: "Bob"),
            lastMessageStatus: .delivered
        ),
        MockThread(
            displayName: "Bob",
            lastMessageDate: Date().addingTimeInterval(-3600),
            lastMessageSnippet: .message(text: "See you tomorrow!"),
            lastMessageStatus: .read
        ),
    ]

    viewModel.setThreads(mockThreads)

    return NavigationStack {
        ChatListView(viewModel: viewModel)
            .navigationTitle("chat_list.title")
            .navigationBarTitleDisplayMode(.large)
    }
    .chatListStyle(.default)
    .arabicPreview()
}
