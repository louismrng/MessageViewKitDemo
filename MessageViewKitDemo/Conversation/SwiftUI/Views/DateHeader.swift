//
// DateHeader.swift
// Conversation
//
// Date separator view for grouping messages by day
//

import SwiftUI

// MARK: - Date Header View

/// Displays a date separator between message groups.
/// Shows "Today", "Yesterday", or a formatted date.
public struct DateHeader: View {
    // MARK: - Properties

    let date: Date

    // MARK: - Initialization

    public init(date: Date) {
        self.date = date
    }

    // MARK: - Body

    public var body: some View {
        Text(formattedDate)
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)
    }

    // MARK: - Date Formatting

    private var formattedDate: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return String(localized: "conversation.date.today")
        } else if calendar.isDateInYesterday(date) {
            return String(localized: "conversation.date.yesterday")
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DateHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            DateHeader(date: Date())
            DateHeader(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
            DateHeader(date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
