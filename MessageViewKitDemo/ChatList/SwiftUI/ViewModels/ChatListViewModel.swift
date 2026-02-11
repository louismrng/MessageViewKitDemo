//
// ChatListViewModel.swift
// ChatList
//
// ObservableObject for managing chat list state in SwiftUI
//

import SwiftUI
import Combine

// MARK: - Chat List ViewModel

/// Main view model for managing chat list state in SwiftUI.
/// Use this with ChatListView to display the chat list interface.
@MainActor
public final class ChatListViewModel: ObservableObject {

    // MARK: - Published Properties

    /// All threads to display
    @Published public private(set) var threads: [AnyThread] = []

    /// Current filter mode
    @Published public private(set) var filterMode: FilterMode = .none

    /// Set of selected thread IDs (for multi-select mode)
    @Published public private(set) var selectedThreadIds: Set<String> = []

    /// Whether the view is in multi-select mode
    @Published public private(set) var isInMultiSelectMode: Bool = false

    /// Search text for filtering threads
    @Published public var searchText: String = ""

    /// Whether there are archived threads to show
    @Published public private(set) var hasArchivedThreads: Bool = false

    // MARK: - Callbacks

    /// Called when a thread is selected (tapped)
    public var onThreadSelected: ((String) -> Void)?

    /// Called when the archive button is pressed
    public var onArchivePressed: (() -> Void)?

    /// Called when a thread should be archived via swipe
    public var onArchiveThread: ((String) -> Void)?

    /// Called when a thread should be deleted via swipe
    public var onDeleteThread: ((String) -> Void)?

    /// Called when a thread should be muted/unmuted via swipe
    public var onToggleMuteThread: ((String) -> Void)?

    /// Called when a thread should be marked read/unread via swipe
    public var onToggleReadThread: ((String) -> Void)?

    // MARK: - Initialization

    public init(threads: [AnyThread] = []) {
        self.threads = threads
    }

    /// Initialize with threads conforming to Thread
    public convenience init<T: Thread>(threads: [T]) {
        self.init(threads: threads.map { AnyThread($0) })
    }

    // MARK: - Thread Management

    /// Set all threads (sorted by last message date)
    public func setThreads(_ newThreads: [AnyThread]) {
        withAnimation {
            threads = newThreads.sorted { (lhs, rhs) in
                // Sort by last message date, newest first
                guard let lhsDate = lhs.lastMessageDate else { return false }
                guard let rhsDate = rhs.lastMessageDate else { return true }
                return lhsDate > rhsDate
            }
        }
    }

    /// Set threads from Thread array
    public func setThreads<T: Thread>(_ newThreads: [T]) {
        setThreads(newThreads.map { AnyThread($0) })
    }

    /// Update a single thread
    public func updateThread(_ thread: AnyThread) {
        if let index = threads.firstIndex(where: { $0.id == thread.id }) {
            threads[index] = thread
        } else {
            threads.append(thread)
        }
        // Re-sort after update
        threads.sort { (lhs, rhs) in
            guard let lhsDate = lhs.lastMessageDate else { return false }
            guard let rhsDate = rhs.lastMessageDate else { return true }
            return lhsDate > rhsDate
        }
    }

    /// Update a thread from Thread
    public func updateThread<T: Thread>(_ thread: T) {
        updateThread(AnyThread(thread))
    }

    /// Remove a thread by ID
    public func removeThread(id: String) {
        threads.removeAll { $0.id == id }
        selectedThreadIds.remove(id)
    }

    // MARK: - Filter Mode

    /// Set the filter mode
    public func setFilterMode(_ mode: FilterMode) {
        filterMode = mode
    }

    /// Toggle unread filter
    public func toggleUnreadFilter() {
        filterMode = filterMode == .unread ? .none : .unread
    }

    // MARK: - Computed Properties

    /// All threads (alias for compatibility)
    public var allThreads: [AnyThread] {
        threads
    }

    /// Filtered threads based on current filter mode and search text
    public var filteredThreads: [AnyThread] {
        filterThreads(threads)
    }

    /// Total number of visible threads
    public var visibleThreadCount: Int {
        filteredThreads.count
    }

    /// Whether the list is empty
    public var isEmpty: Bool {
        visibleThreadCount == 0
    }

    /// Whether the empty state is due to filtering
    public var isEmptyDueToFilter: Bool {
        isEmpty && (filterMode != .none || !searchText.isEmpty) && !threads.isEmpty
    }

    // MARK: - Selection

    /// Select a thread
    public func selectThread(id: String) {
        if isInMultiSelectMode {
            if selectedThreadIds.contains(id) {
                selectedThreadIds.remove(id)
            } else {
                selectedThreadIds.insert(id)
            }
        } else {
            onThreadSelected?(id)
        }
    }

    /// Enter multi-select mode
    public func enterMultiSelectMode() {
        isInMultiSelectMode = true
        selectedThreadIds.removeAll()
    }

    /// Exit multi-select mode
    public func exitMultiSelectMode() {
        isInMultiSelectMode = false
        selectedThreadIds.removeAll()
    }

    /// Select all visible threads
    public func selectAll() {
        let allIds = filteredThreads.map { $0.id }
        selectedThreadIds = Set(allIds)
    }

    /// Deselect all threads
    public func deselectAll() {
        selectedThreadIds.removeAll()
    }

    // MARK: - Private Helpers

    private func filterThreads(_ threads: [AnyThread]) -> [AnyThread] {
        var result = threads

        // Apply filter mode
        if filterMode == .unread {
            result = result.filter { $0.hasUnreadMessages }
        }

        // Apply search filter
        if !searchText.isEmpty {
            let lowercasedSearch = searchText.lowercased()
            result = result.filter { thread in
                thread.displayName.lowercased().contains(lowercasedSearch)
            }
        }

        return result
    }
}

// MARK: - Archive Support

public extension ChatListViewModel {
    /// Set whether there are archived threads
    func setHasArchivedThreads(_ hasArchived: Bool) {
        hasArchivedThreads = hasArchived
    }

    /// Handle archive button press
    func archivePressed() {
        onArchivePressed?()
    }
}
