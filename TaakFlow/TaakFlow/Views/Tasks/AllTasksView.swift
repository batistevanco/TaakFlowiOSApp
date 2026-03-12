// AllTasksView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

struct AllTasksView: View {
    @Environment(\.modelContext) private var context
    @Query private var allTasks: [TFTask]

    @State private var viewModel = TaskViewModel()
    @State private var showAddTask = false
    @State private var taskToEdit: TFTask? = nil
    @State private var taskForFocus: TFTask? = nil

    private var displayedTasks: [TFTask] {
        viewModel.filteredTasks(allTasks)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: TFSpacing.xs) {
                        Text("\(allTasks.count) taken")
                            .font(.tfCaption())
                            .tracking(0.5)
                            .foregroundColor(.tfTextSecondary)
                            .textCase(.uppercase)
                        Text("Alle Taken")
                            .font(.tfLargeTitle())
                            .foregroundColor(.tfTextPrimary)
                            .tracking(-1.0)
                    }
                    Spacer()
                    Button(action: { showAddTask = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(LinearGradient.tfHero)
                            .clipShape(Circle())
                            .accentGlowShadow()
                    }
                    .accessibilityLabel("Taak toevoegen")
                }
                .padding(.horizontal, TFSpacing.lg)
                .padding(.top, TFSpacing.lg)
                .padding(.bottom, TFSpacing.md)
                .background(Color.tfBgPrimary)

                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.tfTextSecondary)
                        .font(.system(size: 15))
                    TextField("Zoeken...", text: $viewModel.searchText)
                        .font(.tfSubheadline())
                        .foregroundColor(.tfTextPrimary)
                }
                .padding(TFSpacing.md)
                .background(Color.tfBgSubtle)
                .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
                .padding(.horizontal, TFSpacing.lg)
                .padding(.bottom, TFSpacing.sm)

                // Filter bar
                TaskFilterBar(
                    activeFilter: $viewModel.activeFilter,
                    sortOption: $viewModel.sortOption
                )

                Divider()
                    .padding(.top, TFSpacing.xs)

                // Task list
                if displayedTasks.isEmpty {
                    EmptyStateView(
                        systemImage: "checkmark.square",
                        title: "Geen taken",
                        subtitle: "Tik op + om je eerste taak toe te voegen",
                        buttonLabel: "Taak toevoegen",
                        buttonAction: { showAddTask = true }
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: TFSpacing.sm) {
                            ForEach(Array(displayedTasks.enumerated()), id: \.element.id) { index, task in
                                TaskCardView(
                                    task: task,
                                    onFocus: { taskForFocus = $0 },
                                    onEdit: { taskToEdit = $0 },
                                    onDelete: { context.delete($0) },
                                    onDuplicate: duplicateTask
                                )
                                .padding(.horizontal, TFSpacing.lg)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.97)),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.055),
                                    value: displayedTasks.count
                                )
                            }
                            Spacer(minLength: 100)
                        }
                        .padding(.top, TFSpacing.md)
                    }
                }
            }
            .background(Color.tfBgPrimary)
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

    // MARK: - Actions

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
