// TFTask.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

// MARK: - Supporting Types

enum TFPriority: String, Codable, CaseIterable, Identifiable {
    case none   = "none"
    case low    = "low"
    case medium = "medium"
    case high   = "high"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .none:   return .tfPriorityNone
        case .low:    return .tfPriorityLow
        case .medium: return .tfPriorityMed
        case .high:   return .tfPriorityHigh
        }
    }

    var label: String {
        switch self {
        case .none:   return "Geen"
        case .low:    return "Laag"
        case .medium: return "Middel"
        case .high:   return "Hoog"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high:   return 0
        case .medium: return 1
        case .low:    return 2
        case .none:   return 3
        }
    }
}

enum TFTimeBlock: String, Codable, CaseIterable, Identifiable {
    case morning      = "morning"
    case afternoon    = "afternoon"
    case evening      = "evening"
    case unscheduled  = "unscheduled"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .morning:     return "🌅"
        case .afternoon:   return "☀️"
        case .evening:     return "🌙"
        case .unscheduled: return "📋"
        }
    }

    var label: String {
        switch self {
        case .morning:     return "Ochtend"
        case .afternoon:   return "Middag"
        case .evening:     return "Avond"
        case .unscheduled: return "Ongepland"
        }
    }

    var timeRange: String {
        switch self {
        case .morning:     return "06:00–12:00"
        case .afternoon:   return "12:00–17:00"
        case .evening:     return "17:00–23:59"
        case .unscheduled: return ""
        }
    }

    static func from(hour: Int) -> TFTimeBlock {
        switch hour {
        case 6..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<24: return .evening
        default: return .unscheduled
        }
    }
}

struct TFSubtask: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var title: String
    var isDone: Bool = false
}

struct TFRecurrenceRule: Codable, Hashable {
    enum Frequency: String, Codable {
        case daily, weekly, monthly
    }
    var frequency: Frequency
    var interval: Int = 1
    var daysOfWeek: [Int]?
    var endDate: Date?
}

// MARK: - TFTask Model

@Model
class TFTask {
    var id: UUID
    var title: String
    var notes: String
    var isDone: Bool
    var createdAt: Date
    var dueDate: Date?
    var dueTime: Date?
    var completedAt: Date?
    var priority: TFPriority
    var timeBlock: TFTimeBlock
    var isRecurring: Bool

    // SwiftData handles Codable value types natively — no transformer needed
    var recurrenceRule: TFRecurrenceRule?
    var subtasks: [TFSubtask]

    var estimatedMinutes: Int?
    var actualMinutes: Int?

    // Relationships
    @Relationship(deleteRule: .nullify, inverse: \TFProject.tasks)
    var project: TFProject?

    @Relationship(deleteRule: .nullify, inverse: \TFTag.tasks)
    var tags: [TFTag]

    // MARK: - Init
    init(
        title: String,
        notes: String = "",
        priority: TFPriority = .none,
        timeBlock: TFTimeBlock = .unscheduled,
        dueDate: Date? = nil,
        dueTime: Date? = nil,
        isRecurring: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.isDone = false
        self.createdAt = Date()
        self.dueDate = dueDate
        self.dueTime = dueTime
        self.priority = priority
        self.timeBlock = timeBlock
        self.isRecurring = isRecurring
        self.subtasks = []
        self.tags = []
    }

    // MARK: - Computed
    var isOverdue: Bool {
        guard let due = dueDate, !isDone else { return false }
        return due < Calendar.current.startOfDay(for: Date()) && !due.isToday
    }

    var isToday: Bool {
        guard let due = dueDate else { return false }
        return due.isToday
    }

    var progressPercentage: Double {
        guard !subtasks.isEmpty else { return isDone ? 1.0 : 0.0 }
        let done = subtasks.filter(\.isDone).count
        return Double(done) / Double(subtasks.count)
    }
}

