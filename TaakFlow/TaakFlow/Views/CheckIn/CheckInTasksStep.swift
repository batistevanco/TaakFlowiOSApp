// CheckInTasksStep.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct CheckInTasksStep: View {
    @Bindable var viewModel: CheckInViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: TFSpacing.xl) {
            VStack(alignment: .leading, spacing: TFSpacing.xs) {
                Text("Welke taken wil")
                    .font(.tfLargeTitle())
                    .foregroundColor(.tfTextPrimary)
                    .tracking(-1.0)
                Text("je eerst doen? ⚡")
                    .font(.tfLargeTitle())
                    .foregroundColor(.tfTextPrimary)
                    .tracking(-1.0)
            }

            VStack(spacing: 0) {
                taskInputRow(
                    number: "1",
                    placeholder: "Taak 1...",
                    text: $viewModel.plannedTaskTitle1
                )
                Divider()
                    .padding(.leading, TFSpacing.xl)
                taskInputRow(
                    number: "2",
                    placeholder: "Taak 2...",
                    text: $viewModel.plannedTaskTitle2
                )
                Divider()
                    .padding(.leading, TFSpacing.xl)
                taskInputRow(
                    number: "3",
                    placeholder: "Taak 3...",
                    text: $viewModel.plannedTaskTitle3
                )
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: TFRadius.cardLg))
            .elevatedCardShadow()
        }
        .padding(.horizontal, TFSpacing.xl)
    }

    @ViewBuilder
    private func taskInputRow(number: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: TFSpacing.md) {
            Text(number)
                .font(.system(size: 13, weight: .heavy))
                .foregroundColor(.tfTextSecondary)
                .frame(width: 24)
            TextField(placeholder, text: text)
                .font(.tfSubheadline())
                .foregroundColor(.tfTextPrimary)
        }
        .padding(TFSpacing.lg)
    }
}
