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

    // MARK: - Check and update streak
    func checkAndUpdateStreak(tasks: [TFTask]) {
        let today = dateFormatter.string(from: Date())

        // Already updated today
        if lastStreakDate == today { return }

        let hasCompletedToday = tasks.contains { task in
            guard let completedAt = task.completedAt else { return false }
            return Calendar.current.isDateInToday(completedAt)
        }

        guard hasCompletedToday else { return }

        // Check if yesterday was logged
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterday = dateFormatter.string(from: yesterdayDate)

        if lastStreakDate == yesterday {
            currentStreak += 1
        } else if lastStreakDate != today {
            // Streak broken or first task
            currentStreak = 1
        }

        lastStreakDate = today
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }

    func resetStreak() {
        currentStreak = 0
        lastStreakDate = ""
    }
}
