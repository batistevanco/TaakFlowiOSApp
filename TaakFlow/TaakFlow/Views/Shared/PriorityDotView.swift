// PriorityDotView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct PriorityDotView: View {
    let priority: TFPriority

    var body: some View {
        Circle()
            .fill(priority.color)
            .frame(width: 8, height: 8)
            .accessibilityLabel("Prioriteit: \(priority.label)")
    }
}

#Preview {
    HStack(spacing: 12) {
        ForEach(TFPriority.allCases) { p in
            PriorityDotView(priority: p)
        }
    }
    .padding()
}
