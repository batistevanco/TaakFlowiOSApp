// ProjectsView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

struct ProjectsView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<TFProject> { !$0.isArchived },
           sort: \.sortOrder) private var activeProjects: [TFProject]

    @State private var viewModel = ProjectViewModel()
    @State private var showAddProject = false
    @State private var projectToEdit: TFProject? = nil
    @State private var selectedProject: TFProject? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: TFSpacing.sm) {
                    // Header
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: TFSpacing.xs) {
                            Text("\(activeProjects.count) actieve projecten")
                                .font(.tfCaption())
                                .tracking(0.5)
                                .foregroundColor(.tfTextSecondary)
                                .textCase(.uppercase)
                            Text("Projecten")
                                .font(.tfLargeTitle())
                                .foregroundColor(.tfTextPrimary)
                                .tracking(-1.0)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, TFSpacing.lg)
                    .padding(.top, TFSpacing.lg)
                    .padding(.bottom, TFSpacing.md)

                    if activeProjects.isEmpty {
                        EmptyStateView(
                            systemImage: "folder",
                            title: "Geen projecten",
                            subtitle: "Maak een project aan om taken te groeperen",
                            buttonLabel: "Project aanmaken",
                            buttonAction: { showAddProject = true }
                        )
                        .frame(minHeight: 300)
                    } else {
                        // Project cards
                        ForEach(Array(activeProjects.enumerated()), id: \.element.id) { index, project in
                            NavigationLink(destination: ProjectDetailView(project: project)) {
                                ProjectCard(
                                    project: project,
                                    onArchive: { viewModel.archiveProject(project) },
                                    onDelete: { context.delete(project) },
                                    onEdit: { projectToEdit = project }
                                )
                                .padding(.horizontal, TFSpacing.lg)
                            }
                            .buttonStyle(.plain)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.97)),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.055),
                                value: activeProjects.count
                            )
                        }

                        // New project dashed card
                        Button(action: { showAddProject = true }) {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.tfAccent)
                                Text("Nieuw project")
                                    .font(.tfSubheadline())
                                    .foregroundColor(.tfAccent)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: TFRadius.cardLg)
                                    .strokeBorder(Color.tfAccent.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                            )
                        }
                        .buttonStyle(SpringButtonStyle())
                        .padding(.horizontal, TFSpacing.lg)
                        .padding(.top, TFSpacing.sm)
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top, TFSpacing.xs)
            }
            .background(Color.tfBgPrimary)
        }
        .sheet(isPresented: $showAddProject) {
            AddEditProjectSheet(existingProject: nil)
        }
        .sheet(item: $projectToEdit) { project in
            AddEditProjectSheet(existingProject: project)
        }
    }
}
