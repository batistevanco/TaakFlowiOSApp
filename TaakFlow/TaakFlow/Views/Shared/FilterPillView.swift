// FilterPillView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct FilterPillView: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            Text(label)
                .font(.tfCaption())
                .tracking(0.3)
                .foregroundColor(isActive ? .white : .tfTextSecondary)
                .padding(.horizontal, TFSpacing.md)
                .padding(.vertical, TFSpacing.sm)
                .background(
                    Capsule()
                        .fill(isActive ? Color.tfAccent : Color.tfBgSubtle)
                )
                .shadow(color: isActive ? Color.tfAccent.opacity(0.30) : .clear,
                        radius: 8, x: 0, y: 2)
                .offset(y: isActive ? -2 : 0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
    }
}

#Preview {
    HStack {
        FilterPillView(label: "Alle", isActive: true) {}
        FilterPillView(label: "Hoog", isActive: false) {}
        FilterPillView(label: "Klaar", isActive: false) {}
    }
    .padding()
}
