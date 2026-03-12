// CheckButtonView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct CheckButtonView: View {
    let isDone: Bool
    let onToggle: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                onToggle()
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(isDone ? Color.tfPriorityLow : Color.white)
                    .frame(width: 26, height: 26)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .strokeBorder(
                                isDone ? Color.tfPriorityLow : Color.tfBorderMedium,
                                lineWidth: 1.5
                            )
                    )
                    .shadow(
                        color: isDone ? Color.tfPriorityLow.opacity(0.4) : .clear,
                        radius: 6, x: 0, y: 0
                    )

                if isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(SpringButtonStyle())
        .accessibilityLabel(isDone ? "Afgevinkt" : "Niet afgevinkt")
        .accessibilityHint("Tik om de taak af te vinken")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Spring Button Style

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.2 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

#Preview {
    HStack(spacing: 20) {
        CheckButtonView(isDone: false) {}
        CheckButtonView(isDone: true) {}
    }
    .padding()
}
