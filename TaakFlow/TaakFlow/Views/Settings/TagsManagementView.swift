import SwiftUI
import SwiftData

// MARK: - Tags Management

struct TagsManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TFTag.name) private var tags: [TFTag]

    @State private var showAddTag   = false
    @State private var editingTag: TFTag? = nil

    var body: some View {
        List {
            if tags.isEmpty {
                EmptyStateView(
                    icon: "tag",
                    title: "No tags yet",
                    subtitle: "Create tags to organise and filter your tasks"
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                ForEach(tags) { tag in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(tag.color)
                            .frame(width: 12, height: 12)
                        Text(tag.name)
                        Spacer()
                        Text("\(tag.tasks.count) task\(tag.tasks.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            modelContext.delete(tag)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button { editingTag = tag } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
        .navigationTitle("Manage Tags")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAddTag = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAddTag) {
            TagEditorSheet()
        }
        .sheet(item: $editingTag) { tag in
            TagEditorSheet(tag: tag)
        }
    }
}

// MARK: - Tag Editor Sheet

struct TagEditorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var tag: TFTag? = nil

    @State private var name = ""
    @State private var selectedColor: Color = .blue
    @FocusState private var nameFocused: Bool

    private var isEditing: Bool { tag != nil }

    let presetColors: [Color] = [
        .blue, .red, .orange, .yellow, .green,
        .teal, .purple, .pink, .indigo, .cyan
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Tag name", text: $name)
                        .focused($nameFocused)
                }
                Section("Color") {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 5),
                        spacing: 14
                    ) {
                        ForEach(presetColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 38, height: 38)
                                .overlay {
                                    if color.toHex() == selectedColor.toHex() {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                                .onTapGesture { selectedColor = color }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(isEditing ? "Edit Tag" : "New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") { save() }
                        .fontWeight(.semibold)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let tag {
                    name = tag.name
                    selectedColor = tag.color
                } else {
                    nameFocused = true
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let tag {
            tag.name     = trimmed
            tag.colorHex = selectedColor.toHex()
        } else {
            let newTag = TFTag(name: trimmed, colorHex: selectedColor.toHex())
            modelContext.insert(newTag)
        }
        dismiss()
    }
}
