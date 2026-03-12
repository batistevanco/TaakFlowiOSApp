// TimeBlockSection.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct TimeBlockSection: View {
    let block: TFTimeBlock
    let tasks: [TFTask]
    var onFocus: ((TFTask) -> Void)? = nil
    var onEdit: ((TFTask) -> Void)? = nil
    var onDelete: ((TFTask) -> Void)? = nil
    var onDuplicate: ((TFTask) -> Void)? = nil

    private var doneTasks: Int { tasks.filter(\.isDone).count }

    var body: some View {
        VStack(spacing: TFSpacing.sm) {
            SectionHeaderView(
                emoji: block.emoji,
                title: block.label,
                done: doneTasks,
                total: tasks.count
            )

            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                TaskCardView(
                    task: task,
                    onFocus: onFocus,
                    onEdit: onEdit,
                    onDelete: onDelete,
                    onDuplicate: onDuplicate
                )
                .padding(.horizontal, TFSpacing.lg)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.97)),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.055),
                    value: tasks.count
                )
            }
        }
    }
}
