// TodayView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

enum TodayTaskScope: String, CaseIterable, Identifiable {
    case today = "Vandaag"
    case all = "Alle"
    case overdue = "Verlopen"

    var id: String { rawValue }
}

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query private var allTasks: [TFTask]
    @Query(filter: #Predicate<TFProject> { !$0.isArchived }) private var activeProjects: [TFProject]

    @AppStorage("userName") private var userName = ""
    @AppStorage("currentStreak") private var currentStreak = 0
    @AppStorage("defaultTaskScope") private var defaultScopeRaw = TodayTaskScope.today.rawValue

    @State private var showAddTask = false
    @State private var taskToEdit: TFTask? = nil
    @State private var taskForFocus: TFTask? = nil
    @State private var selectedScope: TodayTaskScope = .today
    @State private var searchText = ""
    var onOpenSettings: (() -> Void)

    private var scopeFallbackToken: String {
        allTasks
            .map { task in
                [
                    task.id.uuidString,
                    task.isDone.description,
                    task.dueDate?.ISO8601Format() ?? "nil"
                ].joined(separator: "#")
            }
            .sorted()
            .joined(separator: "|")
    }

    // MARK: - Computed
    private var todayTasks: [TFTask] {
        sortedTasks(allTasks.filter { task in
            guard let due = task.dueDate else { return false }
            return due.isToday
        })
    }

    private var hasFallbackTasksOutsideToday: Bool {
        allTasks.contains { task in
            guard !task.isDone else { return false }
            guard let dueDate = task.dueDate else { return true }
            return !dueDate.isToday
        }
    }

    private var overdueTasks: [TFTask] {
        sortedTasks(allTasks.filter(\.isOverdue))
    }

    private var scopedTasks: [TFTask] {
        switch selectedScope {
        case .today:
            return todayTasks
        case .all:
            return sortedTasks(allTasks)
        case .overdue:
            return overdueTasks
        }
    }

    private var visibleScopedTasks: [TFTask] {
        guard !searchText.isEmpty else { return scopedTasks }
        return scopedTasks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var openVisibleScopedTasks: [TFTask] {
        visibleScopedTasks.filter { !$0.isDone }
    }

    private var completedTodayTasks: [TFTask] {
        visibleScopedTasks
            .filter(\.isDone)
            .sorted { lhs, rhs in
                switch (lhs.completedAt, rhs.completedAt) {
                case (.some(let lCompleted), .some(let rCompleted)):
                    return lCompleted > rCompleted
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return lhs.createdAt > rhs.createdAt
                }
            }
    }

    private var morningTasks: [TFTask] { openVisibleScopedTasks.filter { $0.timeBlock == .morning } }
    private var afternoonTasks: [TFTask] { openVisibleScopedTasks.filter { $0.timeBlock == .afternoon } }
    private var eveningTasks: [TFTask] { openVisibleScopedTasks.filter { $0.timeBlock == .evening } }
    private var unscheduledTasks: [TFTask] {
        openVisibleScopedTasks.filter { $0.timeBlock == .unscheduled }
    }

    private var completedTasks: Int { visibleScopedTasks.filter(\.isDone).count }
    private var urgentCount: Int { visibleScopedTasks.filter { $0.priority == .high && !$0.isDone }.count }
    private var scopedProjectsCount: Int {
        Set(visibleScopedTasks.compactMap { $0.project?.id }).count
    }

    private var scopeSubtitle: String {
        switch selectedScope {
        case .today:
            return Date().fullDateString
        case .all:
            return "\(visibleScopedTasks.count) taken in beeld"
        case .overdue:
            return visibleScopedTasks.isEmpty ? "Geen verlopen taken" : "\(visibleScopedTasks.count) taken vragen aandacht"
        }
    }

    private var listTitle: String {
        switch selectedScope {
        case .today:
            return "Vandaag"
        case .all:
            return "Alle taken"
        case .overdue:
            return "Verlopen taken"
        }
    }

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
                            completedCount: completedTasks,
                            totalCount: visibleScopedTasks.count
                        )
                        .padding(.horizontal, TFSpacing.lg)

                        // Stats row
                        TodayStatsRow(
                            streakCount: currentStreak,
                            urgentCount: urgentCount,
                            projectsCount: selectedScope == .today ? activeProjects.count : scopedProjectsCount
                        )
                        .padding(.horizontal, TFSpacing.lg)

                        scopeFilterBar
                            .padding(.horizontal, TFSpacing.lg)

                        if selectedScope != .today {
                            searchBar
                                .padding(.horizontal, TFSpacing.lg)
                        }

                        // Task content
                        if visibleScopedTasks.isEmpty {
                            emptyStateView
                                .frame(minHeight: 250)
                        } else {
                            taskContent
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, TFSpacing.lg)
                }
                .scrollDismissesKeyboard(.interactively)
                .background(Color.tfBgPrimary)

                // FAB
                FABButton { showAddTask = true }
                    .padding(TFSpacing.xl)
            }
            .dismissKeyboardOnInteraction()
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
        .onAppear {
            selectedScope = TodayTaskScope(rawValue: defaultScopeRaw) ?? .today
            applyAutomaticFallbackScope()
        }
        .onChange(of: scopeFallbackToken) { _, _ in
            applyAutomaticFallbackScope()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: TFSpacing.xs) {
                Text(scopeSubtitle)
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

    private var scopeFilterBar: some View {
        HStack(spacing: TFSpacing.sm) {
            ForEach(TodayTaskScope.allCases) { scope in
                FilterPillView(
                    label: scope.rawValue,
                    isActive: selectedScope == scope
                ) {
                    selectedScope = scope
                    if scope == .today {
                        searchText = ""
                    }
                }
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.tfTextSecondary)
                .font(.system(size: 15))
            TextField("Zoeken in taken...", text: $searchText)
                .font(.tfSubheadline())
                .foregroundColor(.tfTextPrimary)
        }
        .padding(TFSpacing.md)
        .background(Color.tfBgSubtle)
        .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
    }

    @ViewBuilder
    private var taskContent: some View {
        if selectedScope == .today {
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
            if !completedTodayTasks.isEmpty {
                VStack(spacing: TFSpacing.sm) {
                    SectionHeaderView(
                        emoji: "✅",
                        title: "Voltooid vandaag",
                        done: completedTodayTasks.count,
                        total: completedTodayTasks.count
                    )

                    ForEach(Array(completedTodayTasks.enumerated()), id: \.element.id) { index, task in
                        TaskCardView(
                            task: task,
                            onFocus: { taskForFocus = $0 },
                            onEdit: { taskToEdit = $0 },
                            onDelete: deleteTask,
                            onDuplicate: duplicateTask
                        )
                        .padding(.horizontal, TFSpacing.lg)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.97)),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.04),
                            value: completedTodayTasks.count
                        )
                    }
                }
            }
        } else {
            VStack(spacing: TFSpacing.sm) {
                SectionHeaderView(
                    emoji: selectedScope == .all ? "🗂️" : "⚠️",
                    title: listTitle,
                    done: visibleScopedTasks.filter(\.isDone).count,
                    total: visibleScopedTasks.count
                )

                ForEach(Array(visibleScopedTasks.enumerated()), id: \.element.id) { index, task in
                    TaskCardView(
                        task: task,
                        onFocus: { taskForFocus = $0 },
                        onEdit: { taskToEdit = $0 },
                        onDelete: deleteTask,
                        onDuplicate: duplicateTask
                    )
                    .padding(.horizontal, TFSpacing.lg)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.97)),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.04),
                        value: visibleScopedTasks.count
                    )
                }
            }
        }
    }

    private var emptyStateView: some View {
        EmptyStateView(
            systemImage: selectedScope == .overdue ? "exclamationmark.triangle" : "checkmark.square",
            title: emptyStateTitle,
            subtitle: emptyStateSubtitle,
            buttonLabel: "Taak toevoegen",
            buttonAction: { showAddTask = true }
        )
    }

    private var emptyStateTitle: String {
        if selectedScope == .today {
            return "Geen taken vandaag"
        }
        if selectedScope == .overdue {
            return "Niets verlopen"
        }
        return searchText.isEmpty ? "Nog geen taken" : "Geen resultaten"
    }

    private var emptyStateSubtitle: String {
        if selectedScope == .today {
            return "Tik op + om taken toe te voegen aan je dag"
        }
        if selectedScope == .overdue {
            return "Je planning is weer helemaal bijgewerkt"
        }
        return searchText.isEmpty
            ? "Gebruik + om je eerste taak toe te voegen"
            : "Probeer een andere zoekterm of filter"
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

    private func sortedTasks(_ tasks: [TFTask]) -> [TFTask] {
        tasks.sorted { lhs, rhs in
            if lhs.isDone != rhs.isDone {
                return !lhs.isDone && rhs.isDone
            }
            switch (lhs.dueDate, rhs.dueDate) {
            case (.some(let lDate), .some(let rDate)):
                if lDate != rDate { return lDate < rDate }
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.none, .none):
                break
            }
            switch (lhs.dueTime, rhs.dueTime) {
            case (.some(let lTime), .some(let rTime)):
                if lTime != rTime { return lTime < rTime }
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.none, .none):
                break
            }
            return lhs.createdAt > rhs.createdAt
        }
    }

    private func applyAutomaticFallbackScope() {
        guard selectedScope == .today else { return }
        guard todayTasks.isEmpty else { return }
        guard hasFallbackTasksOutsideToday else { return }
        selectedScope = .all
    }
}
