import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let project: TFProject

    @State private var showAddTask   = false
    @State private var showEditSheet = false

    private var pendingTasks: [TFTask] {
        project.tasks
            .filter { !$0.isCompleted }
            .sorted { a, b in
                if a.priority.sortOrder != b.priority.sortOrder {
                    return a.priority.sortOrder < b.priority.sortOrder
                }
                return a.createdAt < b.createdAt
            }
    }

    private var completedTasks: [TFTask] {
        project.tasks
            .filter { $0.isCompleted }
            .sorted { ($0.dueDate ?? $0.createdAt) > ($1.dueDate ?? $1.createdAt) }
    }

    var body: some View {
        List {
            // Progress header
            if !project.tasks.isEmpty {
                Section {
                    VStack(spacing: 10) {
                        HStack {
                            Text("\(project.completedCount) of \(project.tasks.count) completed")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(Int(project.progress * 100))%")
                                .font(.subheadline.bold())
                                .foregroundStyle(project.color)
                        }
                        ProgressView(value: project.progress)
                            .tint(project.color)
                    }
                    .padding(.vertical, 4)
                }
            }

            // Pending
            if !pendingTasks.isEmpty {
                Section("Pending") {
                    ForEach(pendingTasks) { task in
                        TaskRowView(task: task)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                    }
                    .onDelete { offsets in
                        for idx in offsets { modelContext.delete(pendingTasks[idx]) }
                    }
                }
            }

            // Completed
            if !completedTasks.isEmpty {
                Section("Completed") {
                    ForEach(completedTasks) { task in
                        TaskRowView(task: task)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                    }
                }
            }

            // Empty state
            if project.tasks.isEmpty {
                Section {
                    EmptyStateView(
                        icon: project.icon,
                        title: "No tasks yet",
                        subtitle: "Tap + to add your first task to \(project.name)"
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAddTask = true } label: { Image(systemName: "plus") }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button { showEditSheet = true } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    project.isArchived.toggle()
                } label: {
                    Label(
                        project.isArchived ? "Unarchive" : "Archive",
                        systemImage: project.isArchived ? "archivebox" : "archivebox"
                    )
                }
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddEditTaskSheet(initialProject: project)
        }
        .sheet(isPresented: $showEditSheet) {
            ProjectEditorSheet(project: project)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TFTask.self, TFProject.self, TFTag.self, configurations: config)
    let project = TFProject(name: "Sample Project", colorHex: "#007AFF", icon: "star")
    container.mainContext.insert(project)
    return NavigationStack { ProjectDetailView(project: project) }
        .modelContainer(container)
}
