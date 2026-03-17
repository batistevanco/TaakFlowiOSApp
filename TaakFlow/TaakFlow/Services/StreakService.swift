// StreakService.swift
// TaakFlow — Vancoillie Studio

import Foundation

// MARK: - StreakService

class StreakService {
    static let shared = StreakService()
    private init() {}

    private let defaults = UserDefaults.standard

    var currentStreak: Int {
        get { defaults.integer(forKey: "currentStreak") }
        set { defaults.set(newValue, forKey: "currentStreak") }
    }
    var longestStreak: Int {
        get { defaults.integer(forKey: "longestStreak") }
        set { defaults.set(newValue, forKey: "longestStreak") }
    }
    var lastStreakDate: String {
        get { defaults.string(forKey: "lastStreakDate") ?? "" }
        set { defaults.set(newValue, forKey: "lastStreakDate") }
    }

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // MARK: - Sync
    func syncStreak(tasks: [TFTask]) {
        let completionDays = uniqueCompletionDays(from: tasks)
        let sortedDays = completionDays.sorted()

        currentStreak = currentStreakLength(from: completionDays)
        longestStreak = longestStreakLength(from: sortedDays)
        lastStreakDate = sortedDays.last.map { dateFormatter.string(from: $0) } ?? ""
    }

    func resetStreak() {
        currentStreak = 0
        longestStreak = 0
        lastStreakDate = ""
    }

    // MARK: - Helpers
    private func uniqueCompletionDays(from tasks: [TFTask]) -> Set<Date> {
        Set(tasks.compactMap { task in
            guard let completedAt = task.completedAt else { return nil }
            return Calendar.current.startOfDay(for: completedAt)
        })
    }

    private func currentStreakLength(from completionDays: Set<Date>) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today

        let anchorDay: Date
        if completionDays.contains(today) {
            anchorDay = today
        } else if completionDays.contains(yesterday) {
            anchorDay = yesterday
        } else {
            return 0
        }

        var streak = 0
        var currentDay = anchorDay

        while completionDays.contains(currentDay) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDay) else { break }
            currentDay = previousDay
        }

        return streak
    }

    private func longestStreakLength(from sortedDays: [Date]) -> Int {
        guard !sortedDays.isEmpty else { return 0 }

        let calendar = Calendar.current
        var longest = 1
        var running = 1

        for index in 1..<sortedDays.count {
            let previous = sortedDays[index - 1]
            let current = sortedDays[index]
            let delta = calendar.dateComponents([.day], from: previous, to: current).day ?? 0

            if delta == 1 {
                running += 1
            } else {
                running = 1
            }

            longest = max(longest, running)
        }

        return longest
    }
}
