// TagPillView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct TagPillView: View {
    let tag: TFTag

    var body: some View {
        Text(tag.name.uppercased())
            .font(.tfCaption())
            .tracking(0.5)
            .foregroundColor(tag.color)
            .padding(.horizontal, TFSpacing.sm)
            .padding(.vertical, 3)
            .background(tag.color.opacity(0.1))
            .clipShape(Capsule())
    }
}

struct SmallTagPill: View {
    let name: String
    let color: Color

    var body: some View {
        Text(name.uppercased())
            .font(.tfCaption())
            .tracking(0.5)
            .foregroundColor(color)
            .padding(.horizontal, TFSpacing.sm)
            .padding(.vertical, 3)
            .background(color.opacity(0.10))
            .clipShape(Capsule())
    }
}

#Preview {
    HStack {
        SmallTagPill(name: "Work", color: .tfAccent)
        SmallTagPill(name: "Urgent", color: .tfPriorityHigh)
    }
    .padding()
}
