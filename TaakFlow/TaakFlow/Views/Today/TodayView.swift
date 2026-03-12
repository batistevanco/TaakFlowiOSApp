// TodayView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query private var allTasks: [TFTask]
    @Query(filter: #Predicate<TFProject> { !$0.isArchived }) private var activeProjects: [TFProject]

    @AppStorage("userName") private var userName = ""
    @AppStorage("currentStreak") private var currentStreak = 0

    @State private var showAddTask = false
    @State private var taskToEdit: TFTask? = nil
    @State private var taskForFocus: TFTask? = nil
    var onOpenSettings: (() -> Void)

    // MARK: - Computed
    private var todayTasks: [TFTask] {
        allTasks.filter { task in
            guard let due = task.dueDate else { return false }
            return due.isToday
        }
    }

    private var morningTasks: [TFTask] { todayTasks.filter { $0.timeBlock == .morning } }
    private var afternoonTasks: [TFTask] { todayTasks.filter { $0.timeBlock == .afternoon } }
    private var eveningTasks: [TFTask] { todayTasks.filter { $0.timeBlock == .evening } }
    private var unscheduledTasks: [TFTask] {
        todayTasks.filter { $0.timeBlock == .unscheduled }
    }

    private var completedToday: Int { todayTasks.filter(\.isDone).count }
    private var urgentCount: Int { todayTasks.filter { $0.priority == .high && !$0.isDone }.count }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = userName.isEmpty ? "" : ", \(userName)"
        if hour < 12 { return "Goedemorgen\(name) 👋" }
        if hour < 18 { return "Goedemiddag\(name) ☀️" }
        return "Goedenavond\(name) 🌙"
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack(spacing: TFSpacing.xl, pinnedViews: []) {
                        // Header
                        headerView
                            .padding(.horizontal, TFSpacing.lg)

                        // Hero card
                        GradientHeroCardView(
                            completedCount: completedToday,
                            totalCount: todayTasks.count
                        )
                        .padding(.horizontal, TFSpacing.lg)

                        // Stats row
                        TodayStatsRow(
                            streakCount: currentStreak,
                            urgentCount: urgentCount,
                            projectsCount: activeProjects.count
                        )
                        .padding(.horizontal, TFSpacing.lg)

                        // Time block sections
                        if todayTasks.isEmpty {
                            EmptyStateView(
                                systemImage: "sun.max",
                                title: "Geen taken vandaag",
                                subtitle: "Tik op + om taken toe te voegen aan je dag"
                            )
                            .frame(minHeight: 250)
                        } else {
                            if !morningTasks.isEmpty {
                                TimeBlockSection(
                                    block: .morning,
                                    tasks: morningTasks,
                                    onFocus: { taskForFocus = $0 },
                                    onEdit: { taskToEdit = $0 },
                                    onDelete: deleteTask,
                                    onDuplicate: duplicateTask
                                )
                            }
                            if !afternoonTasks.isEmpty {
                                TimeBlockSection(
                                    block: .afternoon,
                                    tasks: afternoonTasks,
                                    onFocus: { taskForFocus = $0 },
                                    onEdit: { taskToEdit = $0 },
                                    onDelete: deleteTask,
                                    onDuplicate: duplicateTask
                                )
                            }
                            if !eveningTasks.isEmpty {
                                TimeBlockSection(
                                    block: .evening,
                                    tasks: eveningTasks,
                                    onFocus: { taskForFocus = $0 },
                                    onEdit: { taskToEdit = $0 },
                                    onDelete: deleteTask,
                                    onDuplicate: duplicateTask
                                )
                            }
                            if !unscheduledTasks.isEmpty {
                                TimeBlockSection(
                                    block: .unscheduled,
                                    tasks: unscheduledTasks,
                                    onFocus: { taskForFocus = $0 },
                                    onEdit: { taskToEdit = $0 },
                                    onDelete: deleteTask,
                                    onDuplicate: duplicateTask
                                )
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, TFSpacing.lg)
                }
                .background(Color.tfBgPrimary)

                // FAB
                FABButton { showAddTask = true }
                    .padding(TFSpacing.xl)
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddEditTaskSheet(existingTask: nil)
        }
        .sheet(item: $taskToEdit) { task in
            AddEditTaskSheet(existingTask: task)
        }
        .fullScreenCover(item: $taskForFocus) { task in
            FocusModeView(task: task)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: TFSpacing.xs) {
                Text(Date().fullDateString)
                    .font(.tfCaption())
                    .tracking(0.5)
                    .foregroundColor(.tfTextSecondary)
                    .textCase(.uppercase)

                Text(greeting)
                    .font(.tfLargeTitle())
                    .foregroundColor(.tfTextPrimary)
                    .tracking(-1.0)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer()
            Button(action: onOpenSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.tfTextSecondary)
                    .frame(width: 40, height: 40)
                    .background(Color.tfBgCard)
                    .clipShape(Circle())
                    .cardShadow()
            }
            .accessibilityLabel("Instellingen")
        }
    }

    // MARK: - Actions

    private func deleteTask(_ task: TFTask) {
        context.delete(task)
    }

    private func duplicateTask(_ task: TFTask) {
        let copy = TFTask(
            title: task.title + " (kopie)",
            notes: task.notes,
            priority: task.priority,
            timeBlock: task.timeBlock,
            dueDate: task.dueDate,
            dueTime: task.dueTime
        )
        copy.tags = task.tags
        copy.project = task.project
        context.insert(copy)
    }
}
