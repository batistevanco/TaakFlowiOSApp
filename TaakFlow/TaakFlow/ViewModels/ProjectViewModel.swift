// ProjectViewModel.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData
import Observation

@Observable
class ProjectViewModel {
    var showArchived: Bool = false

    // MARK: - Filtering
    func activeProjects(_ projects: [TFProject]) -> [TFProject] {
        projects
            .filter { !$0.isArchived }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    func archivedProjects(_ projects: [TFProject]) -> [TFProject] {
        projects.filter { $0.isArchived }
    }

    // MARK: - CRUD helpers
    func addProject(
        name: String,
        emoji: String = "📁",
        colorHex: String = "#5B6EF5",
        notes: String = "",
        deadline: Date? = nil,
        context: ModelContext
    ) {
        let project = TFProject(
            name: name,
            emoji: emoji,
            colorHex: colorHex,
            notes: notes,
            deadline: deadline
        )
        context.insert(project)
    }

    func deleteProject(_ project: TFProject, context: ModelContext) {
        context.delete(project)
    }

    func archiveProject(_ project: TFProject) {
        project.isArchived = true
    }

    func unarchiveProject(_ project: TFProject) {
        project.isArchived = false
    }
}
