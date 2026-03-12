// SectionHeaderView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct SectionHeaderView: View {
    let emoji: String
    let title: String
    let done: Int
    let total: Int

    var body: some View {
        HStack {
            HStack(spacing: TFSpacing.xs) {
                Text(emoji)
                    .font(.system(size: 13))
                Text(title.uppercased())
                    .font(.tfCaption())
                    .tracking(0.8)
                    .foregroundColor(.tfTextSecondary)
            }
            Spacer()
            Text("\(done)/\(total)")
                .font(.tfCaption())
                .foregroundColor(.tfAccent)
                .padding(.horizontal, TFSpacing.sm)
                .padding(.vertical, 3)
                .background(Color.tfAccent.opacity(0.10))
                .clipShape(Capsule())
        }
        .padding(.horizontal, TFSpacing.lg)
    }
}

#Preview {
    SectionHeaderView(emoji: "🌅", title: "Ochtend", done: 2, total: 4)
        .padding()
        .background(Color.tfBgPrimary)
}
