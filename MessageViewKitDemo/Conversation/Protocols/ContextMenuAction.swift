//
// ContextMenuAction.swift
// Conversation
//
// Context menu actions for message long-press menu
//

import Foundation

// MARK: - Context Menu Action

/// Available actions in the message context menu
public enum ContextMenuAction: String, CaseIterable, Identifiable {
    case reply
    case forward
    case copy
    case select
    case info
    case delete

    public var id: String { rawValue }

    /// Display title for the action
    public var title: String {
        switch self {
        case .reply: return String(localized: "context_menu.reply")
        case .forward: return String(localized: "context_menu.forward")
        case .copy: return String(localized: "context_menu.copy")
        case .select: return String(localized: "context_menu.select")
        case .info: return String(localized: "context_menu.info")
        case .delete: return String(localized: "context_menu.delete")
        }
    }

    /// SF Symbol name for the action icon
    public var iconName: String {
        switch self {
        case .reply: return "arrowshape.turn.up.left"
        case .forward: return "arrowshape.turn.up.right"
        case .copy: return "doc.on.doc"
        case .select: return "checkmark.circle"
        case .info: return "info.circle"
        case .delete: return "trash"
        }
    }

    /// Whether this action is destructive (shown in red)
    public var isDestructive: Bool {
        switch self {
        case .delete: return true
        default: return false
        }
    }

    /// Get available actions for a message
    /// - Parameter hasText: Whether the message has text content that can be copied
    /// - Returns: Array of available actions
    public static func actions(hasText: Bool) -> [ContextMenuAction] {
        if hasText {
            return allCases
        } else {
            // Hide Copy for image-only messages
            return allCases.filter { $0 != .copy }
        }
    }
}
