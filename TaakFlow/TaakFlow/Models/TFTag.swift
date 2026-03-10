import SwiftUI
import SwiftData

@Model
final class TFTag {
    var id: UUID = UUID()
    var name: String = ""
    var colorHex: String = "#007AFF"

    @Relationship(deleteRule: .nullify, inverse: \TFTask.tags)
    var tasks: [TFTask] = []

    init(name: String, colorHex: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}
