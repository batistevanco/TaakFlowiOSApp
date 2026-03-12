// StatsViewModel.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import Observation

@Observable
class StatsViewModel {

    // MARK: - Weekly data
    struct DayStats: Identifiable {
        let id = UUID()
        let date: Date
        let completed: Int
        let isToday: Bool
    }

    func weeklyStats(tasks: [TFTask]) -> [DayStats] {
        let calendar = Calendar.current
        let today = Date()

        return (0..<7).map { offset -> DayStats in
            guard let day = calendar.date(byAdding: .day, value: -6 + offset, to: today) else {
                return DayStats(date: today, completed: 0, isToday: false)
            }
            let count = tasks.filter { task in
                guard let completedAt = task.completedAt else { return false }
                return calendar.isDate(completedAt, inSameDayAs: day)
            }.count
            return DayStats(
                date: day,
                completed: count,
                isToday: calendar.isDateInToday(day)
            )
        }
    }

    // MARK: - Summary stats
    func totalCompletedThisWeek(tasks: [TFTask]) -> Int {
        let calendar = Calendar.current
        let startOfWeek = Date().startOfWeek
        return tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            return completedAt >= startOfWeek
        }.count
    }

    func focusTimeThisWeek(tasks: [TFTask]) -> Int {
        let calendar = Calendar.current
        let startOfWeek = Date().startOfWeek
        return tasks
            .filter { task in
                guard let completedAt = task.completedAt else { return false }
                return completedAt >= startOfWeek
            }
            .compactMap { $0.actualMinutes }
            .reduce(0, +)
    }

    // MARK: - 30-day streak calendar
    struct CalendarDay: Identifiable {
        let id = UUID()
        let date: Date
        let hasCompletedTask: Bool
        let isToday: Bool
    }

    func last30Days(tasks: [TFTask]) -> [CalendarDay] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<30).reversed().compactMap { offset -> CalendarDay? in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let hasTask = tasks.contains { task in
                guard let completedAt = task.completedAt else { return false }
                return calendar.isDate(completedAt, inSameDayAs: day)
            }
            return CalendarDay(
                date: day,
                hasCompletedTask: hasTask,
                isToday: calendar.isDateInToday(day)
            )
        }
    }

    // MARK: - Insights
    func generateInsights(tasks: [TFTask]) -> [String] {
        var insights: [String] = []

        // Most productive day
        let calendar = Calendar.current
        var dayCounts = [Int: Int]()
        for task in tasks {
            guard let completedAt = task.completedAt else { continue }
            let weekday = calendar.component(.weekday, from: completedAt)
            dayCounts[weekday, default: 0] += 1
        }
        if let best = dayCounts.max(by: { $0.value < $1.value }) {
            let days = ["zondag", "maandag", "dinsdag", "woensdag", "donderdag", "vrijdag", "zaterdag"]
            if best.key > 0 && best.key <= 7 {
                insights.append("Je bent het meest productief op \(days[best.key - 1]) 📈")
            }
        }

        // Morning tasks
        let morningDone = tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            let hour = calendar.component(.hour, from: completedAt)
            return hour < 10
        }.count
        if morningDone >= 2 {
            insights.append("Je hebt \(morningDone) taken afgerond vóór 10:00 — je ochtendroetine werkt! 🌅")
        }

        // Average high priority time
        let highPriorityTimes = tasks
            .filter { $0.priority == .high && $0.actualMinutes != nil }
            .compactMap { $0.actualMinutes }
        if !highPriorityTimes.isEmpty {
            let avg = highPriorityTimes.reduce(0, +) / highPriorityTimes.count
            insights.append("Hoog-prioriteit taken duren gemiddeld \(avg) minuten 💡")
        }

        if insights.isEmpty {
            insights.append("Ga taken afvinken om inzichten te genereren 🚀")
        }

        return insights
    }

    // MARK: - Category breakdown (by tag)
    struct TagBreakdown: Identifiable {
        let id = UUID()
        let tagName: String
        let colorHex: String
        let count: Int
        let color: Color
    }

    func tagBreakdown(tasks: [TFTask]) -> [TagBreakdown] {
        var tagCounts: [String: (hex: String, count: Int)] = [:]
        for task in tasks.filter(\.isDone) {
            for tag in task.tags {
                tagCounts[tag.name] = (tag.colorHex, (tagCounts[tag.name]?.count ?? 0) + 1)
            }
        }
        return tagCounts
            .map { name, value in
                TagBreakdown(
                    tagName: name,
                    colorHex: value.hex,
                    count: value.count,
                    color: Color(hex: value.hex)
                )
            }
            .sorted { $0.count > $1.count }
    }
}
