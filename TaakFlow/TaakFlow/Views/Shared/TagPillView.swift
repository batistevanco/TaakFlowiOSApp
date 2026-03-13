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

struct ProjectPillView: View {
    let project: TFProject

    var body: some View {
        HStack(spacing: TFSpacing.xs) {
            Text(project.emoji)
                .font(.system(size: 11))
            Text(project.name.uppercased())
                .lineLimit(1)
        }
        .font(.tfCaption())
        .tracking(0.4)
        .foregroundColor(project.color)
        .padding(.horizontal, TFSpacing.sm)
        .padding(.vertical, 3)
        .background(project.color.opacity(0.10))
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
