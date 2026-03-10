import SwiftUI
import SwiftData

struct AllTasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTasks: [TFTask]
    @Query(sort: \TFProject.name) private var allProjects: [TFProject]
    @Query(sort: \TFTag.name)     private var allTags: [TFTag]

    @State private var searchText = ""
    @State private var showAddTask = false
    @State private var filterPriority: TaskPriority? = nil
    @State private var filterProject: TFProject? = nil
    @State private var filterTag: TFTag? = nil
    @State private var sortOrder: TaskSortOrder = .dueDate

    private var hasActiveFilters: Bool {
        filterPriority != nil || filterProject != nil || filterTag != nil
    }

    // MARK: Filtered & Sorted Tasks

    private var displayedTasks: [TFTask] {
        var tasks = allTasks

        if !searchText.isEmpty {
            tasks = tasks.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        if let p = filterPriority { tasks = tasks.filter { $0.priority == p } }
        if let proj = filterProject { tasks = tasks.filter { $0.project?.id == proj.id } }
        if let tag = filterTag { tasks = tasks.filter { $0.tags.contains { $0.id == tag.id } } }

        switch sortOrder {
        case .dueDate:
            tasks.sort {
                switch ($0.dueDate, $1.dueDate) {
                case (nil, nil): return $0.createdAt > $1.createdAt
                case (nil, _):   return false
                case (_, nil):   return true
                case (let a, let b): return a! < b!
                }
            }
        case .priority:
            tasks.sort { $0.priority.sortOrder < $1.priority.sortOrder }
        case .createdAt:
            tasks.sort { $0.createdAt > $1.createdAt }
        }

        return tasks
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                List {
                    ForEach(displayedTasks) { task in
                        TaskRowView(task: task)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: deleteTasks)

                    if displayedTasks.isEmpty {
                        EmptyStateView(
                            icon: "checklist",
                            title: hasActiveFilters ? "No matching tasks" : "No tasks yet",
                            subtitle: hasActiveFilters
                                ? "Try clearing your filters"
                                : "Tap + to create your first task"
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search tasks…")
                .navigationTitle("All Tasks")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button { showAddTask = true } label: { Image(systemName: "plus") }
                    }
                    ToolbarItem(placement: .secondaryAction) {
                        filterMenu
                    }
                }

                // Active-filter chips bar
                if hasActiveFilters {
                    activeFiltersBar
                        .padding(.bottom, 0)
                }
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddEditTaskSheet()
        }
    }

    // MARK: Filter menu

    private var filterMenu: some View {
        Menu {
            // Sort
            Menu("Sort by") {
                ForEach(TaskSortOrder.allCases, id: \.self) { order in
                    Button {
                        sortOrder = order
                    } label: {
                        if sortOrder == order {
                            Label(order.label, systemImage: "checkmark")
                        } else {
                            Text(order.label)
                        }
                    }
                }
            }

            Divider()

            // Filter priority
            Menu("Priority") {
                Button("All Priorities") { filterPriority = nil }
                Divider()
                ForEach(TaskPriority.allCases, id: \.self) { p in
                    Button(p.label) { filterPriority = p }
                }
            }

            // Filter project
            if !allProjects.isEmpty {
                Menu("Project") {
                    Button("All Projects") { filterProject = nil }
                    Divider()
                    ForEach(allProjects.filter { !$0.isArchived }) { proj in
                        Button(proj.name) { filterProject = proj }
                    }
                }
            }

            // Filter tag
            if !allTags.isEmpty {
                Menu("Tag") {
                    Button("All Tags") { filterTag = nil }
                    Divider()
                    ForEach(allTags) { tag in
                        Button(tag.name) { filterTag = tag }
                    }
                }
            }

            if hasActiveFilters {
                Divider()
                Button(role: .destructive) {
                    filterPriority = nil; filterProject = nil; filterTag = nil
                } label: {
                    Label("Clear All Filters", systemImage: "xmark.circle")
                }
            }
        } label: {
            Image(
                systemName: hasActiveFilters
                    ? "line.3.horizontal.decrease.circle.fill"
                    : "line.3.horizontal.decrease.circle"
            )
        }
    }

    // MARK: Active filters bar

    private var activeFiltersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let p = filterPriority {
                    FilterChip(label: p.label, color: p.color) { filterPriority = nil }
                }
                if let proj = filterProject {
                    FilterChip(label: proj.name, color: proj.color) { filterProject = nil }
                }
                if let tag = filterTag {
                    FilterChip(label: tag.name, color: tag.color) { filterTag = nil }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    // MARK: Helpers

    private func deleteTasks(at offsets: IndexSet) {
        for idx in offsets {
            let task = displayedTasks[idx]
            NotificationManager.shared.cancelNotification(for: task)
            modelContext.delete(task)
        }
    }
}

// MARK: - Sort order enum

enum TaskSortOrder: CaseIterable {
    case dueDate, priority, createdAt
    var label: String {
        switch self {
        case .dueDate:   return "Due Date"
        case .priority:  return "Priority"
        case .createdAt: return "Date Created"
        }
    }
}

#Preview {
    let schema = Schema([TFTask.self, TFProject.self, TFTag.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    return AllTasksView().modelContainer(container)
}
