// EmptyStateView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let subtitle: String
    var buttonLabel: String? = nil
    var buttonAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: TFSpacing.lg) {
            Image(systemName: systemImage)
                .font(.system(size: 52, weight: .light))
                .foregroundColor(.tfTextSecondary.opacity(0.5))
                .padding(.bottom, TFSpacing.sm)

            VStack(spacing: TFSpacing.xs) {
                Text(title)
                    .font(.tfHeadline())
                    .foregroundColor(.tfTextPrimary)

                Text(subtitle)
                    .font(.tfSubheadline())
                    .foregroundColor(.tfTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TFSpacing.xxxl)
            }

            if let label = buttonLabel, let action = buttonAction {
                Button(action: action) {
                    Text(label)
                        .font(.tfSubheadline())
                        .foregroundColor(.white)
                        .padding(.horizontal, TFSpacing.xl)
                        .padding(.vertical, TFSpacing.md)
                        .background(LinearGradient.tfButton)
                        .clipShape(Capsule())
                        .buttonGlowShadow(color: .tfAccent)
                }
                .buttonStyle(SpringButtonStyle())
                .padding(.top, TFSpacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        systemImage: "checkmark.square",
        title: "Geen taken",
        subtitle: "Tik op + om je eerste taak toe te voegen",
        buttonLabel: "Taak toevoegen",
        buttonAction: {}
    )
    .background(Color.tfBgPrimary)
}
