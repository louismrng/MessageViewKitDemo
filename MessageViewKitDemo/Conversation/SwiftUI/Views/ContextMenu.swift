//
// MessageContextMenu.swift
// Conversation
//
// Context menu with actions for long-pressed messages
//

import SwiftUI

// MARK: - Context Menu

/// A context menu displaying available actions for a message
public struct MessageContextMenu: View {
    // MARK: - Layout Constants

    private enum Layout {
        static let menuWidth: CGFloat = 250
        static let cornerRadius: CGFloat = 30
        static let itemHeight: CGFloat = 44
        static let iconSize: CGFloat = 20
        static let iconFrameWidth: CGFloat = 24
        static let horizontalPadding: CGFloat = 16
        static let itemSpacing: CGFloat = 12

        static let shadowOpacity: Double = 0.2
        static let shadowRadius: CGFloat = 16
        static let shadowYOffset: CGFloat = 8

        static let scaleStart: CGFloat = 0.85
        static let springResponse: Double = 0.28
        static let springDamping: Double = 0.75
    }

    // MARK: - Properties

    let message: AnyMessage
    let onAction: (ContextMenuAction) -> Void

    @State private var appeared = false

    // MARK: - Initialization

    public init(
        message: AnyMessage,
        onAction: @escaping (ContextMenuAction) -> Void
    ) {
        self.message = message
        self.onAction = onAction
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(availableActions) { action in
                MenuItem(action: action) {
                    onAction(action)
                }

                if #unavailable(iOS 26.0), action != availableActions.last {
                    Divider()
                }
            }
        }
        .padding(.vertical, 8)
        .frame(width: Layout.menuWidth)
        .modifier(MenuBackgroundModifier(cornerRadius: Layout.cornerRadius))
        .shadow(color: .black.opacity(Layout.shadowOpacity), radius: Layout.shadowRadius, x: 0, y: Layout.shadowYOffset)
        .scaleEffect(appeared ? 1.0 : Layout.scaleStart)
        .opacity(appeared ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: Layout.springResponse, dampingFraction: Layout.springDamping)) {
                appeared = true
            }
        }
    }

    // MARK: - Available Actions

    private var availableActions: [ContextMenuAction] {
        let hasText = message.bodyText != nil && !message.bodyText!.isEmpty
        return ContextMenuAction.actions(hasText: hasText)
    }
}

// MARK: - Menu Item

private struct MenuItem: View {
    let action: ContextMenuAction
    let onTap: () -> Void

    @State private var isPressed = false

    private enum Layout {
        static let itemHeight: CGFloat = 44
        static let iconSize: CGFloat = 20
        static let iconFrameWidth: CGFloat = 24
        static let horizontalPadding: CGFloat = 30
        static let itemSpacing: CGFloat = 12
        static let pressedOpacity: Double = 0.1
    }

    var body: some View {
        HStack(spacing: Layout.itemSpacing) {
            Image(systemName: action.iconName)
                .font(.system(size: Layout.iconSize))
                .frame(width: Layout.iconFrameWidth)
            Text(action.title)
                .font(.body)
            Spacer()
        }
        .foregroundColor(action.isDestructive ? .red : .primary)
        .padding(.horizontal, Layout.horizontalPadding)
        .frame(height: Layout.itemHeight)
        .background(isPressed ? Color.primary.opacity(Layout.pressedOpacity) : Color.clear)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { value in
                    isPressed = false
                    // Only trigger if finger is still within bounds
                    if abs(value.translation.width) < 50 && abs(value.translation.height) < 50 {
                        onTap()
                    }
                }
        )
    }
}

// MARK: - Menu Background Modifier

private struct MenuBackgroundModifier: ViewModifier {
    let cornerRadius: CGFloat
    let legacyCornerRadius: CGFloat = 12

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(
                    .regular,
                    in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
        } else {
            content
                .background(
                    RoundedRectangle(cornerRadius: legacyCornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .clipShape(RoundedRectangle(cornerRadius: legacyCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: legacyCornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MessageContextMenu_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .ignoresSafeArea()

            MessageContextMenu(
                message: AnyMessage(MockMessage(
                    bodyText: "Hello!",
                    isOutgoing: true
                )),
                onAction: { action in
                    print("Action: \(action.title)")
                }
            )
        }
    }
}
#endif
