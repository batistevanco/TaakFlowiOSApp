// ProjectDetailView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var project: TFProject

    @State private var showAddTask = false
    @State private var taskToEdit: TFTask? = nil
    @State private var taskForFocus: TFTask? = nil
    @State private var showEditProject = false

    private var pendingTasks: [TFTask] { project.tasks.filter { !$0.isDone } }
    private var doneTasks: [TFTask] { project.tasks.filter { $0.isDone } }
    private var overdueTasks: [TFTask] { project.tasks.filter { $0.isOverdue } }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: TFSpacing.xl, pinnedViews: []) {
                    // Project hero
                    projectHero

                    // Stats
                    statsRow

                    // Task list
                    if project.tasks.isEmpty {
                        EmptyStateView(
                            systemImage: "checklist",
                            title: "Geen taken",
                            subtitle: "Tik op + om een taak aan dit project toe te voegen",
                            buttonLabel: "Taak toevoegen",
                            buttonAction: { showAddTask = true }
                        )
                        .frame(minHeight: 200)
                    } else {
                        // Pending tasks
                        if !pendingTasks.isEmpty {
                            VStack(spacing: TFSpacing.sm) {
                                SectionHeaderView(
                                    emoji: "📋",
                                    title: "Te doen",
                                    done: 0,
                                    total: pendingTasks.count
                                )
                                ForEach(pendingTasks) { task in
                                    TaskCardView(
                                        task: task,
                                        onFocus: { taskForFocus = $0 },
                                        onEdit: { taskToEdit = $0 },
                                        onDelete: { context.delete($0) },
                                        onDuplicate: nil
                                    )
                                    .padding(.horizontal, TFSpacing.lg)
                                }
                            }
                        }

                        // Done tasks
                        if !doneTasks.isEmpty {
                            VStack(spacing: TFSpacing.sm) {
                                SectionHeaderView(
                                    emoji: "✅",
                                    title: "Klaar",
                                    done: doneTasks.count,
                                    total: doneTasks.count
                                )
                                ForEach(doneTasks) { task in
                                    TaskCardView(
                                        task: task,
                                        onFocus: nil,
                                        onEdit: { taskToEdit = $0 },
                                        onDelete: { context.delete($0) },
                                        onDuplicate: nil
                                    )
                                    .padding(.horizontal, TFSpacing.lg)
                                }
                            }
                        }
                    }
                    Spacer(minLength: 100)
                }
                .padding(.top, TFSpacing.lg)
            }
            .background(Color.tfBgPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: TFSpacing.xs) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Terug")
                                .font(.tfSubheadline())
                        }
                        .foregroundColor(.tfAccent)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showEditProject = true }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.tfAccent)
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                FABButton { showAddTask = true }
                    .padding(TFSpacing.xl)
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddEditTaskSheet(existingTask: nil, defaultProject: project)
        }
        .sheet(item: $taskToEdit) { task in
            AddEditTaskSheet(existingTask: task)
        }
        .sheet(isPresented: $showEditProject) {
            AddEditProjectSheet(existingProject: project)
        }
        .fullScreenCover(item: $taskForFocus) { task in
            FocusModeView(task: task)
        }
    }

    // MARK: - Project Hero

    private var projectHero: some View {
        VStack(spacing: TFSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(project.color.opacity(0.12))
                    .frame(width: 72, height: 72)
                Text(project.emoji)
                    .font(.system(size: 40))
            }

            VStack(spacing: TFSpacing.xs) {
                Text(project.name)
                    .font(.tfTitle2())
                    .foregroundColor(.tfTextPrimary)
                    .tracking(-0.5)

                if let deadline = project.deadline {
                    HStack(spacing: TFSpacing.xs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                        Text(deadline.fullDateString)
                            .font(.tfCaption())
                    }
                    .foregroundColor(project.deadlineUrgency.color)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, TFSpacing.lg)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: TFSpacing.md) {
            miniStatCard(value: "\(project.totalTasks)", label: "Totaal", color: .tfAccent)
            miniStatCard(value: "\(project.completedTasks)", label: "Klaar", color: .tfPriorityLow)
            miniStatCard(value: "\(overdueTasks.count)", label: "Verlopen", color: .tfPriorityHigh)
        }
        .padding(.horizontal, TFSpacing.lg)
    }

    private func miniStatCard(value: String, label: String, color: Color) -> some View {
        VStack(spacing: TFSpacing.xs) {
            Text(value)
                .font(.system(size: 24, weight: .heavy))
                .foregroundColor(color)
            Text(label)
                .font(.tfCaption2())
                .foregroundColor(.tfTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(TFSpacing.md)
        .background(Color.tfBgCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .cardShadow()
    }
}
