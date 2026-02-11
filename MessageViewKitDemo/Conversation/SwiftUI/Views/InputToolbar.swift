//
// InputToolbar.swift
// Conversation
//
// Text input toolbar with send button for SwiftUI
//

import SwiftUI

// MARK: - Input Toolbar View

/// A text input toolbar for composing and sending messages.
public struct InputToolbar: View {
    // MARK: - Bindings

    @Binding var text: String
    @FocusState.Binding var isFocused: Bool

    // MARK: - Callbacks

    let onSend: () -> Void
    var onEditingChanged: ((Bool) -> Void)?

    // MARK: - Initialization

    public init(
        text: Binding<String>,
        isFocused: FocusState<Bool>.Binding,
        onSend: @escaping () -> Void,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self._text = text
        self._isFocused = isFocused
        self.onSend = onSend
        self.onEditingChanged = onEditingChanged
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(alignment: .bottom, spacing: 8) {
                // Text field
                textField

                // Send button
                sendButton
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemBackground))
        }
        .onChange(of: isFocused) { _, newValue in
            onEditingChanged?(newValue)
        }
    }

    // MARK: - Subviews

    private var textField: some View {
        TextField("Message", text: $text, axis: .vertical)
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .focused($isFocused)
            .lineLimit(1...6)
    }

    private var sendButton: some View {
        Button(action: {
            guard canSend else { return }
            onSend()
        }) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(canSend ? .blue : .gray.opacity(0.5))
        }
        .disabled(!canSend)
    }

    // MARK: - Helpers

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Preview

#if DEBUG
struct InputToolbar_Previews: PreviewProvider {
    struct PreviewContainer: View {
        @State private var text = ""
        @FocusState private var isFocused: Bool

        var body: some View {
            VStack {
                Spacer()
                InputToolbar(text: $text, isFocused: $isFocused) {
                    print("Send: \(text)")
                    text = ""
                }
            }
        }
    }

    static var previews: some View {
        Group {
            PreviewContainer()
                .previewDisplayName("Empty")

            PreviewContainer()
                .onAppear {
                    // Note: Can't set state in preview, but shows layout
                }
                .previewDisplayName("With Text")
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
