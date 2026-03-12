// TaskCardView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI
import SwiftData

struct TaskCardView: View {
    @Bindable var task: TFTask
    var onFocus: ((TFTask) -> Void)? = nil
    var onEdit: ((TFTask) -> Void)? = nil
    var onDelete: ((TFTask) -> Void)? = nil
    var onDuplicate: ((TFTask) -> Void)? = nil

    @State private var showDeleteAlert = false

    var body: some View {
        HStack(spacing: 0) {
            // Priority stripe
            Rectangle()
                .fill(task.priority.color)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            HStack(spacing: TFSpacing.md) {
                CheckButtonView(isDone: task.isDone) {
                    task.isDone.toggle()
                    if task.isDone { task.completedAt = Date() } else { task.completedAt = nil }
                }

                VStack(alignment: .leading, spacing: TFSpacing.xs) {
                    Text(task.title)
                        .font(.tfBody())
                        .foregroundColor(task.isDone ? .tfTextSecondary : .tfTextPrimary)
                        .strikethrough(task.isDone, color: .tfTextSecondary)
                        .opacity(task.isDone ? 0.45 : 1.0)
                        .lineLimit(2)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: task.isDone)

                    if let dueTime = task.dueTime {
                        HStack(spacing: TFSpacing.xs) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                                .foregroundColor(.tfTextSecondary)
                            Text(dueTime.timeString)
                                .font(.tfCaption2())
                                .foregroundColor(.tfTextSecondary)
                        }
                    }

                    if !task.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: TFSpacing.xs) {
                                ForEach(task.tags) { tag in
                                    TagPillView(tag: tag)
                                }
                            }
                        }
                    }
                }

                Spacer(minLength: 0)

                PriorityDotView(priority: task.priority)
            }
            .padding(.horizontal, TFSpacing.md)
            .padding(.vertical, TFSpacing.md)
        }
        .background(Color.tfBgCard)
        .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
        .cardShadow()
        .contentShape(RoundedRectangle(cornerRadius: TFRadius.card))
        .onTapGesture {
            onFocus?(task)
        }
        .contextMenu {
            if let onEdit {
                Button {
                    onEdit(task)
                } label: {
                    Label("Bewerken", systemImage: "pencil")
                }
            }
            Button {
                onFocus?(task)
            } label: {
                Label("Focus Mode", systemImage: "timer")
            }
            if let onDuplicate {
                Button {
                    onDuplicate(task)
                } label: {
                    Label("Dupliceer", systemImage: "doc.on.doc")
                }
            }
            Divider()
            if let onDelete {
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Verwijder", systemImage: "trash")
                }
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    task.isDone.toggle()
                    if task.isDone { task.completedAt = Date() } else { task.completedAt = nil }
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } label: {
                Label("Klaar", systemImage: "checkmark")
            }
            .tint(.tfPriorityLow)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Verwijder", systemImage: "trash")
            }
        }
        .alert("Taak verwijderen?", isPresented: $showDeleteAlert) {
            Button("Verwijder", role: .destructive) {
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                onDelete?(task)
            }
            Button("Annuleer", role: .cancel) {}
        } message: {
            Text("Deze actie kan niet ongedaan worden gemaakt.")
        }
    }
}
