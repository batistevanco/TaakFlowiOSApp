import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    let task: TFTask

    @State private var showEditSheet = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // Completion toggle
            Button {
                withAnimation(.spring(duration: 0.25)) {
                    task.isCompleted.toggle()
                    if task.isCompleted {
                        NotificationManager.shared.cancelNotification(for: task)
                    }
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : Color(.systemGray3))
                    .animation(.spring(duration: 0.2), value: task.isCompleted)
            }
            .buttonStyle(.plain)

            // Content
            VStack(alignment: .leading, spacing: 4) {

                // Title row
                HStack(alignment: .center, spacing: 6) {
                    Text(task.title)
                        .font(.body)
                        .strikethrough(task.isCompleted, color: .secondary)
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)
                        .lineLimit(2)
                    Spacer(minLength: 4)
                    PriorityBadge(priority: task.priority)
                }

                // Meta row: project + due date
                let hasMeta = task.project != nil || task.dueDate != nil
                if hasMeta {
                    HStack(spacing: 10) {
                        if let project = task.project {
                            Label(project.name, systemImage: project.icon)
                                .font(.caption)
                                .foregroundStyle(project.color)
                                .lineLimit(1)
                        }
                        if let due = task.dueDate {
                            HStack(spacing: 3) {
                                Image(systemName: "calendar")
                                Text(task.hasTime
                                     ? "\(due.formattedDueDate) · \(due.formattedTime)"
                                     : due.formattedDueDate)
                            }
                            .font(.caption)
                            .foregroundStyle(task.isOverdue ? .red : .secondary)
                        }
                    }
                }

                // Tags
                if !task.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(task.tags.sorted { $0.name < $1.name }) { tag in
                                TagPill(tag: tag)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture { showEditSheet = true }

        // Swipe-to-complete (leading)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                withAnimation { task.isCompleted.toggle() }
            } label: {
                Label(
                    task.isCompleted ? "Undo" : "Done",
                    systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark"
                )
            }
            .tint(task.isCompleted ? .orange : .green)
        }

        // Trailing: reschedule (overdue) + delete
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                NotificationManager.shared.cancelNotification(for: task)
                modelContext.delete(task)
            } label: {
                Label("Delete", systemImage: "trash")
            }

            if task.isOverdue {
                Button {
                    task.dueDate = Date()
                } label: {
                    Label("Reschedule", systemImage: "calendar.badge.plus")
                }
                .tint(.blue)
            }
        }

        .sheet(isPresented: $showEditSheet) {
            AddEditTaskSheet(task: task)
        }
    }
}
