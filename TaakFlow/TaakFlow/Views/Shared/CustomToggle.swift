// CustomToggle.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct CustomToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isOn.toggle()
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? Color.tfAccent : Color.tfBorderMedium)
                    .frame(width: 46, height: 26)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isOn)

                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
                    .padding(3)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isOn ? "Aan" : "Uit")
    }
}

#Preview {
    @Previewable @State var on = true
    HStack(spacing: 20) {
        CustomToggle(isOn: $on)
        CustomToggle(isOn: .constant(false))
    }
    .padding()
}
