import SwiftUI
import SwiftData

// MARK: - Projects List

struct ProjectsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<TFProject> { !$0.isArchived }, sort: \TFProject.name)
    private var projects: [TFProject]

    @Query(filter: #Predicate<TFProject> { $0.isArchived }, sort: \TFProject.name)
    private var archivedProjects: [TFProject]

    @State private var showAddProject = false

    var body: some View {
        NavigationStack {
            List {
                // Inbox
                Section {
                    InboxRowView()
                }

                // Active projects
                if !projects.isEmpty {
                    Section("Projects") {
                        ForEach(projects) { project in
                            NavigationLink {
                                ProjectDetailView(project: project)
                            } label: {
                                ProjectRowView(project: project)
                            }
                        }
                        .onDelete(perform: deleteProjects)
                    }
                }

                // Archived
                if !archivedProjects.isEmpty {
                    Section {
                        DisclosureGroup("Archived (\(archivedProjects.count))") {
                            ForEach(archivedProjects) { project in
                                NavigationLink {
                                    ProjectDetailView(project: project)
                                } label: {
                                    ProjectRowView(project: project)
                                }
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddProject = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAddProject) {
                ProjectEditorSheet()
            }
        }
    }

    private func deleteProjects(at offsets: IndexSet) {
        for idx in offsets { modelContext.delete(projects[idx]) }
    }
}

// MARK: - Inbox Row

struct InboxRowView: View {
    @Query(filter: #Predicate<TFTask> { $0.project == nil })
    private var inboxTasks: [TFTask]

    private var pendingCount: Int { inboxTasks.filter { !$0.isCompleted }.count }

    var body: some View {
        NavigationLink {
            InboxView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "tray.fill")
                    .foregroundStyle(.blue)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Inbox")
                        .font(.body)
                    Text("\(pendingCount) remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !inboxTasks.isEmpty {
                    CircularProgressView(
                        progress: inboxTasks.isEmpty
                            ? 0
                            : Double(inboxTasks.filter { $0.isCompleted }.count) / Double(inboxTasks.count),
                        color: .blue
                    )
                    .frame(width: 24, height: 24)
                }
            }
        }
    }
}

// MARK: - Project Row

struct ProjectRowView: View {
    let project: TFProject

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: project.icon)
                .foregroundStyle(project.color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.body)
                let pending = project.tasks.filter { !$0.isCompleted }.count
                Text("\(pending) remaining · \(project.tasks.count) total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if !project.tasks.isEmpty {
                CircularProgressView(progress: project.progress, color: project.color)
                    .frame(width: 24, height: 24)
            }
        }
    }
}

// MARK: - Inbox View

struct InboxView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<TFTask> { $0.project == nil })
    private var tasks: [TFTask]
    @State private var showAddTask = false

    private var sorted: [TFTask] {
        tasks.sorted { a, b in
            if a.isCompleted != b.isCompleted { return !a.isCompleted }
            return a.createdAt < b.createdAt
        }
    }

    var body: some View {
        List {
            if sorted.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "Inbox is empty",
                    subtitle: "Tasks not assigned to a project live here"
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                ForEach(sorted) { task in
                    TaskRowView(task: task)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }
                .onDelete { offsets in
                    for idx in offsets { modelContext.delete(sorted[idx]) }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Inbox")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAddTask = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddEditTaskSheet()
        }
    }
}

// MARK: - Project Editor Sheet

struct ProjectEditorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var project: TFProject? = nil

    @State private var name = ""
    @State private var selectedColor: Color = .blue
    @State private var selectedIcon = "folder"
    @FocusState private var nameFocused: Bool

    private var isEditing: Bool { project != nil }

    let presetColors: [Color] = [
        .blue, .red, .orange, .yellow, .green,
        .teal, .purple, .pink, .indigo, .cyan
    ]
    let presetIcons = [
        "folder", "star", "briefcase", "house", "book",
        "heart", "bolt", "flame", "leaf", "camera",
        "music.note", "cart", "paintpalette", "graduationcap", "figure.run"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Project name", text: $name)
                        .focused($nameFocused)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(presetColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 36, height: 36)
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
                    .padding(.vertical, 6)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                        ForEach(presetIcons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title3)
                                .frame(width: 38, height: 38)
                                .background(
                                    selectedIcon == icon
                                        ? selectedColor.opacity(0.15)
                                        : Color(.systemGray6)
                                )
                                .foregroundStyle(selectedIcon == icon ? selectedColor : .secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture { selectedIcon = icon }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle(isEditing ? "Edit Project" : "New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Create") { save() }
                        .fontWeight(.semibold)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let project {
                    name = project.name
                    selectedColor = project.color
                    selectedIcon  = project.icon
                } else {
                    nameFocused = true
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let project {
            project.name     = trimmed
            project.colorHex = selectedColor.toHex()
            project.icon     = selectedIcon
        } else {
            let p = TFProject(name: trimmed, colorHex: selectedColor.toHex(), icon: selectedIcon)
            modelContext.insert(p)
        }
        dismiss()
    }
}

#Preview {
    ProjectsView()
        .modelContainer(for: [TFTask.self, TFProject.self, TFTag.self], inMemory: true)
}
