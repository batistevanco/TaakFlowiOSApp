// CheckInGoalStep.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct CheckInGoalStep: View {
    @Bindable var viewModel: CheckInViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: TFSpacing.xl) {
            VStack(alignment: .leading, spacing: TFSpacing.xs) {
                Text("Wat is jouw")
                    .font(.tfLargeTitle())
                    .foregroundColor(.tfTextPrimary)
                    .tracking(-1.0)
                Text("hoofdoel vandaag? 🎯")
                    .font(.tfLargeTitle())
                    .foregroundColor(.tfTextPrimary)
                    .tracking(-1.0)
            }

            VStack {
                TextField(
                    "Bijv. De client proposal afwerken en versturen...",
                    text: $viewModel.dailyGoal,
                    axis: .vertical
                )
                .font(.tfSubheadline())
                .foregroundColor(.tfTextPrimary)
                .lineLimit(3...6)
                .focused($isFocused)
                .padding(TFSpacing.lg)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: TFRadius.cardLg))
                .overlay(
                    RoundedRectangle(cornerRadius: TFRadius.cardLg)
                        .strokeBorder(isFocused ? Color.tfAccent.opacity(0.5) : Color.clear, lineWidth: 2)
                )
                .shadow(color: isFocused ? Color.tfAccent.opacity(0.15) : .black.opacity(0.05),
                        radius: isFocused ? 12 : 4, x: 0, y: 2)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
            }
            .onAppear { isFocused = true }
        }
        .padding(.horizontal, TFSpacing.xl)
    }
}
