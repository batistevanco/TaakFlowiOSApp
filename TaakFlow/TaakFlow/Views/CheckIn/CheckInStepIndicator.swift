// CheckInStepIndicator.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct CheckInStepIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: TFSpacing.sm) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(dotColor(for: index))
                    .frame(width: dotWidth(for: index), height: 4)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
            }
        }
    }

    private func dotColor(for index: Int) -> Color {
        if index <= currentStep { return .tfAccent }
        return .tfBorderMedium
    }

    private func dotWidth(for index: Int) -> CGFloat {
        index == currentStep ? 24 : 8
    }
}

#Preview {
    CheckInStepIndicator(currentStep: 1, totalSteps: 4)
        .padding()
}
