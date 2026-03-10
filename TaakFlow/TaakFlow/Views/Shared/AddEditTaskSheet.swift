import SwiftUI
import SwiftData

struct AddEditTaskSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \TFProject.name) private var allProjects: [TFProject]
    @Query(sort: \TFTag.name)     private var allTags: [TFTag]

    // Pass existing task to edit, or nil to create
    var task: TFTask? = nil
    var initialDueDate: Date? = nil
    var initialProject: TFProject? = nil

    // Form state
    @State private var title = ""
    @State private var notes = ""
    @State private var priority: TaskPriority = .none
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var hasTime = false
    @State private var hasReminder = false
    @State private var selectedProject: TFProject? = nil
    @State private var selectedTagIDs: Set<UUID> = []

    @FocusState private var titleFocused: Bool

    private var isEditing: Bool { task != nil }

    var body: some View {
        NavigationStack {
            Form {
                // Title
                Section {
                    TextField("Task title", text: $title)
                        .focused($titleFocused)
                }

                // Due Date
                Section {
                    Toggle("Due Date", isOn: $hasDueDate.animation())
                    if hasDueDate {
                        DatePicker(
                            "Date",
                            selection: $dueDate,
                            displayedComponents: hasTime ? [.date, .hourAndMinute] : .date
                        )
                        Toggle("Specific time", isOn: $hasTime.animation())
                        if hasTime {
                            Toggle("Reminder notification", isOn: $hasReminder)
                                .onChange(of: hasReminder) { _, on in
                                    if on { requestNotificationPermission() }
                                }
                        }
                    }
                }

                // Priority
                Section("Priority") {
                    priorityPicker
                }

                // Project
                Section("Project") {
                    Picker("Project", selection: $selectedProject) {
                        Text("Inbox").tag(nil as TFProject?)
                        ForEach(allProjects.filter { !$0.isArchived }) { project in
                            Label(project.name, systemImage: project.icon)
                                .tag(project as TFProject?)
                        }
                    }
                }

                // Tags
                if !allTags.isEmpty {
                    Section("Tags") {
                        ForEach(allTags) { tag in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(tag.color)
                                    .frame(width: 10, height: 10)
                                Text(tag.name)
                                Spacer()
                                if selectedTagIDs.contains(tag.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                        .fontWeight(.semibold)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedTagIDs.contains(tag.id) {
                                    selectedTagIDs.remove(tag.id)
                                } else {
                                    selectedTagIDs.insert(tag.id)
                                }
                            }
                        }
                    }
                }

                // Notes
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveTask()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                populateFields()
                if !isEditing { titleFocused = true }
            }
        }
    }

    // MARK: - Priority picker (segmented style)

    private var priorityPicker: some View {
        HStack(spacing: 0) {
            ForEach(TaskPriority.allCases, id: \.self) { p in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { priority = p }
                } label: {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(p.color)
                            .frame(width: 7, height: 7)
                        Text(p.label)
                            .font(.caption.weight(.medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        priority == p
                            ? p.color.opacity(0.15)
                            : Color.clear
                    )
                    .foregroundStyle(priority == p ? p.color : .secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Logic

    private func populateFields() {
        if let task {
            title            = task.title
            notes            = task.notes
            priority         = task.priority
            hasDueDate       = task.dueDate != nil
            dueDate          = task.dueDate ?? Date()
            hasTime          = task.hasTime
            hasReminder      = task.hasReminder
            selectedProject  = task.project
            selectedTagIDs   = Set(task.tags.map { $0.id })
        } else {
            if let d = initialDueDate { hasDueDate = true; dueDate = d }
            selectedProject = initialProject
        }
    }

    private func saveTask() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let pickedTags = allTags.filter { selectedTagIDs.contains($0.id) }
        let pickedDate: Date? = hasDueDate ? dueDate : nil

        if let task {
            // Update existing
            task.title       = trimmed
            task.notes       = notes
            task.priority    = priority
            task.dueDate     = pickedDate
            task.hasTime     = hasDueDate && hasTime
            task.hasReminder = hasDueDate && hasTime && hasReminder
            task.project     = selectedProject
            task.tags        = pickedTags

            if task.hasReminder {
                NotificationManager.shared.scheduleNotification(for: task)
            } else {
                NotificationManager.shared.cancelNotification(for: task)
            }
        } else {
            // Create new
            let newTask      = TFTask(title: trimmed)
            newTask.notes    = notes
            newTask.priority = priority
            newTask.dueDate  = pickedDate
            newTask.hasTime  = hasDueDate && hasTime
            newTask.hasReminder = hasDueDate && hasTime && hasReminder
            newTask.project  = selectedProject
            newTask.tags     = pickedTags

            modelContext.insert(newTask)

            if newTask.hasReminder {
                NotificationManager.shared.scheduleNotification(for: newTask)
            }
        }

        dismiss()
    }

    private func requestNotificationPermission() {
        Task {
            let granted = await NotificationManager.shared.requestPermission()
            if !granted { hasReminder = false }
        }
    }
}
