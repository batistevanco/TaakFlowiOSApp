// GradientHeroCardView.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct GradientHeroCardView: View {
    let completedCount: Int
    let totalCount: Int

    private var percentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    private var contextEmoji: String {
        switch percentage {
        case 1.0:         return "🎉"
        case 0.8...:      return "🏆"
        case 0.5...:      return "⚡"
        default:          return "🚀"
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 100, height: 100)
                .blur(radius: 1)
                .offset(x: 20, y: -30)

            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 70, height: 70)
                .blur(radius: 1)
                .offset(x: -120, y: 60)

            // Content
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: TFSpacing.sm) {
                    Text("\(completedCount) van \(totalCount) taken klaar")
                        .font(.tfSubheadline())
                        .foregroundColor(.white.opacity(0.85))

                    Text("\(Int(percentage * 100))%")
                        .font(.system(size: 42, weight: .heavy))
                        .foregroundColor(.white)
                        .tracking(-1.0)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.20))
                                .frame(height: 6)
                            Capsule()
                                .fill(Color.white.opacity(0.90))
                                .frame(width: geo.size.width * percentage, height: 6)
                                .animation(.spring(response: 0.9, dampingFraction: 0.7).delay(0.2),
                                           value: percentage)
                        }
                    }
                    .frame(height: 6)
                }

                Spacer()

                Text(contextEmoji)
                    .font(.system(size: 48))
                    .padding(.bottom, TFSpacing.xs)
            }
            .padding(TFSpacing.xl)
        }
        .background(LinearGradient.tfHero)
        .clipShape(RoundedRectangle(cornerRadius: TFRadius.cardLg))
        .heroGlowShadow()
    }
}

#Preview {
    GradientHeroCardView(completedCount: 3, totalCount: 7)
        .padding()
        .background(Color.tfBgPrimary)
}
