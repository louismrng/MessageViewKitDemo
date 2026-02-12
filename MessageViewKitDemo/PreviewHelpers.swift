//
// PreviewHelpers.swift
// MessageViewKitDemo
//
// Utilities for previewing localized and RTL layouts
//

import SwiftUI

// MARK: - RTL Preview Modifier

/// A view modifier that configures the environment for Arabic RTL previews.
///
/// Usage in previews:
/// ```
/// #Preview("Arabic RTL") {
///     MyView()
///         .modifier(ArabicPreviewModifier())
/// }
/// ```
///
/// Or for testing in scheme options:
///   Xcode → Product → Scheme → Edit Scheme → Run → Options:
///   - App Language: Arabic
///   - App Region: Saudi Arabia
///   These settings override the simulator/device locale for that run.
struct ArabicPreviewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environment(\.locale, Locale(identifier: "ar"))
            .environment(\.layoutDirection, .rightToLeft)
    }
}

extension View {
    /// Convenience method to apply Arabic RTL environment for previews.
    func arabicPreview() -> some View {
        modifier(ArabicPreviewModifier())
    }
}
