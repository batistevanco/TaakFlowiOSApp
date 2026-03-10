import SwiftUI
import SwiftData

@Model
final class TFProject {
    var id: UUID = UUID()
    var name: String = ""
    var colorHex: String = "#007AFF"
    var icon: String = "folder"
    var isArchived: Bool = false
    var createdAt: Date = Date()

    @Relationship(deleteRule: .nullify, inverse: \TFTask.project)
    var tasks: [TFTask] = []

    init(name: String, colorHex: String = "#007AFF", icon: String = "folder") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
        self.isArchived = false
        self.createdAt = Date()
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    var completedCount: Int {
        tasks.filter { $0.isCompleted }.count
    }

    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedCount) / Double(tasks.count)
    }
}
