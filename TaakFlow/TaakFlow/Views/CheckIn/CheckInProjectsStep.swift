// CheckInProjectsStep.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct CheckInProjectsStep: View {
    @Bindable var viewModel: CheckInViewModel
    let projects: [TFProject]

    var body: some View {
        VStack(alignment: .leading, spacing: TFSpacing.xl) {
            VStack(alignment: .leading, spacing: TFSpacing.xs) {
                Text("Verder werken")
                    .font(.tfLargeTitle())
                    .foregroundColor(.tfTextPrimary)
                    .tracking(-1.0)
                Text("aan projecten? 📁")
                    .font(.tfLargeTitle())
                    .foregroundColor(.tfTextPrimary)
                    .tracking(-1.0)
            }

            VStack(spacing: 0) {
                ForEach(Array(projects.enumerated()), id: \.element.id) { index, project in
                    let isSelected = viewModel.selectedProjectIDs.contains(project.id)

                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            if isSelected {
                                viewModel.selectedProjectIDs.remove(project.id)
                            } else {
                                viewModel.selectedProjectIDs.insert(project.id)
                            }
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        HStack(spacing: TFSpacing.md) {
                            Text(project.emoji)
                                .font(.system(size: 20))

                            Text(project.name)
                                .font(.tfSubheadline())
                                .foregroundColor(.tfTextPrimary)

                            Spacer()

                            // Checkbox
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isSelected ? Color.tfAccent : Color.clear)
                                    .frame(width: 22, height: 22)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .strokeBorder(isSelected ? Color.tfAccent : Color.tfBorderMedium, lineWidth: 1.5)
                                    )
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(TFSpacing.lg)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .strokeBorder(Color.tfBorderLight, lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)

                    if index < projects.count - 1 {
                        Divider().padding(.leading, TFSpacing.xl)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: TFRadius.cardLg))
            .elevatedCardShadow()
        }
        .padding(.horizontal, TFSpacing.xl)
    }
}
