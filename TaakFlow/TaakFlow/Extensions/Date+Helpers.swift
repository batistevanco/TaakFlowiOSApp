// Date+Helpers.swift
// TaakFlow — Vancoillie Studio

import Foundation

extension Date {

    // MARK: - Day checks
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var isPast: Bool {
        self < Date()
    }

    var isOverdue: Bool {
        self < Calendar.current.startOfDay(for: Date()) && !isToday
    }

    // MARK: - Formatted strings
    var dayAndMonthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "nl_BE")
        return formatter.string(from: self)
    }

    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "nl_BE")
        return formatter.string(from: self).capitalized
    }

    var shortWeekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "nl_BE")
        return formatter.string(from: self).capitalized
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    var fullDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        formatter.locale = Locale(identifier: "nl_BE")
        return formatter.string(from: self).capitalized
    }

    // MARK: - Week helpers
    var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        components.weekday = 2 // Monday
        return calendar.date(from: components) ?? self
    }

    var daysInCurrentWeek: [Date] {
        let start = startOfWeek
        return (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: start)
        }
    }

    // MARK: - Relative
    func daysUntil() -> Int {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.startOfDay(for: self)
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }

    // MARK: - Constructors
    static func today(hour: Int, minute: Int = 0) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
}
