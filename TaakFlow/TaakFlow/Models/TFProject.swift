// TFProject.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

@Model
class TFProject {
    var id: UUID
    var name: String
    var emoji: String
    var colorHex: String
    var notes: String
    var createdAt: Date
    var deadline: Date?
    var isArchived: Bool
    var sortOrder: Int

    // Relationship — inverse set on TFTask.project
    @Relationship(deleteRule: .cascade)
    var tasks: [TFTask]

    // MARK: - Init
    init(
        name: String,
        emoji: String = "📁",
        colorHex: String = "#5B6EF5",
        notes: String = "",
        deadline: Date? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.colorHex = colorHex
        self.notes = notes
        self.createdAt = Date()
        self.deadline = deadline
        self.isArchived = false
        self.sortOrder = 0
        self.tasks = []
    }

    // MARK: - Computed
    var totalTasks: Int { tasks.count }

    var completedTasks: Int { tasks.filter(\.isDone).count }

    var progressPercentage: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }

    var isOverdue: Bool {
        guard let dl = deadline, !isArchived else { return false }
        return dl < Date()
    }

    var color: Color { Color(hex: colorHex) }

    var deadlineUrgency: DeadlineUrgency {
        guard let dl = deadline else { return .none }
        let days = dl.daysUntil()
        if days < 0 { return .overdue }
        if days <= 3 { return .soon }
        return .ok
    }

    enum DeadlineUrgency {
        case none, ok, soon, overdue
        var color: Color {
            switch self {
            case .none:    return .tfTextSecondary
            case .ok:      return .tfPriorityLow
            case .soon:    return .tfPriorityMed
            case .overdue: return .tfPriorityHigh
            }
        }
    }
}
