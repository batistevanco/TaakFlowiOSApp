// CheckInMoodStep.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct CheckInMoodStep: View {
    @Bindable var viewModel: CheckInViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: TFSpacing.xl) {
            // Chip
            HStack {
                Text("☀️ Ochtend Check-in")
                    .font(.tfCaption())
                    .tracking(0.5)
                    .foregroundColor(.tfAccent)
                    .padding(.horizontal, TFSpacing.md)
                    .padding(.vertical, TFSpacing.xs)
                    .background(Color.tfAccent.opacity(0.10))
                    .clipShape(Capsule())
            }

            // Title
            VStack(alignment: .leading, spacing: TFSpacing.xs) {
                Text("Hoe voel jij je")
                    .font(.tfLargeTitle())
                    .foregroundColor(.tfTextPrimary)
                    .tracking(-1.0)
                Text("vandaag? 👋")
                    .font(.tfLargeTitle())
                    .foregroundColor(.tfTextPrimary)
                    .tracking(-1.0)
                Text("Neem even 2 minuten voor jezelf")
                    .font(.tfSubheadline())
                    .foregroundColor(.tfTextSecondary)
                    .padding(.top, TFSpacing.xs)
            }

            // Mood buttons
            VStack(spacing: TFSpacing.sm) {
                HStack(spacing: TFSpacing.sm) {
                    ForEach(viewModel.moods) { mood in
                        let isSelected = viewModel.selectedMoodScore == mood.id
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                viewModel.selectedMoodScore = mood.id
                                viewModel.selectedMoodEmoji = mood.emoji
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }) {
                            VStack(spacing: TFSpacing.sm) {
                                Text(mood.emoji)
                                    .font(.system(size: 28))
                                Text(mood.label)
                                    .font(.tfCaption())
                                    .foregroundColor(isSelected ? .tfAccent : .tfTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, TFSpacing.md)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: TFRadius.card))
                            .overlay(
                                RoundedRectangle(cornerRadius: TFRadius.card)
                                    .strokeBorder(isSelected ? Color.tfAccent : Color.clear, lineWidth: 2)
                            )
                            .scaleEffect(isSelected ? 1.05 : (viewModel.selectedMoodScore != nil ? 0.97 : 1.0))
                            .shadow(color: isSelected ? Color.tfAccent.opacity(0.20) : .black.opacity(0.05),
                                    radius: isSelected ? 8 : 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.selectedMoodScore)
                    }
                }
            }
            .padding(TFSpacing.lg)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: TFRadius.cardLg))
            .elevatedCardShadow()
        }
        .padding(.horizontal, TFSpacing.xl)
    }
}
