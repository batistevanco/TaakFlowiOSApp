import SwiftUI
import SwiftData

struct TodayView: View {
    @Query private var allTasks: [TFTask]
    @State private var showAddTask = false

    // MARK: Computed task lists

    private var overdueTasks: [TFTask] {
        allTasks.filter { task in
            guard let due = task.dueDate, !task.isCompleted else { return false }
            let dueDay = Calendar.current.startOfDay(for: due)
            let today  = Calendar.current.startOfDay(for: Date())
            return dueDay < today
        }
        .sorted { ($0.dueDate ?? $0.createdAt) < ($1.dueDate ?? $1.createdAt) }
    }

    private var todayTasks: [TFTask] {
        allTasks.filter { $0.isDueToday }
    }

    private var completedTodayCount: Int { todayTasks.filter { $0.isCompleted }.count }
    private var totalTodayCount: Int { todayTasks.count }

    private func tasks(for block: TimeBlock) -> [TFTask] {
        todayTasks
            .filter { $0.timeBlock == block }
            .sorted { a, b in
                if a.isCompleted != b.isCompleted { return !a.isCompleted }
                guard let ad = a.dueDate, let bd = b.dueDate else { return a.createdAt < b.createdAt }
                return ad < bd
            }
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    progressCard

                    if !overdueTasks.isEmpty {
                        taskSection(
                            title: "Overdue",
                            icon: "exclamationmark.triangle.fill",
                            iconColor: .red,
                            tasks: overdueTasks
                        )
                    }

                    ForEach(TimeBlock.allCases) { block in
                        let blockTasks = tasks(for: block)
                        if !blockTasks.isEmpty {
                            taskSection(
                                title: block.rawValue,
                                icon: block.icon,
                                iconColor: block.color,
                                tasks: blockTasks
                            )
                        }
                    }

                    if todayTasks.isEmpty && overdueTasks.isEmpty {
                        EmptyStateView(
                            icon: "checkmark.circle.dashed",
                            title: "No tasks for today",
                            subtitle: "Tap + to add your first task"
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .navigationTitle("Today")
            .overlay(alignment: .bottomTrailing) {
                FloatingActionButton { showAddTask = true }
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddEditTaskSheet(initialDueDate: Calendar.current.startOfDay(for: Date()))
        }
    }

    // MARK: Subviews

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Date().formatted(.dateTime.weekday(.wide).month().day().year()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(
                        totalTodayCount == 0
                            ? "No tasks scheduled"
                            : "\(completedTodayCount) of \(totalTodayCount) tasks completed"
                    )
                    .font(.subheadline.weight(.medium))
                }
                Spacer()
                Text(
                    totalTodayCount == 0
                        ? "–"
                        : "\(Int(Double(completedTodayCount) / Double(totalTodayCount) * 100))%"
                )
                .font(.title2.bold())
            }
            ProgressView(
                value: Double(completedTodayCount),
                total: Double(max(totalTodayCount, 1))
            )
            .tint(.accentColor)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func taskSection(
        title: String,
        icon: String,
        iconColor: Color,
        tasks: [TFTask]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section header
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.caption.weight(.semibold))
                Text(title.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
                Spacer()
                let pending = tasks.filter { !$0.isCompleted }.count
                if pending > 0 {
                    Text("\(pending)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            // Task cards
            VStack(spacing: 0) {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { idx, task in
                    TaskRowView(task: task)
                    if idx < tasks.count - 1 {
                        Divider().padding(.leading, 44)
                    }
                }
            }
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

#Preview {
    let schema = Schema([TFTask.self, TFProject.self, TFTag.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    return TodayView().modelContainer(container)
}
