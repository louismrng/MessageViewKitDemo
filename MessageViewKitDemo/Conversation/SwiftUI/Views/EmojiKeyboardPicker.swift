//
// EmojiKeyboardPicker.swift
// Conversation
//
// UIViewRepresentable wrapper to show system emoji keyboard
//

import SwiftUI
import UIKit

// MARK: - Emoji Keyboard Picker

/// A wrapper that presents the system emoji keyboard for selecting any emoji
public struct EmojiKeyboardPicker: UIViewRepresentable {
    // MARK: - Properties

    let onSelectEmoji: (String) -> Void
    let onDismiss: () -> Void

    // MARK: - Initialization

    public init(
        onSelectEmoji: @escaping (String) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.onSelectEmoji = onSelectEmoji
        self.onDismiss = onDismiss
    }

    // MARK: - UIViewRepresentable

    public func makeUIView(context: Context) -> EmojiTextField {
        let textField = EmojiTextField()
        textField.delegate = context.coordinator
        textField.onSelectEmoji = onSelectEmoji
        textField.onDismiss = onDismiss
        return textField
    }

    public func updateUIView(_ uiView: EmojiTextField, context: Context) {
        // No updates needed
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(onSelectEmoji: onSelectEmoji, onDismiss: onDismiss)
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject, UITextFieldDelegate {
        let onSelectEmoji: (String) -> Void
        let onDismiss: () -> Void

        init(
            onSelectEmoji: @escaping (String) -> Void,
            onDismiss: @escaping () -> Void
        ) {
            self.onSelectEmoji = onSelectEmoji
            self.onDismiss = onDismiss
        }

        public func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            // Check if the replacement string contains an emoji
            if !string.isEmpty && string.unicodeScalars.allSatisfy({ $0.properties.isEmoji }) {
                onSelectEmoji(string)
                textField.resignFirstResponder()
                return false
            }
            return false
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            onDismiss()
        }
    }
}

// MARK: - Emoji TextField

/// A hidden text field that forces emoji keyboard
public class EmojiTextField: UITextField {
    var onSelectEmoji: ((String) -> Void)?
    var onDismiss: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // Make the text field invisible but functional
        alpha = 0.01
        backgroundColor = .clear
        tintColor = .clear
        textColor = .clear
    }

    override public var textInputMode: UITextInputMode? {
        // Force emoji keyboard
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return super.textInputMode
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            // Become first responder when added to view
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.becomeFirstResponder()
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct EmojiKeyboardPicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Emoji Picker will appear")
            EmojiKeyboardPicker(
                onSelectEmoji: { emoji in
                    print("Selected emoji: \(emoji)")
                },
                onDismiss: {
                    print("Dismissed")
                }
            )
            .frame(width: 0, height: 0)
        }
    }
}
#endif
