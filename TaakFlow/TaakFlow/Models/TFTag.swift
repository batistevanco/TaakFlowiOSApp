// TFTag.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

@Model
class TFTag {
    var id: UUID
    var name: String
    var colorHex: String
    var sortOrder: Int

    // Relationship — inverse set on TFTask.tags
    @Relationship(deleteRule: .nullify)
    var tasks: [TFTask]

    // MARK: - Init
    init(name: String, colorHex: String = "#5B6EF5") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.sortOrder = 0
        self.tasks = []
    }

    var color: Color { Color(hex: colorHex) }
}
