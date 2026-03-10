import SwiftUI
import SwiftData

// MARK: - Enums

enum TaskPriority: String, Codable, CaseIterable {
    case high
    case medium
    case low
    case none

    var label: String {
        switch self {
        case .high:   return "High"
        case .medium: return "Medium"
        case .low:    return "Low"
        case .none:   return "None"
        }
    }

    var color: Color {
        switch self {
        case .high:   return .red
        case .medium: return .orange
        case .low:    return .green
        case .none:   return Color(.systemGray4)
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

enum TimeBlock: String, CaseIterable, Identifiable {
    case morning      = "Morning"
    case afternoon    = "Afternoon"
    case evening      = "Evening"
    case unscheduled  = "Unscheduled"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .morning:     return "sunrise.fill"
        case .afternoon:   return "sun.max.fill"
        case .evening:     return "moon.stars.fill"
        case .unscheduled: return "clock"
        }
    }

    var color: Color {
        switch self {
        case .morning:     return .orange
        case .afternoon:   return .yellow
        case .evening:     return .indigo
        case .unscheduled: return .gray
        }
    }
}

// MARK: - TFTask Model

@Model
final class TFTask {
    var id: UUID = UUID()
    var title: String = ""
    var notes: String = ""
    var isCompleted: Bool = false
    var priority: TaskPriority = TaskPriority.none
    var dueDate: Date? = nil
    var hasTime: Bool = false
    var hasReminder: Bool = false
    var notificationID: String? = nil
    var createdAt: Date = Date()

    var project: TFProject? = nil
    var tags: [TFTag] = []

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.notes = ""
        self.isCompleted = false
        self.priority = .none
        self.hasTime = false
        self.hasReminder = false
        self.createdAt = Date()
    }

    // MARK: Computed

    var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        if hasTime {
            return dueDate < Date()
        } else {
            return Calendar.current.startOfDay(for: dueDate) < Calendar.current.startOfDay(for: Date())
        }
    }

    var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    var timeBlock: TimeBlock {
        guard hasTime, let dueDate else { return .unscheduled }
        let hour = Calendar.current.component(.hour, from: dueDate)
        if (6...11).contains(hour)  { return .morning }
        if (12...16).contains(hour) { return .afternoon }
        if (17...23).contains(hour) { return .evening }
        return .unscheduled
    }
}
