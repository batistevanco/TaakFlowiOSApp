// ProjectCard.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct ProjectCard: View {
    let project: TFProject
    var onArchive: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil

    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: TFSpacing.md) {
            HStack(spacing: TFSpacing.md) {
                // Emoji icon
                ZStack {
                    RoundedRectangle(cornerRadius: TFRadius.projectIcon)
                        .fill(project.color.opacity(0.10))
                        .frame(width: 44, height: 44)
                    Text(project.emoji)
                        .font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: TFSpacing.xs) {
                    Text(project.name)
                        .font(.tfHeadline())
                        .foregroundColor(.tfTextPrimary)
                    Text("\(project.completedTasks) van \(project.totalTasks) klaar")
                        .font(.tfCaption2())
                        .foregroundColor(.tfTextSecondary)
                }

                Spacer()

                if let deadline = project.deadline {
                    deadlineBadge(for: deadline)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.tfTextSecondary)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.tfBorderLight)
                        .frame(height: 5)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(project.color)
                        .frame(width: geo.size.width * project.progressPercentage, height: 5)
                        .shadow(color: project.color.opacity(0.3), radius: 4, x: 0, y: 1)
                        .animation(.spring(response: 0.9, dampingFraction: 0.7).delay(0.2),
                                   value: project.progressPercentage)
                }
            }
            .frame(height: 5)
        }
        .padding(TFSpacing.lg)
        .background(Color.tfBgCard)
        .clipShape(RoundedRectangle(cornerRadius: TFRadius.cardLg))
        .cardShadow()
        .contextMenu {
            if let onEdit {
                Button { onEdit() } label: {
                    Label("Bewerken", systemImage: "pencil")
                }
            }
            if let onArchive {
                Button { onArchive() } label: {
                    Label("Archiveer", systemImage: "archivebox")
                }
            }
            Divider()
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Verwijder", systemImage: "trash")
            }
        }
        .alert("Project verwijderen?", isPresented: $showDeleteAlert) {
            Button("Verwijder", role: .destructive) { onDelete?() }
            Button("Annuleer", role: .cancel) {}
        } message: {
            Text("Alle taken in dit project worden ook verwijderd.")
        }
    }

    @ViewBuilder
    private func deadlineBadge(for date: Date) -> some View {
        let urgency = project.deadlineUrgency
        Text(date.dayAndMonthString)
            .font(.tfCaption2())
            .foregroundColor(urgency.color)
            .padding(.horizontal, TFSpacing.sm)
            .padding(.vertical, 3)
            .background(urgency.color.opacity(0.10))
            .clipShape(Capsule())
    }
}
