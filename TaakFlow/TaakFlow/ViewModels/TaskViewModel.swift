// TaskViewModel.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData
import Observation

// MARK: - Sort Option

enum TFSortOption: String, CaseIterable, Identifiable {
    case dueDate     = "Vervaldatum"
    case priority    = "Prioriteit"
    case createdAt   = "Aanmaakdatum"
    case alphabetical = "Alfabetisch"
    var id: String { rawValue }
}

// MARK: - Filter Option

enum TFFilterOption: String, CaseIterable, Identifiable {
    case all      = "Alle"
    case high     = "🔴 Hoog"
    case medium   = "🟠 Middel"
    case low      = "🟢 Laag"
    case done     = "✅ Klaar"
    case today    = "📅 Vandaag"
    case overdue  = "⚠️ Verlopen"
    var id: String { rawValue }
}

// MARK: - TaskViewModel

@Observable
class TaskViewModel {
    var searchText: String = ""
    var activeFilter: TFFilterOption = .all
    var sortOption: TFSortOption = .dueDate
    var showCompleted: Bool = true

    // MARK: - Filtering
    func filteredTasks(_ tasks: [TFTask]) -> [TFTask] {
        var result = tasks

        // Search
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Filter
        switch activeFilter {
        case .all:
            break
        case .high:
            result = result.filter { $0.priority == .high && !$0.isDone }
        case .medium:
            result = result.filter { $0.priority == .medium && !$0.isDone }
        case .low:
            result = result.filter { $0.priority == .low && !$0.isDone }
        case .done:
            result = result.filter { $0.isDone }
        case .today:
            result = result.filter { $0.isToday && !$0.isDone }
        case .overdue:
            result = result.filter { $0.isOverdue }
        }

        return sorted(result)
    }

    func todayTasks(_ tasks: [TFTask]) -> [TFTask] {
        tasks.filter { task in
            guard let due = task.dueDate else { return false }
            return due.isToday
        }
    }

    func tasksForBlock(_ tasks: [TFTask], block: TFTimeBlock) -> [TFTask] {
        tasks
            .filter { $0.timeBlock == block }
            .sorted { a, b in
                switch (a.dueTime, b.dueTime) {
                case (.some(let t1), .some(let t2)): return t1 < t2
                case (.some, .none): return true
                default: return false
                }
            }
    }

    // MARK: - Sorting
    private func sorted(_ tasks: [TFTask]) -> [TFTask] {
        tasks.sorted { a, b in
            switch sortOption {
            case .dueDate:
                switch (a.dueDate, b.dueDate) {
                case (.some(let d1), .some(let d2)): return d1 < d2
                case (.some, .none): return true
                default: return a.createdAt < b.createdAt
                }
            case .priority:
                return a.priority.sortOrder < b.priority.sortOrder
            case .createdAt:
                return a.createdAt > b.createdAt
            case .alphabetical:
                return a.title.localizedCompare(b.title) == .orderedAscending
            }
        }
    }

    // MARK: - CRUD helpers
    func addTask(
        title: String,
        notes: String = "",
        priority: TFPriority = .none,
        timeBlock: TFTimeBlock = .unscheduled,
        dueDate: Date? = nil,
        dueTime: Date? = nil,
        project: TFProject? = nil,
        tags: [TFTag] = [],
        subtasks: [TFSubtask] = [],
        estimatedMinutes: Int? = nil,
        context: ModelContext
    ) {
        let task = TFTask(
            title: title,
            notes: notes,
            priority: priority,
            timeBlock: timeBlock,
            dueDate: dueDate,
            dueTime: dueTime
        )
        task.project = project
        task.tags = tags
        task.subtasks = subtasks
        task.estimatedMinutes = estimatedMinutes
        context.insert(task)
    }

    func deleteTask(_ task: TFTask, context: ModelContext) {
        context.delete(task)
    }

    func duplicateTask(_ task: TFTask, context: ModelContext) {
        let copy = TFTask(
            title: task.title + " (kopie)",
            notes: task.notes,
            priority: task.priority,
            timeBlock: task.timeBlock,
            dueDate: task.dueDate,
            dueTime: task.dueTime
        )
        copy.project = task.project
        copy.tags = task.tags
        copy.subtasks = task.subtasks.map { TFSubtask(title: $0.title) }
        copy.estimatedMinutes = task.estimatedMinutes
        context.insert(copy)
    }
}
